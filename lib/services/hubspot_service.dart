import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../features/savings/savings_provider.dart';

class HubSpotService {
  // Credentials
  static const String _portalId = '442678262';
  static const String _formGuid = 'aed1b8bc-1b82-4f66-bcfd-7405bf0f6844';
  
  // SECURITY: Access Token is REMOVED from client code. 
  // It is injected securely by the backend/proxy.
  
  static const String _submitUrl = 'https://api.hsforms.com/submissions/v3/integration/submit';

  /// 1. Upload a single file to HubSpot via a secure Proxy/Backend
  /// Returns a record with either the URL or an error message.
  Future<({String? url, String? error})> _uploadFile(XFile file, String folder) async {
    try {
      Uri uri;
      
      if (kIsWeb) {
        // Use the Python backend at /api/upload for Web
        const String proxyUrl = String.fromEnvironment(
          'PROXY_URL',
          defaultValue: '/api/upload',
        );
        uri = Uri.parse(proxyUrl);
        if (!uri.hasScheme) {
           uri = Uri.base.resolve(proxyUrl);
        }
      } else if (kReleaseMode) {
        // PRODUCTION: Use the configured backend URL
        const String prodUrl = String.fromEnvironment(
          'BACKEND_UPLOAD_URL',
          defaultValue: 'https://savenest.au/api/upload',
        );
        uri = Uri.parse(prodUrl);
      } else {
        // SECURITY: Delegate to a secure backend/proxy.
        // For development (Android Emulator), use 10.0.2.2 to access host's localhost.
        // For iOS Simulator or Desktop, use 127.0.0.1.
        
        String host = '127.0.0.1';
        if (defaultTargetPlatform == TargetPlatform.android) {
          host = '10.0.2.2';
        }
        
        // Ensure your local proxy_server.py is running on this port
        uri = Uri.parse('http://$host:8888');
      }

      final request = http.MultipartRequest('POST', uri);
      
      // NOTE: No Authorization header is added here. 
      // The proxy/backend is responsible for adding the secret token.

      // File Data
      final bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      ));

      // Note: The simple Python proxy currently hardcodes folderPath/options.
      // If using a more advanced backend, you would send them here.

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('url')) {
          return (url: data['url'] as String?, error: null);
        } else {
          return (url: null, error: 'Invalid JSON response: ${response.body}');
        }
      } else {
        final errorMsg = 'Status ${response.statusCode}: ${response.body}';
        debugPrint('File Upload Failed: $errorMsg');
        return (url: null, error: errorMsg);
      }
    } catch (e) {
      debugPrint('File Upload Error: $e');
      return (url: null, error: e.toString());
    }
  }

  /// 2. Submit the Form with Data + File Links
  Future<Map<String, dynamic>> submitForm({
    required String name,
    required String email,
    required String phone,
    required double totalSavings,
    required List<String> services,
    required Map<UtilityType, XFile?> billImages,
  }) async {
    final submitUrl = Uri.parse('$_submitUrl/$_portalId/$_formGuid');
    
    // Prepare the fields list
    final List<Map<String, dynamic>> fields = [
      {'name': 'firstname', 'value': name},
      {'name': 'email', 'value': email},
      {'name': 'phone', 'value': phone},
      {'name': 'projected_annual_savings', 'value': totalSavings.toStringAsFixed(2)},
      {'name': 'services_to_switch', 'value': services.join(';')},
    ];

    List<String> uploadErrors = [];

    // Upload Images and add their URLs to fields
    for (var entry in billImages.entries) {
      if (entry.value != null) {
        // Attempt upload
        final result = await _uploadFile(entry.value!, 'savenest_bills');
        
        if (result.url != null) {
          final String fieldName = _getFieldNameForType(entry.key);
          if (fieldName.isNotEmpty) {
            // Check if this field already exists (e.g. for Home & Car insurance sharing a field)
            final existingIndex = fields.indexWhere((f) => f['name'] == fieldName);
            
            if (existingIndex != -1) {
              // Append to existing value
              fields[existingIndex]['value'] = '${fields[existingIndex]['value']} ; ${result.url}';
            } else {
              // Add new field
              fields.add({'name': fieldName, 'value': result.url});
            }
          }
        } else {
          // Soft fail: Log error but don't stop submission
          final cleanError = result.error?.replaceAll(RegExp(r'[\r\n]'), ' ') ?? 'Unknown error';
          final shortError = cleanError.length > 100 ? '${cleanError.substring(0, 100)}...' : cleanError;
          uploadErrors.add('${entry.key.name} failed: $shortError');
        }
      }
    }

    try {
      final response = await http.post(
        submitUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fields': fields,
          'context': {
            'pageUri': 'www.savenest.app/registration',
            'pageName': 'Registration Screen',
          },
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': uploadErrors.isEmpty 
              ? 'Registration Successful!' 
              : 'Contact saved, but images failed: ${uploadErrors.join(", ")}',
        };
      } else {
        return {
          'success': false,
          'message': 'HubSpot Form Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error: $e',
      };
    }
  }

  String _getFieldNameForType(UtilityType type) {
    switch (type) {
      case UtilityType.nbn: return 'nbn_bill_url';
      case UtilityType.electricity: return 'electricity_bill_url';
      case UtilityType.gas: return 'gas_bill_url';
      case UtilityType.mobile: return 'mobile_bill_url';
      case UtilityType.homeInsurance: return 'home_insurance_bill_url';
      // Fallback: Map Car Insurance to Home Insurance field due to HubSpot property limits (max 10).
      // The submission logic now handles appending multiple URLs to the same field.
      case UtilityType.carInsurance: return 'home_insurance_bill_url'; 
      default: return '';
    }
  }
}
