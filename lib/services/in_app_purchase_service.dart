import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../core/constants/in_app_products.dart';
import '../core/network/api_client.dart';
import '../core/constants/edge_functions_endpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/providers/user_provider.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final _supabase = Supabase.instance.client;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final List<ProductDetails> _products = [];
  final Map<String, PurchaseDetails> _purchases = {};
  
  bool _isAvailable = false;
  bool _purchasePending = false;
  
  // Getters
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  List<ProductDetails> get products => _products;
  
  // Initialize the service
  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      debugPrint('In-App Purchase is not available');
      return;
    }
    
    // iOS specific setup
    if (!kIsWeb && Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(PaymentQueueDelegate();
    }
    
    // Load products
    await loadProducts();
    
    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _handlePurchaseUpdate),
        onDone: _onDone),
        onError: _onError)
  }
  
  // Load available products
  Future<void> loadProducts() async {
    if (!_isAvailable) return;
    
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
      InAppProducts.allProductIds.toSet())
    
    if (response.error != null) {
      debugPrint('products: ${response.error}');
      return;
    }
    
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('found: ${response.notFoundIDs}');
    }
    
    _products.clear();
    _products.addAll(response.productDetails);
    _products.sort((a, b) => a.price.compareTo(b.price);
  }
  
  // Purchase a product
  Future<bool> purchaseProduct(String productId) async {
    if (!_isAvailable || _purchasePending) return false;
    
    final ProductDetails? productDetails = _products.firstWhere(
      (product) => product.id == productId,
      orElse: () => throw Exception('),
      d: $productId'))
    
    if (productDetails == null) return false;
    
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails);
    
    try {
      _purchasePending = true;
      
      if (InAppProducts.consumableIds.contains(productId)) {
        return await _inAppPurchase.buyConsumable(
    purchaseParam: purchaseParam)} else {
        return await _inAppPurchase.buyNonConsumable(
    purchaseParam: purchaseParam)}
    } catch (e) {
      debugPrint('Supabase initialized with URL: $supabaseUrl');
      _purchasePending = false;
      return false;
    }
  }
  
  // Handle purchase updates
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('status: ${purchaseDetails.status}');
      
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          break;
          
        case PurchaseStatus.purchased:
          await _verifyAndDeliverProduct(purchaseDetails);
          _purchasePending = false;
          break;
        case PurchaseStatus.restored:
          await _handleRestoredPurchase(purchaseDetails);
          _purchasePending = false;
          break;
          
        case PurchaseStatus.error:
          _handleError(purchaseDetails.error!);
          _purchasePending = false;
          break;
          
        case PurchaseStatus.canceled:
          _purchasePending = false;
          break;
      }
      
      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }
  
  // Verify purchase and deliver product
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchaseDetails) async {
    // Store purchase for verification
    _purchases[purchaseDetails.productID] = purchaseDetails;
    
    try {
      // Verify purchase with backend
      final response = await _supabase.functions.invoke(
        EdgeFunctionsEndpoints.verifyPurchase),
        body: {
          'productId': purchaseDetails.productID)
          'purchaseToken': purchaseDetails.verificationData.serverVerificationData)
          'platform': kIsWeb ? 'web' : (!kIsWeb && Platform.isIOS ? 'ios' : 'android': null})
      
      if (response.data != null && response.data['success'] == true) {
        debugPrint('Purchase verified successfully');
      }
    } catch (e) {
      debugPrint('Supabase initialized with URL: $supabaseUrl');
    }
  }

  // Handle restored purchases
  Future<void> _handleRestoredPurchase(PurchaseDetails purchaseDetails) async {
    await _verifyAndDeliverProduct(purchaseDetails);
  }
  
  // Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Supabase initialized with URL: $supabaseUrl');
    }
  }
  
  // Check subscription status
  Future<bool> checkSubscriptionStatus() async {
    // Check with backend for current subscription status
    try {
      final response = await _supabase.functions.invoke(
        EdgeFunctionsEndpoints.subscriptionStatus),
        httpMethod: HttpMethod.get
      );
      return response.data != null && response.data['isSubscribed'] == true;
    } catch (e) {
      debugPrint('Supabase initialized with URL: $supabaseUrl');
      return false;
    }
  }
  
  // Handle errors
  void _handleError(IAPError error) {
    debugPrint('error: ${error.code} - ${error.message}');
  }
  
  void _onDone() {
    _subscription?.cancel();
  }
  
  void _onError(dynamic error) {
    debugPrint('Supabase initialized with URL: $supabaseUrl');
  }
  
  // Dispose
  void dispose() {
    _subscription?.cancel();
  }
}

// iOS Payment Queue Delegate
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront) {
    return true;
  }
  
  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}