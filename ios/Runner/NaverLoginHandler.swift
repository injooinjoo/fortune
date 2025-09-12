import Foundation
import Flutter
import NidThirdPartyLogin
import NidCore

class NaverLoginHandler: NSObject {
    private var channel: FlutterMethodChannel?
    private var pendingResult: FlutterResult?
    
    override init() {
        super.init()
    }
    
    func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(
            name: "com.beyond.fortune/naver_auth",
            binaryMessenger: registrar.messenger()
        )
        
        guard let channel = channel else { return }
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        pendingResult = result
        
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
        print("🟢 [NaverLoginHandler] Initializing Naver SDK")
        
        // The SDK is already configured via Info.plist
        // Just check if we have a valid session
        if let accessToken = NidOAuth.shared.accessToken {
            print("✅ [NaverLoginHandler] Already logged in with token")
            result([
                "success": true,
                "isLoggedIn": true,
                "accessToken": accessToken.tokenString
            ])
        } else {
            print("✅ [NaverLoginHandler] SDK ready, not logged in")
            result([
                "success": true,
                "isLoggedIn": false
            ])
        }
    }
    
    private func loginWithNaver(result: @escaping FlutterResult) {
        print("🟢 [NaverLoginHandler] Starting Naver login")
        
        DispatchQueue.main.async {
            NidOAuth.shared.requestLogin { loginResult in
                switch loginResult {
                case .success(let authResult):
                    print("✅ [NaverLoginHandler] Login successful")
                    
                    // Get user profile
                    self.getUserProfile(accessToken: authResult.accessToken.tokenString) { profileResult in
                        switch profileResult {
                        case .success(let profile):
                            result([
                                "success": true,
                                "accessToken": authResult.accessToken.tokenString,
                                "refreshToken": authResult.refreshToken.tokenString,
                                "expiresAt": authResult.accessToken.expiresAt.iso8601String(),
                                "profile": profile
                            ])
                        case .failure(let error):
                            print("❌ [NaverLoginHandler] Failed to get profile: \(error)")
                            // Still return success with tokens even if profile fetch fails
                            result([
                                "success": true,
                                "accessToken": authResult.accessToken.tokenString,
                                "refreshToken": authResult.refreshToken.tokenString,
                                "expiresAt": authResult.accessToken.expiresAt.iso8601String(),
                                "profile": [:]
                            ])
                        }
                    }
                    
                case .failure(let error):
                    print("❌ [NaverLoginHandler] Login failed: \(error)")
                    result([
                        "success": false,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
    
    private func logoutNaver(result: @escaping FlutterResult) {
        print("🟢 [NaverLoginHandler] Logging out from Naver")
        NidOAuth.shared.logout()
        result(["success": true])
    }
    
    private func getCurrentNaverToken(result: @escaping FlutterResult) {
        if let accessToken = NidOAuth.shared.accessToken {
            result([
                "success": true,
                "accessToken": accessToken.tokenString,
                "refreshToken": NidOAuth.shared.refreshToken?.tokenString ?? "",
                "expiresAt": accessToken.expiresAt.iso8601String()
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
}

extension Date {
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}