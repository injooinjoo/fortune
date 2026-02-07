import Flutter
import UIKit
import ActivityKit
import WidgetKit
import Intents
import Vision
import CoreImage

@available(iOS 16.1, *)
public class NativePlatformPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.fortune.fortune/ios", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "com.fortune.fortune/ios/events", binaryMessenger: registrar.messenger())
        
        let instance = NativePlatformPlugin()
        instance.channel = channel
        instance.eventChannel = eventChannel
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "updateWidget":
            updateWidget(call: call, result: result)
        case "requestNotificationPermission":
            requestNotificationPermission(result: result)
        case "scheduleNotification":
            scheduleNotification(call: call, result: result)
        case "cancelNotification":
            cancelNotification(call: call, result: result)
        case "updateDynamicIsland":
            updateDynamicIsland(call: call, result: result)
        case "startLiveActivity":
            startLiveActivity(call: call, result: result)
        case "endLiveActivity":
            endLiveActivity(call: call, result: result)
        case "addSiriShortcut":
            addSiriShortcut(call: call, result: result)
        case "startScreenshotDetection":
            startScreenshotDetection(result: result)
        case "stopScreenshotDetection":
            stopScreenshotDetection(result: result)
        case "detectFace":
            detectFace(call: call, result: result)
        case "isFaceDetectionSupported":
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(result: @escaping FlutterResult) {
        // Initialize any required iOS components
        WidgetCenter.shared.reloadAllTimelines()
        result("iOS platform initialized")
    }
    
    private func updateWidget(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let widgetType = args["widgetType"] as? String,
              let data = args["data"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        // Store widget data in App Group container
        // AppGroupId는 Dart 코드(group.com.beyond.fortune)와 동일해야 함
        if let sharedDefaults = UserDefaults(suiteName: "group.com.beyond.fortune") {
            sharedDefaults.set(data, forKey: "widget_\(widgetType)")
            sharedDefaults.synchronize()
            
            // Reload the specific widget
            WidgetCenter.shared.reloadTimelines(ofKind: widgetType)
            result("Widget updated: \(widgetType)")
        } else {
            result(FlutterError(code: "APP_GROUP_ERROR", message: "Failed to access app group", details: nil))
        }
    }
    
    private func requestNotificationPermission(result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                result(FlutterError(code: "PERMISSION_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(granted)
            }
        }
    }
    
    private func scheduleNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let title = args["title"] as? String,
              let body = args["body"] as? String,
              let scheduledTime = args["scheduledTime"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if let payload = args["payload"] as? [String: Any] {
            content.userInfo = payload
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(scheduledTime - Int(Date().timeIntervalSince1970 * 1000)) / 1000,
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                result(FlutterError(code: "SCHEDULE_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result("Notification scheduled")
            }
        }
    }
    
    private func cancelNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        result("Notification cancelled")
    }
    
    @available(iOS 16.2, *)
    private func updateDynamicIsland(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let activityId = args["activityId"] as? String,
              let content = args["content"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        // Update Live Activity content
        Task {
            do {
                // Find the activity and update it
                for activity in Activity<FortuneActivityAttributes>.activities {
                    if activity.id == activityId {
                        let updatedState = FortuneActivityAttributes.ContentState(fortuneData: content)
                        await activity.update(using: updatedState)
                        result("Dynamic Island updated")
                        return
                    }
                }
                result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "Activity not found", details: nil))
            } catch {
                result(FlutterError(code: "UPDATE_ERROR", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    @available(iOS 16.2, *)
    private func startLiveActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let attributes = args["attributes"] as? [String: Any],
              let contentState = args["contentState"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        Task {
            do {
                let fortuneAttributes = FortuneActivityAttributes(fortuneType: attributes["fortuneType"] as? String ?? "daily")
                let initialState = FortuneActivityAttributes.ContentState(fortuneData: contentState)
                
                let activity = try Activity.request(
                    attributes: fortuneAttributes,
                    contentState: initialState,
                    pushType: .token
                )
                
                result(activity.id)
            } catch {
                result(FlutterError(code: "START_ERROR", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    @available(iOS 16.2, *)
    private func endLiveActivity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        Task {
            for activity in Activity<FortuneActivityAttributes>.activities {
                if activity.id == activityId {
                    await activity.end(dismissalPolicy: .immediate)
                    result("Live Activity ended")
                    return
                }
            }
            result(FlutterError(code: "ACTIVITY_NOT_FOUND", message: "Activity not found", details: nil))
        }
    }
    
    private func addSiriShortcut(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let shortcutId = args["shortcutId"] as? String,
              let title = args["title"] as? String,
              let phrase = args["phrase"] as? String,
              let userInfo = args["userInfo"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        // Create and donate Siri shortcut
        let activity = NSUserActivity(activityType: "com.fortune.fortune.\(shortcutId)")
        activity.title = title
        activity.userInfo = userInfo
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(shortcutId)
        activity.suggestedInvocationPhrase = phrase
        
        activity.becomeCurrent()
        result("Siri shortcut added")
    }
    
    private func startScreenshotDetection(result: @escaping FlutterResult) {
        // Register for screenshot notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
        result("Screenshot detection started")
    }
    
    private func stopScreenshotDetection(result: @escaping FlutterResult) {
        // Remove screenshot notification observer
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
        result("Screenshot detection stopped")
    }
    
    @objc private func userDidTakeScreenshot() {
        // Send event to Flutter
        eventSink?([
            "type": "screenshot_detected",
            "data": ["timestamp": Int(Date().timeIntervalSince1970 * 1000)]
        ])
    }

    // MARK: - Face Detection with Landmarks (Vision Framework)
    private func detectFace(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imageData = args["imageData"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Image data required", details: nil))
            return
        }

        guard let cgImage = createCGImage(from: imageData.data) else {
            result(FlutterError(code: "IMAGE_ERROR", message: "Failed to create image from data", details: nil))
            return
        }

        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)

        // Create face landmarks detection request (includes face detection + landmarks)
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest { request, error in
            if let error = error {
                DispatchQueue.main.async {
                    result(FlutterError(code: "DETECTION_ERROR", message: error.localizedDescription, details: nil))
                }
                return
            }

            guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty else {
                DispatchQueue.main.async {
                    result(nil) // No face detected
                }
                return
            }

            // Get the first (most prominent) face
            let face = observations[0]
            let boundingBox = face.boundingBox

            // Convert normalized coordinates to pixel coordinates
            // Vision uses bottom-left origin, Flutter uses top-left
            let x = boundingBox.origin.x * imageWidth
            let y = (1 - boundingBox.origin.y - boundingBox.height) * imageHeight
            let width = boundingBox.width * imageWidth
            let height = boundingBox.height * imageHeight

            // Extract face landmarks
            var landmarksData: [[String: Double]] = []

            if let landmarks = face.landmarks {
                // Helper function to extract points from a landmark region
                func extractPoints(from region: VNFaceLandmarkRegion2D?, into array: inout [[String: Double]]) {
                    guard let region = region else { return }
                    for i in 0..<region.pointCount {
                        let point = region.normalizedPoints[i]
                        // Convert normalized coordinates (0-1, bottom-left origin) to pixel coordinates (top-left origin)
                        // Points are relative to bounding box, need to transform to image coordinates
                        let pixelX = (boundingBox.origin.x + point.x * boundingBox.width) * imageWidth
                        let pixelY = (1 - (boundingBox.origin.y + point.y * boundingBox.height)) * imageHeight
                        array.append([
                            "x": Double(pixelX),
                            "y": Double(pixelY)
                        ])
                    }
                }

                // Extract all landmark regions in order
                extractPoints(from: landmarks.faceContour, into: &landmarksData)      // Face outline
                extractPoints(from: landmarks.leftEyebrow, into: &landmarksData)      // Left eyebrow
                extractPoints(from: landmarks.rightEyebrow, into: &landmarksData)     // Right eyebrow
                extractPoints(from: landmarks.leftEye, into: &landmarksData)          // Left eye
                extractPoints(from: landmarks.rightEye, into: &landmarksData)         // Right eye
                extractPoints(from: landmarks.nose, into: &landmarksData)             // Nose
                extractPoints(from: landmarks.noseCrest, into: &landmarksData)        // Nose bridge
                extractPoints(from: landmarks.outerLips, into: &landmarksData)        // Outer lips
                extractPoints(from: landmarks.innerLips, into: &landmarksData)        // Inner lips
            }

            let faceData: [String: Any] = [
                "detected": true,
                "confidence": Double(face.confidence),
                "boundingBox": [
                    "x": Double(x),
                    "y": Double(y),
                    "width": Double(width),
                    "height": Double(height)
                ],
                "landmarks": landmarksData,
                "faceCount": observations.count
            ]

            DispatchQueue.main.async {
                result(faceData)
            }
        }

        // Enable CPU-only mode for simulator support
        #if targetEnvironment(simulator)
        if #available(iOS 17.0, *) {
            let revision = VNDetectFaceLandmarksRequest.supportedRevisions.max() ?? VNDetectFaceLandmarksRequestRevision3
            faceLandmarksRequest.revision = revision
        }
        #endif

        // Create and execute the request handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([faceLandmarksRequest])
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "HANDLER_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    private func createCGImage(from data: Data) -> CGImage? {
        guard let dataProvider = CGDataProvider(data: data as CFData),
              let cgImage = CGImage(
                jpegDataProviderSource: dataProvider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
              ) else {
            // Try PNG if JPEG fails
            if let uiImage = UIImage(data: data) {
                return uiImage.cgImage
            }
            return nil
        }
        return cgImage
    }
}

// MARK: - FlutterStreamHandler
extension NativePlatformPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: - Live Activity Attributes
@available(iOS 16.2, *)
struct FortuneActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var fortuneData: [String: Any]
        
        enum CodingKeys: String, CodingKey {
            case fortuneData
        }
        
        init(fortuneData: [String: Any]) {
            self.fortuneData = fortuneData
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            fortuneData = [:]
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            // Encode fortuneData as needed
        }
    }
    
    var fortuneType: String
}