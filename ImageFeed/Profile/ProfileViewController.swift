import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {

    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var bioLabel: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAppearance()
        updateProfileDetails()
        updateAvatar()

        logoutButton.addTarget(
            self,
            action: #selector(logoutButtonTapped),
            for: .touchUpInside
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(
                profileImageDidChange
            ),
            name: ProfileImageService
                .didChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self
        )
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func configureAppearance() {
        view.backgroundColor =
            .imageFeedBackground

        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true

        profileImageView.contentMode =
            .scaleAspectFill

        nameLabel.font =
            .systemFont(
                ofSize: 23,
                weight: .bold
            )

        nameLabel.textColor = .white

        usernameLabel.font =
            .systemFont(ofSize: 13)

        usernameLabel.textColor =
            UIColor.white.withAlphaComponent(
                0.5
            )

        bioLabel.font =
            .systemFont(ofSize: 13)

        bioLabel.textColor = .white

        let logoutImage =
            UIImage(named: "LogoutIcon")?
                .withRenderingMode(
                    .alwaysOriginal
                )

        logoutButton.setImage(
            logoutImage,
            for: .normal
        )

        logoutButton.backgroundColor =
            .clear
    }

    private func updateProfileDetails() {
        guard let profile =
                ProfileService.shared.profile else {

            print(
                "[ProfileViewController.updateProfileDetails]: profile is nil"
            )
            return
        }

        nameLabel.text = profile.name
        usernameLabel.text =
            profile.loginName
        bioLabel.text = profile.bio
    }

    private func updateAvatar() {
        guard let avatarURLString =
                ProfileImageService.shared
                    .avatarURL,
              let url = URL(
                string: avatarURLString
              ) else {

            print(
                "[ProfileViewController.updateAvatar]: avatarURL is nil"
            )

            return
        }

        let processor =
            RoundCornerImageProcessor(
                cornerRadius: 35
            )

        profileImageView.kf.setImage(
            with: url,
            placeholder:
                UIImage(named: "ProfileAvatar"),
            options: [
                .processor(processor),
                .cacheOriginalImage
            ]
        )
    }

    @objc private func profileImageDidChange() {
        updateAvatar()
    }

    @objc private func logoutButtonTapped() {
        OAuth2TokenStorage.shared.token = nil

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
                            self?.view.window else {
                        return
                    }

                    window.rootViewController =
                        AuthViewController()

                    window.makeKeyAndVisible()
                }
            }
    }
}
