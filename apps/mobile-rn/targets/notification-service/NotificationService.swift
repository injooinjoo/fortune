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
import UniformTypeIdentifiers
import Intents

class NotificationService: UNNotificationServiceExtension {

    private let appGroupSuiteName = "group.com.beyond.fortune.widgets"
    private let badgeCountKey = "characterUnreadBadgeCount"
    private let lastNativeBadgeIncrementAtKey = "characterUnreadBadgeLastNativeIncrementAt"

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
        applyUnreadBadgeIncrementIfNeeded(to: bestAttempt)

        // 다양한 위치에서 image URL 후보를 찾는다.
        // 1) userInfo.body / userInfo.aps 에 직접 박힌 image
        // 2) Expo 가 변환한 attachment-url
        // 3) data 페이로드 (data.image)
        let imageUrlString = self.extractImageUrl(from: request.content.userInfo)

        guard let urlString = imageUrlString,
              let imageUrl = URL(string: urlString) else {
            let bundledAvatarData = self.attachBundledAvatarIfAvailable(to: bestAttempt)
            self.applyCommunicationMetadataAndDeliver(avatarData: bundledAvatarData)
            return
        }

        // 비동기 다운로드 — iOS 가 NSE 에 주는 시간은 약 30초. 그 안에 못 끝내면
        // serviceExtensionTimeWillExpire 가 fire 되어 첨부 없이 fallback.
        let task = URLSession.shared.downloadTask(with: imageUrl) { [weak self] (location, response, error) in
            guard let self = self,
                  let bestAttempt = self.bestAttemptContent,
                  let location = location,
                  error == nil else {
                let bundledAvatarData = self?.bestAttemptContent.flatMap { self?.attachBundledAvatarIfAvailable(to: $0) }
                self?.applyCommunicationMetadataAndDeliver(avatarData: bundledAvatarData)
                return
            }

            // 다운로드 결과는 임시 파일 → 시스템이 알아서 정리하는 attachments
            // 디렉토리로 옮긴다. 파일 확장자가 정확해야 iOS 가 typeHint 로
            // 디코딩 가능. URL path 의 확장자(.webp 등)를 그대로 살린다.
            let pathExt = imageUrl.pathExtension.isEmpty ? "jpg" : imageUrl.pathExtension
            let targetUrl = location.deletingLastPathComponent()
                .appendingPathComponent("\(UUID().uuidString).\(pathExt)")
            var avatarData: Data? = nil

            do {
                try FileManager.default.moveItem(at: location, to: targetUrl)
                avatarData = try? Data(contentsOf: targetUrl)
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
                // 첨부 실패해도 텍스트 푸시는 살린다. Communication Notification
                // 메타데이터는 extension bundle PNG fallback 으로 다시 시도한다.
                avatarData = nil
            }

            self.applyCommunicationMetadataAndDeliver(avatarData: avatarData ?? self.attachBundledAvatarIfAvailable(to: bestAttempt))
        }
        task.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        // 시간 안에 다운로드 못 끝낸 경우. 텍스트만이라도 띄우되, 가능한 경우
        // Communication Notification 메타데이터는 적용한다.
        applyCommunicationMetadataAndDeliver(avatarData: nil)
    }

    private func deliverBestAttempt() {
        guard let contentHandler = contentHandler,
              let bestAttempt = bestAttemptContent else { return }
        contentHandler(bestAttempt)
    }

    private func applyUnreadBadgeIncrementIfNeeded(to content: UNMutableNotificationContent) {
        let rawIncrement = extractString(from: content.userInfo, keys: ["badge_increment", "badgeIncrement"])
        let increment = Int(rawIncrement ?? "") ?? 0
        guard increment > 0 else { return }

        if let defaults = UserDefaults(suiteName: appGroupSuiteName) {
            let current = max(0, defaults.integer(forKey: badgeCountKey))
            let next = current + increment
            defaults.set(next, forKey: badgeCountKey)
            defaults.set(Date().timeIntervalSince1970, forKey: lastNativeBadgeIncrementAtKey)
            content.badge = NSNumber(value: next)
            return
        }

        // App Group entitlement 이 없는 구 빌드 fallback: 서버 badge 값은 최소 보존.
        let fallback = max(content.badge?.intValue ?? 0, increment)
        content.badge = NSNumber(value: fallback)
    }

    /// iOS 15+ Communication Notification 메타데이터를 적용한다.
    /// 카톡/iMessage처럼 알림을 "앱이 보낸 일반 푸시"가 아니라
    /// "캐릭터가 보낸 메시지"로 분류하게 만들어 발신자 avatar 표시 가능성을 높인다.
    ///
    /// 주의: 작은 앱 출처 아이콘 자체는 iOS 정책상 계속 앱 아이콘이다. 이 메타데이터는
    /// 시스템이 허용하는 발신자 이미지/메시지 UI 영역을 채우는 경로다.
    private func applyCommunicationMetadataAndDeliver(avatarData: Data?) {
        guard let contentHandler = contentHandler,
              let bestAttempt = bestAttemptContent else { return }

        guard #available(iOSApplicationExtension 15.0, *) else {
            contentHandler(bestAttempt)
            return
        }

        let updated = communicationUpdatedContent(from: bestAttempt, avatarData: avatarData)
        bestAttemptContent = updated
        contentHandler(updated)
    }

    @available(iOSApplicationExtension 15.0, *)
    private func communicationUpdatedContent(
        from content: UNMutableNotificationContent,
        avatarData: Data?
    ) -> UNMutableNotificationContent {
        let userInfo = content.userInfo
        let characterId = extractString(from: userInfo, keys: ["character_id", "characterId"])
            ?? "ondo-character"
        let displayName = extractString(from: userInfo, keys: ["title", "character_name", "characterName"])
            ?? content.title
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let body = extractString(from: userInfo, keys: ["body", "message", "messageText"])
            ?? content.body
        let conversationId = extractString(from: userInfo, keys: ["conversation_id", "conversationId", "route"])
            ?? characterId

        let senderImage = avatarData.flatMap { INImage(imageData: $0) }
        let sender = INPerson(
            personHandle: INPersonHandle(value: characterId, type: .unknown),
            nameComponents: nil,
            displayName: displayName.isEmpty ? content.title : displayName,
            image: senderImage,
            contactIdentifier: characterId,
            customIdentifier: characterId,
            isMe: false,
            suggestionType: .none
        )
        let me = INPerson(
            personHandle: INPersonHandle(value: "ondo-user", type: .unknown),
            nameComponents: nil,
            displayName: "나",
            image: nil,
            contactIdentifier: nil,
            customIdentifier: "ondo-user",
            isMe: true,
            suggestionType: .none
        )

        let intent = INSendMessageIntent(
            recipients: [me],
            outgoingMessageType: .outgoingMessageText,
            content: body,
            speakableGroupName: nil,
            conversationIdentifier: conversationId,
            serviceName: "온도",
            sender: sender,
            attachments: nil
        )
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.direction = .incoming
        interaction.donate(completion: nil)

        do {
            let updatedContent = try content.updating(from: intent)
            guard let mutable = updatedContent.mutableCopy() as? UNMutableNotificationContent else {
                return content
            }
            // updating(from:) 이 본문/제목을 시스템 메시지 스타일로 재작성할 수 있으므로
            // 기존 route/data 및 rich attachment 는 반드시 보존한다.
            mutable.userInfo = content.userInfo
            mutable.attachments = content.attachments
            mutable.sound = content.sound
            mutable.badge = content.badge
            mutable.categoryIdentifier = content.categoryIdentifier
            mutable.threadIdentifier = content.threadIdentifier.isEmpty ? characterId : content.threadIdentifier
            return mutable
        } catch {
            return content
        }
    }

    private func extractString(from userInfo: [AnyHashable: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = userInfo[key] as? String, !value.isEmpty {
                return value
            }
            if let body = userInfo["body"] as? [String: Any],
               let value = body[key] as? String,
               !value.isEmpty {
                return value
            }
            if let data = userInfo["data"] as? [String: Any],
               let value = data[key] as? String,
               !value.isEmpty {
                return value
            }
        }
        return nil
    }

    /// 서버 richContent.image 다운로드가 실패하거나 URL 이 없을 때도 캐릭터 얼굴이
    /// 뜨도록 extension bundle 에 포함한 PNG avatar 를 fallback 으로 사용한다.
    @discardableResult
    private func attachBundledAvatarIfAvailable(to content: UNMutableNotificationContent) -> Data? {
        let characterId = extractString(from: content.userInfo, keys: ["character_id", "characterId"])
        guard let characterId = characterId else { return nil }
        guard let bundledUrl = Bundle.main.url(
            forResource: characterId,
            withExtension: "png",
            subdirectory: "avatars"
        ) else { return nil }

        let avatarData = try? Data(contentsOf: bundledUrl)
        do {
            let tmpUrl = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(UUID().uuidString)-\(characterId).png")
            try FileManager.default.copyItem(at: bundledUrl, to: tmpUrl)
            let attachment = try UNNotificationAttachment(
                identifier: "character-avatar-bundled",
                url: tmpUrl,
                options: [UNNotificationAttachmentOptionsTypeHintKey: UTType.png.identifier]
            )
            if content.attachments.isEmpty {
                content.attachments = [attachment]
            }
        } catch {
            // Attachment fallback 실패 시에도 INPerson avatar data 는 사용할 수 있다.
        }
        return avatarData
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

    /// 파일 확장자 → UTI 변환. Notification Service Extension deployment target 이
    /// iOS 17 이므로 UniformTypeIdentifiers 만 사용한다.
    private func utiTypeHint(for pathExtension: String) -> String? {
        let ext = pathExtension.lowercased()
        return UTType(filenameExtension: ext)?.identifier
    }
}
