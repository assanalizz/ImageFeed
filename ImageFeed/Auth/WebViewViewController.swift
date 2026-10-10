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

        // Не сохраняем OAuth cookies между новыми WebView
        configuration.websiteDataStore = .nonPersistent()

        return WKWebView(
            frame: .zero,
            configuration: configuration
        )
    }()

    private let progressView =
        UIProgressView(progressViewStyle: .bar)

    private let backButton = UIButton(type: .system)

    private var progressObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupProgressObservation()
        loadAuthPage()
    }

    deinit {
        progressObservation?.invalidate()
    }

    private func setupUI() {
        view.backgroundColor = .white

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .clear

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(
            UIImage(systemName: "chevron.backward"),
            for: .normal
        )
        backButton.tintColor = .black
        backButton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )

        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            progressView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
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
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupProgressObservation() {
        progressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [weak self] webView, _ in

            DispatchQueue.main.async {
                self?.progressView.progress =
                    Float(webView.estimatedProgress)

                self?.progressView.isHidden =
                    webView.estimatedProgress >= 1
            }
        }
    }

    private func loadAuthPage() {
        guard var components = URLComponents(
            string: Constants.authorizeURLString
        ) else {
            print("WebViewViewController: URLComponents error")
            return
        }

        components.queryItems = [
            URLQueryItem(
                name: "client_id",
                value: Constants.accessKey
            ),
            URLQueryItem(
                name: "redirect_uri",
                value: Constants.redirectURI
            ),
            URLQueryItem(
                name: "response_type",
                value: "code"
            ),
            URLQueryItem(
                name: "scope",
                value: Constants.accessScope
                    .replacingOccurrences(of: "+", with: " ")
            )
        ]

        guard let url = components.url else {
            print("WebViewViewController: OAuth URL error")
            return
        }

        webView.load(URLRequest(url: url))
    }

    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
}

extension WebViewViewController: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            print("WebViewViewController: navigation URL is nil")
            decisionHandler(.cancel)
            return
        }

        guard url.absoluteString.hasPrefix(
            Constants.redirectURI
        ) else {
            decisionHandler(.allow)
            return
        }

        guard let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else {
            print("WebViewViewController: redirect parsing error")
            decisionHandler(.cancel)
            return
        }

        if let error = components.queryItems?
            .first(where: { $0.name == "error" })?
            .value {

            print("Unsplash authorization error: \(error)")
            decisionHandler(.cancel)
            return
        }

        guard let code = components.queryItems?
            .first(where: { $0.name == "code" })?
            .value else {

            print("WebViewViewController: authorization code missing")
            decisionHandler(.cancel)
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
            "WebView navigation error: \(error.localizedDescription)"
        )
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation?,
        withError error: Error
    ) {
        print(
            "WebView provisional error: \(error.localizedDescription)"
        )
    }
}
