import Flutter
import UIKit
import BackgroundTasks
// Naver Login SDK is provided via SPM. Guard import so the app still builds
// even if the package hasn't been added to the project yet.
#if canImport(NaverThirdPartyLogin)
import NaverThirdPartyLogin
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  // Background Task Identifiers
  static let widgetRefreshTaskId = "com.beyond.fortune.refresh"
  static let widgetProcessingTaskId = "com.beyond.fortune.processing"
  // Shared FlutterEngine for Scene lifecycle support (iOS 13+)
  lazy var flutterEngine: FlutterEngine = {
    let engine = FlutterEngine(name: "main engine")
    engine.run()
    return engine
  }()

  #if canImport(NaverThirdPartyLogin)
  private var naverChannel: FlutterMethodChannel?
  private var naverPendingResult: FlutterResult?
  #endif

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Ensure engine is running and register plugins
    GeneratedPluginRegistrant.register(with: flutterEngine)
    
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

    // Register background tasks for widget refresh
    registerBackgroundTasks()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Background Tasks for Widget Refresh

  private func registerBackgroundTasks() {
    // Register app refresh task (short-running, for quick updates)
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: AppDelegate.widgetRefreshTaskId,
      using: nil
    ) { [weak self] task in
      self?.handleWidgetRefresh(task: task as! BGAppRefreshTask)
    }

    // Register processing task (long-running, for data fetch)
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: AppDelegate.widgetProcessingTaskId,
      using: nil
    ) { [weak self] task in
      self?.handleWidgetProcessing(task: task as! BGProcessingTask)
    }

    print("✅ [BGTask] Widget background tasks registered")
  }

  private func handleWidgetRefresh(task: BGAppRefreshTask) {
    print("🔄 [BGTask] Widget refresh started")

    // Schedule next refresh
    scheduleWidgetRefresh()

    // Create a task request to process widget data
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1

    let operation = BlockOperation {
      // Notify Flutter to refresh widget data
      self.notifyFlutterForWidgetRefresh()
    }

    task.expirationHandler = {
      queue.cancelAllOperations()
      print("⚠️ [BGTask] Widget refresh expired")
    }

    operation.completionBlock = {
      task.setTaskCompleted(success: !operation.isCancelled)
      print("✅ [BGTask] Widget refresh completed")
    }

    queue.addOperation(operation)
  }

  private func handleWidgetProcessing(task: BGProcessingTask) {
    print("🔄 [BGTask] Widget processing started")

    // Schedule next processing task
    scheduleWidgetProcessing()

    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1

    let operation = BlockOperation {
      // Fetch and save widget data
      self.fetchAndSaveWidgetData()
    }

    task.expirationHandler = {
      queue.cancelAllOperations()
      print("⚠️ [BGTask] Widget processing expired")
    }

    operation.completionBlock = {
      task.setTaskCompleted(success: !operation.isCancelled)
      print("✅ [BGTask] Widget processing completed")
    }

    queue.addOperation(operation)
  }

  /// Schedule widget refresh task (short-running)
  func scheduleWidgetRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: AppDelegate.widgetRefreshTaskId)
    // Schedule for early morning (between 1-6 AM)
    request.earliestBeginDate = getNextEarlyMorningDate()

    do {
      try BGTaskScheduler.shared.submit(request)
      print("✅ [BGTask] Widget refresh scheduled for: \(request.earliestBeginDate?.description ?? "nil")")
    } catch {
      print("❌ [BGTask] Failed to schedule widget refresh: \(error)")
    }
  }

  /// Schedule widget processing task (long-running)
  func scheduleWidgetProcessing() {
    let request = BGProcessingTaskRequest(identifier: AppDelegate.widgetProcessingTaskId)
    request.requiresNetworkConnectivity = true
    request.requiresExternalPower = false
    // Schedule for early morning (between 1-6 AM)
    request.earliestBeginDate = getNextEarlyMorningDate()

    do {
      try BGTaskScheduler.shared.submit(request)
      print("✅ [BGTask] Widget processing scheduled for: \(request.earliestBeginDate?.description ?? "nil")")
    } catch {
      print("❌ [BGTask] Failed to schedule widget processing: \(error)")
    }
  }

  /// Get next early morning date (1-6 AM)
  private func getNextEarlyMorningDate() -> Date {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current

    var components = calendar.dateComponents([.year, .month, .day], from: Date())
    components.hour = 3 // Target 3 AM
    components.minute = 0
    components.second = 0

    guard var targetDate = calendar.date(from: components) else {
      // Fallback: 1 hour from now
      return Date().addingTimeInterval(3600)
    }

    // If we're past 3 AM today, schedule for tomorrow
    if targetDate <= Date() {
      targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate) ?? targetDate
    }

    return targetDate
  }

  /// Notify Flutter to refresh widget data
  private func notifyFlutterForWidgetRefresh() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }

      let channel = FlutterMethodChannel(
        name: "com.beyond.fortune/widget_refresh",
        binaryMessenger: self.flutterEngine.binaryMessenger
      )

      channel.invokeMethod("refreshWidgetData", arguments: nil) { result in
        if let error = result as? FlutterError {
          print("❌ [BGTask] Flutter widget refresh failed: \(error.message ?? "Unknown")")
        } else {
          print("✅ [BGTask] Flutter widget refresh completed")
        }
      }
    }
  }

  /// Fetch widget data directly (fallback when Flutter is not available)
  private func fetchAndSaveWidgetData() {
    // Read saved widget data from App Group storage
    // This is a fallback - main data fetch happens via Flutter
    let appGroupId = "group.com.beyond.fortune"
    guard let userDefaults = UserDefaults(suiteName: appGroupId) else {
      print("❌ [BGTask] Failed to access App Group")
      return
    }

    // Check if data is already valid for today
    let validDate = userDefaults.string(forKey: "valid_date") ?? ""
    let todayStr = formatTodayString()

    if validDate == todayStr {
      print("ℹ️ [BGTask] Widget data already valid for today")
      // Reload widgets to ensure they show latest data
      reloadAllWidgets()
      return
    }

    // Data needs refresh - notify Flutter if possible
    notifyFlutterForWidgetRefresh()
  }

  private func formatTodayString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    return formatter.string(from: Date())
  }

  private func reloadAllWidgets() {
    if #available(iOS 14.0, *) {
      DispatchQueue.main.async {
        // Import WidgetKit is needed in the widget extension
        // For now, use method channel to trigger reload from Flutter
        print("ℹ️ [BGTask] Requesting widget reload via Flutter")
      }
    }
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
    // Use the shared FlutterEngine's binary messenger for Scene lifecycle support
    naverChannel = FlutterMethodChannel(
      name: "com.beyond.fortune/naver_auth",
      binaryMessenger: flutterEngine.binaryMessenger
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