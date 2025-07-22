import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
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
}
