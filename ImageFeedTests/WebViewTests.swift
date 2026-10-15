import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {

    func testPresenterCallsLoadRequest() {
        let view = WebViewViewControllerSpy()

        guard let url = URL(
            string: "https://example.com"
        ) else {
            XCTFail("Could not create test URL")
            return
        }

        let request = URLRequest(
            url: url
        )

        let authHelper = AuthHelperStub(
            request: request
        )

        let presenter = WebViewPresenter(
            view: view,
            authHelper: authHelper
        )

        presenter.viewDidLoad()

        XCTAssertTrue(view.loadRequestCalled)

        XCTAssertEqual(
            view.loadedRequest?.url,
            request.url
        )
    }

    func testProgressHiddenWhenOne() {
        let view = WebViewViewControllerSpy()
        let authHelper = AuthHelperStub()

        let presenter = WebViewPresenter(
            view: view,
            authHelper: authHelper
        )

        let result = presenter.shouldHideProgress(
            for: 1.0
        )

        XCTAssertTrue(result)
    }

    func testCodeFromURL() {
        let authHelper = AuthHelper()

        var components = URLComponents(
            string: "imagefeed://oauth/callback"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "code",
                value: "test_code"
            )
        ]

        guard let url = components?.url else {
            XCTFail("Could not create test URL")
            return
        }

        let code = authHelper.code(
            from: url
        )

        XCTAssertEqual(
            code,
            "test_code"
        )
    }
}


private final class WebViewViewControllerSpy:
    WebViewViewControllerProtocol {

    var loadRequestCalled = false
    var loadedRequest: URLRequest?

    var progressValue: Float?
    var progressHidden: Bool?

    func load(
        request: URLRequest
    ) {
        loadRequestCalled = true
        loadedRequest = request
    }

    func setProgressValue(
        _ newValue: Float
    ) {
        progressValue = newValue
    }

    func setProgressHidden(
        _ isHidden: Bool
    ) {
        progressHidden = isHidden
    }
}


private final class AuthHelperStub:
    AuthHelperProtocol {

    private let request: URLRequest?

    init(
        request: URLRequest? = nil
    ) {
        self.request = request
    }

    func authRequest() -> URLRequest? {
        request
    }

    func authURL() -> URL? {
        request?.url
    }

    func code(
        from url: URL
    ) -> String? {
        URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )?
        .queryItems?
        .first(
            where: { $0.name == "code" }
        )?
        .value
    }
}
