import Flutter
import UIKit
// Naver Login SDK is provided via SPM. Guard import so the app still builds
// even if the package hasn't been added to the project yet.
#if canImport(NaverThirdPartyLogin)
import NaverThirdPartyLogin
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  #if canImport(NaverThirdPartyLogin)
  private var naverChannel: FlutterMethodChannel?
  private var naverPendingResult: FlutterResult?
  #endif
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register native Naver login handler when Naver SDK is available
    #if canImport(NaverThirdPartyLogin)
    setupNaverLogin()
    #endif
    
    // Register native platform plugin
    // TODO: Add NativePlatformPlugin.swift to Xcode project before uncommenting
    // if #available(iOS 16.1, *) {
    //   if let registrar = self.registrar(forPlugin: "NativePlatformPlugin") {
    //     NativePlatformPlugin.register(with: registrar)
    //   }
    // }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle OAuth callback URLs
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("=== iOS URL HANDLER ===")
    print("Received URL: \(url.absoluteString)")
    print("URL Scheme: \(url.scheme ?? "nil")")
    print("URL Host: \(url.host ?? "nil")")
    print("URL Path: \(url.path)")
    print("URL Query: \(url.query ?? "nil")")
    print("Source Application: \(options[.sourceApplication] ?? "nil")")
    print("====================")
    
    // Check if this is a Naver auth callback (handle both naver{CLIENT_ID} and legacy values)
    #if canImport(NaverThirdPartyLogin)
    if let scheme = url.scheme, scheme.hasPrefix("naver") {
      print("✅ Detected Naver auth callback")
      // Handle Naver OAuth URL
      NaverThirdPartyLoginConnection.getSharedInstance()?.receiveAccessToken(url)
      return true
    }
    #endif
    
    // Check if this is a Supabase auth callback
    if url.scheme == "io.supabase.flutter" {
      print("✅ Detected Supabase auth callback")
    }
    
    // Let Flutter handle the URL
    let handled = super.application(app, open: url, options: options)
    print("Flutter handled URL: \(handled)")
    return handled
  }
  
  // Handle universal links (for iOS 9+)
  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      if let url = userActivity.webpageURL {
        print("Received universal link: \(url.absoluteString)")
      }
    }
    
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
  
  // MARK: - Naver Login Methods
  #if canImport(NaverThirdPartyLogin)
  
  private func setupNaverLogin() {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    naverChannel = FlutterMethodChannel(
      name: "com.beyond.fortune/naver_auth",
      binaryMessenger: controller.binaryMessenger
    )
    
    naverChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleNaverMethod(call, result: result)
    }
  }
  
  private func handleNaverMethod(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    naverPendingResult = result
    
    switch call.method {
    case "initializeNaver":
      initializeNaver(result: result)
    case "loginWithNaver":
      loginWithNaver(result: result)
    case "logoutNaver":
      logoutNaver(result: result)
    case "getCurrentNaverToken":
      getCurrentNaverToken(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func initializeNaver(result: @escaping FlutterResult) {
    print("🟢 [NaverLogin] Initializing Naver SDK")
    
    let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    // Configure using values from Info.plist
    instance?.isNaverAppOauthEnable = true
    instance?.isInAppOauthEnable = true
    instance?.isOnlyPortraitSupportedInIphone()
    
    // Set the URL scheme, consumer key, consumer secret, and app name
    instance?.serviceUrlScheme = "naverQMEfy6U82j8nKG3HSE8y"
    instance?.consumerKey = "QMEfy6U82j8nKG3HSE8y"
    instance?.consumerSecret = "Hu5KdO9DxK"
    instance?.appName = "Fortune"
    
    // Check if already logged in
    if let accessToken = instance?.accessToken, !accessToken.isEmpty {
      print("✅ [NaverLogin] Already logged in with token")
      result([
        "success": true,
        "isLoggedIn": true,
        "accessToken": accessToken
      ])
    } else {
      print("✅ [NaverLogin] SDK ready, not logged in")
      result([
        "success": true,
        "isLoggedIn": false
      ])
    }
  }
  
  private func loginWithNaver(result: @escaping FlutterResult) {
    print("🟢 [NaverLogin] Starting Naver login")
    
    naverPendingResult = result
    
    DispatchQueue.main.async {
      let instance = NaverThirdPartyLoginConnection.getSharedInstance()
      instance?.delegate = self
      instance?.requestThirdPartyLogin()
    }
  }
  
  private func logoutNaver(result: @escaping FlutterResult) {
    print("🟢 [NaverLogin] Logging out from Naver")
    let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    instance?.requestDeleteToken()
    result(["success": true])
  }
  
  private func getCurrentNaverToken(result: @escaping FlutterResult) {
    let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    if let accessToken = instance?.accessToken, !accessToken.isEmpty {
      result([
        "success": true,
        "accessToken": accessToken,
        "refreshToken": instance?.refreshToken ?? "",
        "expiresAt": instance?.accessTokenExpireDate?.iso8601String() ?? ""
      ])
    } else {
      result([
        "success": false,
        "error": "No valid token"
      ])
    }
  }
  
  private func getUserProfile(accessToken: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let url = URL(string: "https://openapi.naver.com/v1/nid/me")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let data = data else {
        completion(.failure(NSError(domain: "NaverAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
        return
      }
      
      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let response = json["response"] as? [String: Any] {
          var profile: [String: Any] = [:]
          
          // Extract available fields
          if let id = response["id"] as? String { profile["id"] = id }
          if let nickname = response["nickname"] as? String { profile["nickname"] = nickname }
          if let name = response["name"] as? String { profile["name"] = name }
          if let email = response["email"] as? String { profile["email"] = email }
          if let profileImage = response["profile_image"] as? String { profile["profile_image"] = profileImage }
          if let age = response["age"] as? String { profile["age"] = age }
          if let gender = response["gender"] as? String { profile["gender"] = gender }
          if let birthday = response["birthday"] as? String { profile["birthday"] = birthday }
          if let birthyear = response["birthyear"] as? String { profile["birthyear"] = birthyear }
          if let mobile = response["mobile"] as? String { profile["mobile"] = mobile }
          
          completion(.success(profile))
        } else {
          completion(.failure(NSError(domain: "NaverAuth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
        }
      } catch {
        completion(.failure(error))
      }
    }.resume()
  }
  
  #endif
}

// MARK: - NaverThirdPartyLoginConnectionDelegate
#if canImport(NaverThirdPartyLogin)
extension AppDelegate: NaverThirdPartyLoginConnectionDelegate {
  func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
    print("✅ [NaverLogin] Login successful, getting user profile")
    
    let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    guard let accessToken = instance?.accessToken, !accessToken.isEmpty else {
      naverPendingResult?([
        "success": false,
        "error": "Failed to get access token"
      ])
      naverPendingResult = nil
      return
    }
    
    // Get user profile
    getUserProfile(accessToken: accessToken) { [weak self] profileResult in
      switch profileResult {
      case .success(let profile):
        self?.naverPendingResult?([
          "success": true,
          "accessToken": accessToken,
          "refreshToken": instance?.refreshToken ?? "",
          "expiresAt": instance?.accessTokenExpireDate?.iso8601String() ?? "",
          "profile": profile
        ])
      case .failure(let error):
        print("❌ [NaverLogin] Failed to get profile: \(error)")
        // Still return success with tokens even if profile fetch fails
        self?.naverPendingResult?([
          "success": true,
          "accessToken": accessToken,
          "refreshToken": instance?.refreshToken ?? "",
          "expiresAt": instance?.accessTokenExpireDate?.iso8601String() ?? "",
          "profile": [:]
        ])
      }
      self?.naverPendingResult = nil
    }
  }
  
  func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
    print("✅ [NaverLogin] Token refreshed successfully")
  }
  
  func oauth20ConnectionDidFinishDeleteToken() {
    print("✅ [NaverLogin] Logout successful")
  }
  
  func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
    print("❌ [NaverLogin] Login failed: \(error?.localizedDescription ?? "Unknown error")")
    naverPendingResult?([
      "success": false,
      "error": error?.localizedDescription ?? "Unknown error"
    ])
    naverPendingResult = nil
  }
}

extension Date {
  func iso8601String() -> String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: self)
  }
}
#endif