import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../features/savings/savings_provider.dart';

class HubSpotService {
  // Credentials
  static const String _portalId = '442678262';
  static const String _formGuid = 'aed1b8bc-1b82-4f66-bcfd-7405bf0f6844';
  static const String _accessToken = String.fromEnvironment('HUBSPOT_ACCESS_TOKEN');
  
  // static const String _filesUrl = 'https://api.hubapi.com/files/v3/files';
  // Use local proxy to bypass CORS on Web
  static const String _filesUrl = 'http://localhost:8888';
  static const String _submitUrl = 'https://api.hsforms.com/submissions/v3/integration/submit';

  /// 1. Upload a single file to HubSpot and get the URL
  Future<String?> _uploadFile(XFile file, String folder) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_filesUrl));
      
      // Auth Header
      request.headers['Authorization'] = 'Bearer $_accessToken';

      // File Data
      final bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      ));

      // File Options (specify folder and visibility)
      request.fields['folderPath'] = folder; // e.g. "savenest_bills"
      request.fields['options'] = jsonEncode({
        "access": "PUBLIC_INDEXABLE" // So the form can see it easily
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url']; // The public URL of the uploaded file
      } else {
        print('File Upload Failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('File Upload Error: $e');
      return null;
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
        final String? uploadedUrl = await _uploadFile(entry.value!, 'savenest_bills');
        
        if (uploadedUrl != null) {
          final String fieldName = _getFieldNameForType(entry.key);
          if (fieldName.isNotEmpty) {
            fields.add({'name': fieldName, 'value': uploadedUrl});
          }
        } else {
          // Soft fail: Log error but don't stop submission
          uploadErrors.add('Failed to upload ${entry.key.name} image');
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
              : 'Contact saved, but some images failed to upload.',
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
      case UtilityType.carInsurance: return 'home_insurance_bill_url'; // Mapped to same field per request
      default: return '';
    }
  }
}