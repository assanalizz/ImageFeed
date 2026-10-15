import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )
}

final class WebViewViewController: UIViewController {

    weak var delegate: WebViewViewControllerDelegate?

    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()

        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.accessibilityIdentifier =
            "UnsplashWebView"

        return webView
    }()

    private let progressView =
        UIProgressView(
            progressViewStyle: .bar
        )

    private let backButton =
        UIButton(type: .system)

    private var progressObservation:
        NSKeyValueObservation?

    private var presenter:
        WebViewPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = WebViewPresenter(
            view: self
        )

        setupUI()
        setupProgressObservation()

        presenter?.viewDidLoad()
    }

    deinit {
        progressObservation?.invalidate()
    }

    private func setupUI() {
        view.backgroundColor = .white

        webView.translatesAutoresizingMaskIntoConstraints =
            false

        webView.navigationDelegate = self

        progressView.translatesAutoresizingMaskIntoConstraints =
            false

        progressView.progressTintColor =
            .systemBlue

        progressView.trackTintColor =
            .clear

        backButton.translatesAutoresizingMaskIntoConstraints =
            false

        backButton.setImage(
            UIImage(
                systemName: "chevron.backward"
            ),
            for: .normal
        )

        backButton.tintColor = .black

        backButton.accessibilityIdentifier =
            "WebViewBackButton"

        backButton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )

        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            webView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            webView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            webView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            progressView.topAnchor.constraint(
                equalTo:
                    view.safeAreaLayoutGuide.topAnchor
            ),

            progressView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            progressView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            backButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 8
            ),

            backButton.topAnchor.constraint(
                equalTo:
                    view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),

            backButton.widthAnchor.constraint(
                equalToConstant: 44
            ),

            backButton.heightAnchor.constraint(
                equalToConstant: 44
            )
        ])
    }

    private func setupProgressObservation() {
        progressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [weak self] webView, _ in

            guard let self else {
                return
            }

            DispatchQueue.main.async {
                self.presenter?
                    .didUpdateProgressValue(
                        webView.estimatedProgress
                    )
            }
        }
    }

    @objc
    private func didTapBackButton() {
        dismiss(animated: true)
    }
}

extension WebViewViewController:
    WebViewViewControllerProtocol {

    func load(
        request: URLRequest
    ) {
        webView.load(request)
    }

    func setProgressValue(
        _ newValue: Float
    ) {
        progressView.progress = newValue
    }

    func setProgressHidden(
        _ isHidden: Bool
    ) {
        progressView.isHidden = isHidden
    }
}

extension WebViewViewController:
    WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction:
            WKNavigationAction,
        decisionHandler:
            @escaping (WKNavigationActionPolicy) -> Void
    ) {

        guard let code =
                presenter?.code(
                    from: navigationAction
                ) else {

            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)

        delegate?.webViewViewController(
            self,
            didAuthenticateWithCode: code
        )
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation?,
        withError error: Error
    ) {
        print(
            "[WebViewViewController.didFail]: \(error.localizedDescription)"
        )
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation
            navigation: WKNavigation?,
        withError error: Error
    ) {
        print(
            "[WebViewViewController.didFailProvisionalNavigation]: \(error.localizedDescription)"
        )
    }
}
