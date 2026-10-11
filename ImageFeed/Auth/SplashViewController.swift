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

        routeFromSplash()
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
        guard let token =
                OAuth2TokenStorage.shared.token else {

            showAuth()
            return
        }

        fetchProfile(token: token)
    }

    private func fetchProfile(token: String) {
        ProfileService.shared.fetchProfile(
            token: token
        ) { [weak self] result in

            switch result {

            case .success(let profile):

                self?.fetchProfileImage(
                    username: profile.username
                )

            case .failure(let error):

                print(
                    "[SplashViewController.fetchProfile]: \(error)"
                )

                OAuth2TokenStorage.shared.token = nil
                self?.showAuth()
            }
        }
    }

    private func fetchProfileImage(
        username: String
    ) {
        ProfileImageService.shared
            .fetchProfileImageURL(
                username: username
            ) { [weak self] result in

                switch result {

                case .success:
                    self?.showGallery()

                case .failure(let error):

                    print(
                        "[SplashViewController.fetchProfileImage]: \(error)"
                    )

                    // Профиль уже загрузился,
                    // поэтому даже при ошибке аватарки
                    // можем открыть приложение.
                    self?.showGallery()
                }
            }
    }

    private func showAuth() {
        guard let window = view.window else {
            print(
                "[SplashViewController.showAuth]: window is nil"
            )
            return
        }

        window.rootViewController =
            AuthViewController()

        window.makeKeyAndVisible()
    }

    private func showGallery() {
        let feedViewController =
            ImagesListViewController()

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let profileViewController =
                storyboard.instantiateViewController(
                    withIdentifier:
                        "ProfileViewController"
                ) as? ProfileViewController else {

            print(
                "[SplashViewController.showGallery]: ProfileViewController not found"
            )
            return
        }

        let tabBarController =
            ImageFeedTabBarController()

        tabBarController.viewControllers = [
            feedViewController,
            profileViewController
        ]

        tabBarController.selectedIndex = 0
        tabBarController.overrideUserInterfaceStyle =
            .dark

        guard let window = view.window else {
            print(
                "[SplashViewController.showGallery]: window is nil"
            )
            return
        }

        window.rootViewController =
            tabBarController

        window.makeKeyAndVisible()
    }
}
