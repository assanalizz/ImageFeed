import Foundation
import WebKit

protocol WebViewViewControllerProtocol: AnyObject {
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func shouldHideProgress(for value: Float) -> Bool
    func code(from navigationAction: WKNavigationAction) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {

    private weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol

    init(
        view: WebViewViewControllerProtocol,
        authHelper: AuthHelperProtocol = AuthHelper()
    ) {
        self.view = view
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            return
        }

        view?.load(request: request)
    }

    func didUpdateProgressValue(
        _ newValue: Double
    ) {
        let progress = Float(newValue)

        view?.setProgressValue(progress)

        view?.setProgressHidden(
            shouldHideProgress(for: progress)
        )
    }

    func shouldHideProgress(
        for value: Float
    ) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func code(
        from navigationAction: WKNavigationAction
    ) -> String? {
        guard let url =
                navigationAction.request.url else {
            return nil
        }

        return authHelper.code(from: url)
    }
}
