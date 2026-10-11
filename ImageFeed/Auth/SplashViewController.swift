import UIKit

final class SplashViewController: UIViewController {

    private let logoImageView = UIImageView()
    private var didRoute = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didRoute else { return }
        didRoute = true

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.35
        ) { [weak self] in
            self?.routeFromSplash()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupUI() {
        view.backgroundColor = .imageFeedBackground

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "LaunchLogo")
        logoImageView.contentMode = .scaleAspectFit

        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            logoImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            logoImageView.widthAnchor.constraint(
                equalToConstant: 100
            ),
            logoImageView.heightAnchor.constraint(
                equalToConstant: 100
            )
        ])
    }

    private func routeFromSplash() {
        if OAuth2TokenStorage.shared.token == nil {
            showAuth()
        } else {
            showGallery()
        }
    }

    private func showAuth() {
        guard let window = view.window else {
            print("SplashViewController: window is nil")
            return
        }

        let authViewController = AuthViewController()

        window.rootViewController = authViewController
        window.makeKeyAndVisible()
    }

    private func showGallery() {
        let feedViewController = ImagesListViewController()

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let profileViewController =
            storyboard.instantiateViewController(
                withIdentifier: "ProfileViewController"
            ) as? ProfileViewController else {

            print(
                "SplashViewController: ProfileViewController not found"
            )
            return
        }

        let tabBarController = ImageFeedTabBarController()

        tabBarController.viewControllers = [
            feedViewController,
            profileViewController
        ]

        tabBarController.selectedIndex = 0
        tabBarController.overrideUserInterfaceStyle = .dark

        guard let window = view.window else {
            print("SplashViewController: window is nil")
            return
        }

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
