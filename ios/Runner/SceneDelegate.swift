import UIKit
import Flutter

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)

        // Get the shared FlutterEngine from AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let flutterEngine = appDelegate.flutterEngine

        // Create FlutterViewController with shared engine
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)

        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()

        // Handle any URLs that were passed during launch
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is released by the system
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene moves from inactive to active state
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene moves from active to inactive state
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called when the scene transitions from background to foreground
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when the scene transitions from foreground to background
    }

    // Handle URL opening via Scene lifecycle (iOS 13+)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            handleIncomingURL(context.url)
        }
    }

    private func handleIncomingURL(_ url: URL) {
        print("=== SceneDelegate URL Handler ===")
        print("Received URL: \(url.absoluteString)")

        // Forward URL to Flutter via AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        _ = appDelegate.application(UIApplication.shared, open: url, options: [:])
    }
}
