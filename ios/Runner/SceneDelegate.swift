import UIKit
import Flutter

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private weak var flutterViewController: FlutterViewController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)

        // Get the shared FlutterEngine from AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let flutterEngine = appDelegate.flutterEngine

        // Create FlutterViewController with shared engine
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        self.flutterViewController = flutterViewController

        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()

        // Keep AppDelegate's window reference in sync so FlutterAppDelegate
        // can propagate lifecycle changes to the engine reliably.
        appDelegate.window = window

        // Handle any URLs that were passed during launch
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is released by the system
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        _ = appDelegate?.applicationDidBecomeActive?(UIApplication.shared)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        _ = appDelegate?.applicationWillResignActive?(UIApplication.shared)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        _ = appDelegate?.applicationWillEnterForeground?(UIApplication.shared)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        _ = appDelegate?.applicationDidEnterBackground?(UIApplication.shared)
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
