import UIKit

final class AuthViewController: UIViewController {

    private let logoImageView = UIImageView()
    private let loginButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupUI() {
        view.backgroundColor = .imageFeedBackground

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "LaunchLogo")
        logoImageView.contentMode = .scaleAspectFit

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle("Войти", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )
        loginButton.backgroundColor = .white
        loginButton.layer.cornerRadius = 16
        loginButton.accessibilityIdentifier = "Authenticate"

        loginButton.addTarget(
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside
        )

        view.addSubview(logoImageView)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            logoImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -55
            ),
            logoImageView.widthAnchor.constraint(
                equalToConstant: 100
            ),
            logoImageView.heightAnchor.constraint(
                equalToConstant: 100
            ),
            loginButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            loginButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            loginButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),
            loginButton.heightAnchor.constraint(
                equalToConstant: 48
            )
        ])
    }

    @objc
    private func didTapLoginButton() {
        let webViewViewController =
            WebViewViewController()

        webViewViewController.delegate = self
        webViewViewController.modalPresentationStyle = .fullScreen

        present(
            webViewViewController,
            animated: true
        )
    }

    private func showAuthError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Ок",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }

    private func switchToSplash() {
        guard let window = view.window else {
            print(
                "[AuthViewController.switchToSplash]: window is nil"
            )
            return
        }

        window.rootViewController =
            SplashViewController()

        window.makeKeyAndVisible()
    }
}

extension AuthViewController:
    WebViewViewControllerDelegate {

    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        vc.dismiss(
            animated: true
        ) { [weak self] in

            guard let self else {
                return
            }

            UIBlockingProgressHUD.show()

            OAuth2Service.shared.fetchAuthToken(
                code: code
            ) { [weak self] result in

                guard let self else {
                    UIBlockingProgressHUD.dismiss()
                    return
                }

                UIBlockingProgressHUD.dismiss()

                switch result {

                case .success(let token):
                    OAuth2TokenStorage.shared.token =
                        token

                    self.switchToSplash()

                case .failure(let error):
                    print(
                        "[AuthViewController.fetchAuthToken]: \(error)"
                    )

                    self.showAuthError()
                }
            }
        }
    }
}
