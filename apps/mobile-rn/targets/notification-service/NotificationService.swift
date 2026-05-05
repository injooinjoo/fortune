//
//  NotificationService.swift
//  OndoNotificationService
//
//  iOS Notification Service Extension —
//  서버가 보낸 푸시 페이로드의 image URL 을 다운로드해서 로컬 임시 파일로
//  복사한 뒤 UNNotificationAttachment 로 첨부한다. 결과적으로 잠금화면 푸시
//  배너에 캐릭터 얼굴이 큰 썸네일로 노출된다.
//
//  서버 측 푸시 페이로드 구조 (supabase/functions/_shared/notification_push.ts):
//    - mutableContent: true
//    - richContent.image: "https://<supabase>/storage/.../character-avatars/<id>.webp"
//    - data.image: 같은 URL (Expo SDK 변경 대비 fallback)
//
//  Expo SDK 가 richContent.image 를 받으면 APNS payload 의 attachment hint
//  로 변환하지만, 정확한 키는 SDK 버전마다 미묘하게 다르다. 따라서 여러
//  후보 키를 순서대로 검사하는 식으로 robust 하게 처리한다.
//

import UserNotifications
import MobileCoreServices
import UniformTypeIdentifiers

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        let mutable = (request.content.mutableCopy() as? UNMutableNotificationContent)
        self.bestAttemptContent = mutable

        guard let bestAttempt = mutable else {
            // mutableCopy 가 실패하면(사실상 없음) 원본 그대로 전달.
            contentHandler(request.content)
            return
        }

        // 다양한 위치에서 image URL 후보를 찾는다.
        // 1) userInfo.body / userInfo.aps 에 직접 박힌 image
        // 2) Expo 가 변환한 attachment-url
        // 3) data 페이로드 (data.image)
        let imageUrlString = self.extractImageUrl(from: request.content.userInfo)

        guard let urlString = imageUrlString,
              let imageUrl = URL(string: urlString) else {
            contentHandler(bestAttempt)
            return
        }

        // 비동기 다운로드 — iOS 가 NSE 에 주는 시간은 약 30초. 그 안에 못 끝내면
        // serviceExtensionTimeWillExpire 가 fire 되어 첨부 없이 fallback.
        let task = URLSession.shared.downloadTask(with: imageUrl) { [weak self] (location, response, error) in
            guard let self = self,
                  let bestAttempt = self.bestAttemptContent,
                  let location = location,
                  error == nil else {
                self?.deliverBestAttempt()
                return
            }

            // 다운로드 결과는 임시 파일 → 시스템이 알아서 정리하는 attachments
            // 디렉토리로 옮긴다. 파일 확장자가 정확해야 iOS 가 typeHint 로
            // 디코딩 가능. URL path 의 확장자(.webp 등)를 그대로 살린다.
            let pathExt = imageUrl.pathExtension.isEmpty ? "jpg" : imageUrl.pathExtension
            let targetUrl = location.deletingLastPathComponent()
                .appendingPathComponent("\(UUID().uuidString).\(pathExt)")

            do {
                try FileManager.default.moveItem(at: location, to: targetUrl)
                let typeHint = self.utiTypeHint(for: pathExt)
                var options: [String: Any] = [:]
                if let typeHint = typeHint {
                    options[UNNotificationAttachmentOptionsTypeHintKey] = typeHint
                }
                let attachment = try UNNotificationAttachment(
                    identifier: "character-avatar",
                    url: targetUrl,
                    options: options
                )
                bestAttempt.attachments = [attachment]
            } catch {
                // 첨부 실패해도 텍스트 푸시는 살린다.
            }

            self.deliverBestAttempt()
        }
        task.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        // 시간 안에 다운로드 못 끝낸 경우. 텍스트만이라도 띄운다.
        deliverBestAttempt()
    }

    private func deliverBestAttempt() {
        guard let contentHandler = contentHandler,
              let bestAttempt = bestAttemptContent else { return }
        contentHandler(bestAttempt)
    }

    /// userInfo 트리에서 image URL 후보를 휴리스틱하게 뽑는다.
    /// Expo SDK 와 APNS 서버가 키 위치를 바꿔도 견디도록 여러 경로 검사.
    private func extractImageUrl(from userInfo: [AnyHashable: Any]) -> String? {
        // 1) APNS 표준 attachment-url (Expo SDK 가 richContent.image 를 변환)
        if let urlString = userInfo["attachment-url"] as? String {
            return urlString
        }
        // 2) data 페이로드 (서버가 명시적으로 박은 fallback)
        if let body = userInfo["body"] as? [String: Any],
           let urlString = body["image"] as? String {
            return urlString
        }
        if let urlString = userInfo["image"] as? String {
            return urlString
        }
        // 3) Expo 가 사용하는 또 다른 후보 키
        if let richContent = userInfo["richContent"] as? [String: Any],
           let urlString = richContent["image"] as? String {
            return urlString
        }
        return nil
    }

    /// 파일 확장자 → UTI 변환. iOS 14+ 는 UniformTypeIdentifiers, 이하는 MobileCoreServices.
    private func utiTypeHint(for pathExtension: String) -> String? {
        let ext = pathExtension.lowercased()
        if #available(iOS 14.0, *) {
            return UTType(filenameExtension: ext)?.identifier
        }
        let cfExt = ext as CFString
        guard let uti = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            cfExt,
            nil
        )?.takeRetainedValue() else {
            return nil
        }
        return uti as String
    }
}
