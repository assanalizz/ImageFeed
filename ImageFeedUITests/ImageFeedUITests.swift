
import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAuth() throws {
        launchApp(resetAuth: true)

        try authenticate()

        let table = app.tables["ImagesListTableView"]

        XCTAssertTrue(
            table.waitForExistence(timeout: 15)
        )
    }

    func testFeed() throws {
        launchApp()

        try ensureAuthenticated()

        let table = app.tables["ImagesListTableView"]

        XCTAssertTrue(
            table.waitForExistence(timeout: 15)
        )

        XCTAssertTrue(
            table.cells.firstMatch.waitForExistence(timeout: 15)
        )

        let startPoint = table.coordinate(
            withNormalizedOffset: CGVector(
                dx: 0.04,
                dy: 0.78
            )
        )

        let endPoint = table.coordinate(
            withNormalizedOffset: CGVector(
                dx: 0.04,
                dy: 0.25
            )
        )

        startPoint.press(
            forDuration: 0.05,
            thenDragTo: endPoint
        )

        XCTAssertTrue(
            table.waitForExistence(timeout: 5)
        )

        XCTAssertTrue(
            table.isHittable,
            "Feed is no longer visible after scrolling"
        )

        let visibleCells = table.cells.allElementsBoundByIndex

        guard let cell = visibleCells.first(where: {
            $0.isHittable &&
            $0.buttons["LikeButton"].isHittable
        }) else {
            XCTFail("No visible photo cell with a like button")
            return
        }

        let likeButton = cell.buttons["LikeButton"]

        XCTAssertTrue(
            likeButton.waitForExistence(timeout: 5)
        )

        guard let originalValue = likeButton.value as? String,
              originalValue == "liked" ||
              originalValue == "not liked" else {
            XCTFail("Like button has an unexpected value")
            return
        }

        let changedValue = originalValue == "liked"
            ? "not liked"
            : "liked"

        likeButton.tap()

        waitForLikeValue(
            changedValue,
            button: likeButton
        )

        XCTAssertTrue(
            likeButton.waitForExistence(timeout: 5)
        )

        likeButton.tap()

        waitForLikeValue(
            originalValue,
            button: likeButton
        )

        cell.tap()

        let scrollView = app.scrollViews[
            "SingleImageScrollView"
        ]

        XCTAssertTrue(
            scrollView.waitForExistence(timeout: 15)
        )

        scrollView.pinch(
            withScale: 3,
            velocity: 1
        )

        scrollView.pinch(
            withScale: 0.5,
            velocity: -1
        )

        let backButton = app.buttons[
            "SingleImageBackButton"
        ]

        XCTAssertTrue(
            backButton.waitForExistence(timeout: 5)
        )

        backButton.tap()

        XCTAssertTrue(
            table.waitForExistence(timeout: 5)
        )
    }

    func testProfile() throws {
        launchApp()

        try ensureAuthenticated()

        let profileButton = app.buttons["ProfileTabButton"]

        XCTAssertTrue(
            profileButton.waitForExistence(timeout: 15)
        )

        profileButton.tap()

        let nameLabel = app.staticTexts["ProfileNameLabel"]
        let usernameLabel = app.staticTexts["ProfileUsernameLabel"]

        XCTAssertTrue(
            nameLabel.waitForExistence(timeout: 10)
        )

        XCTAssertTrue(
            usernameLabel.waitForExistence(timeout: 10)
        )

        XCTAssertFalse(
            nameLabel.label.isEmpty
        )

        XCTAssertTrue(
            usernameLabel.label.hasPrefix("@")
        )

        let logoutButton = app.buttons[
            "ProfileLogoutButton"
        ]

        XCTAssertTrue(
            logoutButton.waitForExistence(timeout: 5)
        )

        logoutButton.tap()

        let alert = app.alerts["Пока, пока!"]

        XCTAssertTrue(
            alert.waitForExistence(timeout: 5)
        )

        alert.buttons["Да"].tap()

        let authButton = app.buttons["Authenticate"]

        XCTAssertTrue(
            authButton.waitForExistence(timeout: 15)
        )
    }

    private func launchApp(resetAuth: Bool = false) {
        app.launchArguments = resetAuth
            ? ["-UITestResetAuth"]
            : []

        app.launch()
    }

    private func ensureAuthenticated() throws {
        let table = app.tables["ImagesListTableView"]

        if table.waitForExistence(timeout: 10) {
            return
        }

        let authButton = app.buttons["Authenticate"]

        if authButton.waitForExistence(timeout: 5) {
            try authenticate()
        }

        XCTAssertTrue(
            table.waitForExistence(timeout: 15)
        )
    }

    private func waitForLikeValue(
        _ expectedValue: String,
        button: XCUIElement
    ) {
        let predicate = NSPredicate(
            format: "value == %@",
            expectedValue
        )

        let expectation = XCTNSPredicateExpectation(
            predicate: predicate,
            object: button
        )

        let result = XCTWaiter.wait(
            for: [expectation],
            timeout: 20
        )

        XCTAssertEqual(
            result,
            .completed,
            "Like button did not update its state"
        )
    }

    private func authenticate() throws {
        let authButton = app.buttons["Authenticate"]

        XCTAssertTrue(
            authButton.waitForExistence(timeout: 10)
        )

        authButton.tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(
            webView.waitForExistence(timeout: 15)
        )

        guard let credentials = credentials() else {
            return
        }

        let loginTextField = webView.descendants(
            matching: .textField
        ).element

        XCTAssertTrue(
            loginTextField.waitForExistence(timeout: 15)
        )

        loginTextField.tap()
        loginTextField.typeText(credentials.username)

        let passwordTextField = webView.descendants(
            matching: .secureTextField
        ).element

        XCTAssertTrue(
            passwordTextField.waitForExistence(timeout: 10)
        )

        focusPasswordField(
            passwordTextField,
            in: webView
        )

        passwordTextField.typeText(credentials.password)

        let doneButton = app.buttons["Done"]

        if doneButton.exists && doneButton.isHittable {
            doneButton.tap()
        }

        let loginButton = webView.buttons["Login"]

        if loginButton.waitForExistence(timeout: 5)
            && loginButton.isHittable {
            loginButton.tap()
        } else {
            webView.swipeUp()

            let alternative = webView.buttons["Log in"]

            if alternative.waitForExistence(timeout: 5)
                && alternative.isHittable {
                alternative.tap()
            } else {
                XCTAssertTrue(
                    loginButton.isHittable,
                    "Login button is not accessible"
                )

                loginButton.tap()
            }
        }
    }

    private func focusPasswordField(
        _ passwordTextField: XCUIElement,
        in webView: XCUIElement
    ) {
        let keyboardNextButton = app.keyboards.buttons["Next"]

        if keyboardNextButton.exists
            && keyboardNextButton.isHittable {
            keyboardNextButton.tap()
            return
        }

        let nextButton = app.buttons["Next"]

        if nextButton.exists && nextButton.isHittable {
            nextButton.tap()
            return
        }

        let doneButton = app.buttons["Done"]

        if doneButton.exists && doneButton.isHittable {
            doneButton.tap()
        }

        webView.swipeUp()

        XCTAssertTrue(
            passwordTextField.isHittable,
            "Password field is not accessible"
        )

        passwordTextField.tap()
    }

    private func credentials() -> (
        username: String,
        password: String
    )? {
        let environment = ProcessInfo.processInfo.environment

        guard let username = environment["TEST_USERNAME"],
              !username.isEmpty,
              let password = environment["TEST_PASSWORD"],
              !password.isEmpty
        else {
            XCTFail(
                "TEST_USERNAME and TEST_PASSWORD are not configured"
            )
            return nil
        }

        return (
            username,
            password
        )
    }
}
