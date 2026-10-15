import UIKit
import Kingfisher
import WebKit

final class ProfileViewController:
    UIViewController {

    @IBOutlet private weak var profileImageView:
        UIImageView!

    @IBOutlet private weak var nameLabel:
        UILabel!

    @IBOutlet private weak var usernameLabel:
        UILabel!

    @IBOutlet private weak var bioLabel:
        UILabel!

    @IBOutlet private weak var logoutButton:
        UIButton!

    private var presenter:
        ProfileViewPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        if presenter == nil {
            presenter = ProfileViewPresenter(
                view: self
            )
        }

        configureAppearance()
        setupActions()
        setupNotifications()

        presenter?.viewDidLoad()
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self
        )
    }

    override var preferredStatusBarStyle:
        UIStatusBarStyle {
        .lightContent
    }

    func configure(
        _ presenter: ProfileViewPresenterProtocol
    ) {
        self.presenter = presenter
    }

    private func configureAppearance() {
        view.backgroundColor =
            .imageFeedBackground

        profileImageView.layer.cornerRadius =
            35

        profileImageView.clipsToBounds =
            true

        profileImageView.contentMode =
            .scaleAspectFill

        profileImageView.accessibilityIdentifier =
            "ProfileImageView"

        nameLabel.font = .systemFont(
            ofSize: 23,
            weight: .bold
        )

        nameLabel.textColor = .white
        nameLabel.accessibilityIdentifier =
            "ProfileNameLabel"

        usernameLabel.font = .systemFont(
            ofSize: 13
        )

        usernameLabel.textColor =
            UIColor.white.withAlphaComponent(
                0.5
            )

        usernameLabel.accessibilityIdentifier =
            "ProfileUsernameLabel"

        bioLabel.font = .systemFont(
            ofSize: 13
        )

        bioLabel.textColor = .white
        bioLabel.accessibilityIdentifier =
            "ProfileBioLabel"

        let logoutImage = UIImage(
            systemName:
                "rectangle.portrait.and.arrow.right"
        )

        logoutButton.setImage(
            logoutImage,
            for: .normal
        )

        logoutButton.tintColor =
            .systemRed

        logoutButton.backgroundColor =
            .clear

        logoutButton.accessibilityIdentifier =
            "ProfileLogoutButton"
    }

    private func setupActions() {
        logoutButton.addTarget(
            self,
            action:
                #selector(logoutButtonTapped),
            for: .touchUpInside
        )
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector:
                #selector(profileImageDidChange),
            name:
                ProfileImageService
                    .didChangeNotification,
            object: nil
        )
    }

    @objc
    private func profileImageDidChange() {
        presenter?.profileImageDidChange()
    }

    @objc
    private func logoutButtonTapped() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message:
                "Уверены что хотите выйти?",
            preferredStyle: .alert
        )

        let yesAction = UIAlertAction(
            title: "Да",
            style: .destructive
        ) { [weak self] _ in

            OAuth2TokenStorage.shared.token =
                nil

            HTTPCookieStorage.shared
                .removeCookies(
                    since: .distantPast
                )

            let dataTypes =
                WKWebsiteDataStore
                    .allWebsiteDataTypes()

            WKWebsiteDataStore.default()
                .removeData(
                    ofTypes: dataTypes,
                    modifiedSince: .distantPast
                ) { [weak self] in

                    DispatchQueue.main.async {
                        guard let window =
                                self?.view.window
                        else {
                            return
                        }

                        window.rootViewController =
                            SplashViewController()

                        window.makeKeyAndVisible()
                    }
                }
        }

        let noAction = UIAlertAction(
            title: "Нет",
            style: .cancel
        )

        alert.addAction(yesAction)
        alert.addAction(noAction)

        present(
            alert,
            animated: true
        )
    }
}

extension ProfileViewController:
    ProfileViewControllerProtocol {

    func updateProfileDetails(
        name: String,
        loginName: String,
        bio: String
    ) {
        nameLabel.text = name
        usernameLabel.text = loginName
        bioLabel.text = bio
    }

    func updateAvatar(
        with url: URL?
    ) {
        let placeholder = UIImage(
            named: "ProfileAvatar"
        )

        guard let url else {
            profileImageView.image =
                placeholder
            return
        }

        let processor =
            RoundCornerImageProcessor(
                cornerRadius: 35
            )

        profileImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(processor),
                .cacheOriginalImage
            ]
        )
    }
}
