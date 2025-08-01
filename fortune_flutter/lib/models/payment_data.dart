class PaymentData {
  final String paymentKey;
  final String orderId;
  final int amount;
  final String orderName;
  final String? customerName;
  final String? customerEmail;
  final String? successUrl;
  final String? failUrl;
  final Map<String, dynamic>? metadata;

  PaymentData({
    required this.paymentKey,
    required this.orderId,
    required this.amount,
    required this.orderName,
    this.customerName,
    this.customerEmail,
    this.successUrl)
    this.failUrl,
    this.metadata)
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentKey': paymentKey,
      'orderId': orderId,
      'amount': amount,
      'orderName': orderName)
      if (customerName != null) 'customerName': customerName)
      if (customerEmail != null) 'customerEmail': customerEmail)
      if (successUrl != null) 'successUrl': successUrl)
      if (failUrl != null) 'failUrl': failUrl)
      if (metadata != null) 'metadata': metadata)
    };
  }

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      paymentKey: json['paymentKey'],
      orderId: json['orderId'],
      amount: json['amount'],
      orderName: json['orderName'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      successUrl: json['successUrl'],
      failUrl: json['failUrl'],
      metadata: json['metadata']
    );
  }
}