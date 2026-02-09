class CreditCardDeal {
  final String issuer;
  final String cardName;
  final String customerSegment;
  final String productTier;
  final String cardType;
  final String annualFee;
  final String purchaseApr;
  final String foreignTxFee;
  final String balanceTransferOffer;
  final String balanceTransferFee;
  final String signUpBonus;
  final String rewardsProgram;
  final String rewardsEarnRate;
  final bool travelInsurance;
  final bool loungeAccess;
  final String otherPerks;
  final String logoLink;
  final String interestFreeDays;
  final String minSpendForBonus;
  final String pointsCaps;
  final String digitalWalletSupport;
  final String otherFees;
  final String directPdsLink;

  CreditCardDeal({
    required this.issuer,
    required this.cardName,
    required this.customerSegment,
    required this.productTier,
    required this.cardType,
    required this.annualFee,
    required this.purchaseApr,
    required this.foreignTxFee,
    required this.balanceTransferOffer,
    required this.balanceTransferFee,
    required this.signUpBonus,
    required this.rewardsProgram,
    required this.rewardsEarnRate,
    required this.travelInsurance,
    required this.loungeAccess,
    required this.otherPerks,
    required this.logoLink,
    required this.interestFreeDays,
    required this.minSpendForBonus,
    required this.pointsCaps,
    required this.digitalWalletSupport,
    required this.otherFees,
    required this.directPdsLink,
  });

  factory CreditCardDeal.fromJson(Map<String, dynamic> json) {
    return CreditCardDeal(
      issuer: json['Issuer'] ?? '',
      cardName: json['Card Name'] ?? '',
      customerSegment: json['Customer Segment'] ?? '',
      productTier: json['Product Tier'] ?? '',
      cardType: json['Card Type'] ?? '',
      annualFee: json['Annual Fee'] ?? '',
      purchaseApr: json['Purchase APR'] ?? '',
      foreignTxFee: json['Foreign TX Fee'] ?? '',
      balanceTransferOffer: json['Balance Transfer Offer'] ?? '',
      balanceTransferFee: json['Balance Transfer Fee'] ?? '',
      signUpBonus: json['Sign-up Bonus / Promo'] ?? '',
      rewardsProgram: json['Rewards Program'] ?? '',
      rewardsEarnRate: json['Rewards Earn Rate'] ?? '',
      travelInsurance: (json['Travel Insurance'] ?? '') == '✔',
      loungeAccess: (json['Lounge Access'] ?? '') == '✔',
      otherPerks: json['Other Perks'] ?? '',
      logoLink: json['Logo Link'] ?? '',
      interestFreeDays: json['Interest-free days'] ?? '',
      minSpendForBonus: json['Minimum spend for bonus'] ?? '',
      pointsCaps: json['Points caps'] ?? '',
      digitalWalletSupport: json['Contactless & digital wallet support'] ?? '',
      otherFees: json['Fees (late, overlimit, additional cards)'] ?? '',
      directPdsLink: json['Direct PDS links'] ?? '',
    );
  }
}
