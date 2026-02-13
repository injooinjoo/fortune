//
//  ScreenshotUITests.swift
//  RunnerUITests
//
//  ZPZG App Store Screenshots
//  "운세" 제거된 새 스크린샷 촬영용
//

import XCTest

class ScreenshotUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testTakeScreenshots() throws {
        // 앱 시작 대기
        sleep(3)

        // 1. 메인 홈 화면 (채팅 인터페이스)
        snapshot("01_Home_Chat", waitForLoadingIndicator: true)

        // 2. 기능 목록 화면 - 스크롤 다운하여 칩들 보이게
        let chatInput = app.textFields.firstMatch
        if chatInput.exists {
            chatInput.tap()
            sleep(1)
        }
        snapshot("02_Feature_List", waitForLoadingIndicator: true)

        // 3. Face AI 기능 진입
        let faceAIButton = app.buttons["AI 관상"].firstMatch
        if faceAIButton.exists {
            faceAIButton.tap()
            sleep(2)
            snapshot("03_Face_AI", waitForLoadingIndicator: true)

            // 뒤로 가기
            let backButton = app.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
                sleep(1)
            }
        }

        // 4. 타로/인사이트 카드
        let tarotButton = app.buttons["타로"].firstMatch
        if tarotButton.exists {
            tarotButton.tap()
            sleep(2)
            snapshot("04_Insight_Cards", waitForLoadingIndicator: true)

            let backButton = app.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
                sleep(1)
            }
        }

        // 5. 바이오리듬
        let bioButton = app.buttons["바이오리듬"].firstMatch
        if bioButton.exists {
            bioButton.tap()
            sleep(2)
            snapshot("05_Biorhythm", waitForLoadingIndicator: true)

            let backButton = app.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
                sleep(1)
            }
        }

        // 6. 프로필 화면
        let profileTab = app.tabBars.buttons.element(boundBy: 3)
        if profileTab.exists {
            profileTab.tap()
            sleep(2)
            snapshot("06_Profile", waitForLoadingIndicator: true)
        }

        // 7. MBTI 분석
        let homeTab = app.tabBars.buttons.element(boundBy: 0)
        if homeTab.exists {
            homeTab.tap()
            sleep(1)
        }

        let mbtiButton = app.buttons["MBTI 인사이트"].firstMatch
        if mbtiButton.exists {
            mbtiButton.tap()
            sleep(2)
            snapshot("07_MBTI_Analysis", waitForLoadingIndicator: true)

            let backButton = app.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
                sleep(1)
            }
        }

        // 8. 호흡 명상
        let breathButton = app.buttons["호흡 명상"].firstMatch
        if !breathButton.exists {
            // 스크롤해서 찾기
            app.swipeUp()
            sleep(1)
        }

        if breathButton.exists {
            breathButton.tap()
            sleep(2)
            snapshot("08_Breathing_Meditation", waitForLoadingIndicator: true)
        }
    }

    // 개별 스크린샷 테스트 (디버깅용)
    func testHomeScreen() throws {
        sleep(3)
        snapshot("Home_Main", waitForLoadingIndicator: true)
    }

    func testFeatureChips() throws {
        sleep(3)
        // 채팅 입력창 탭하여 칩 목록 표시
        let chatArea = app.otherElements.firstMatch
        chatArea.tap()
        sleep(2)
        snapshot("Feature_Chips", waitForLoadingIndicator: true)
    }
}
