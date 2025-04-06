class Coupon {
  final String code;
  final double discount; // dalam persen

  Coupon({
    required this.code,
    required this.discount,
  });
}

// Daftar kupon yang tersedia
final List<Coupon> availableCoupons = [
  Coupon(code: 'maul', discount: 5.0),
  Coupon(code: 'naila', discount: 2.0),
  Coupon(code: 'amel', discount: 10.0),
];
