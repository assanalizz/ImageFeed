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
            selector: #selector(profileImageDidChange),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }



    deinit {
        NotificationCenter.default.removeObserver(self)
    }




    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }





    private func configureAppearance() {


        view.backgroundColor = .imageFeedBackground



        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill



        nameLabel.font = .systemFont(
            ofSize: 23,
            weight: .bold
        )

        nameLabel.textColor = .white



        usernameLabel.font = .systemFont(
            ofSize: 13
        )

        usernameLabel.textColor =
        UIColor.white.withAlphaComponent(0.5)



        bioLabel.font = .systemFont(
            ofSize: 13
        )

        bioLabel.textColor = .white



        // Кнопка выхода
        let logoutImage = UIImage(
            systemName: "rectangle.portrait.and.arrow.right"
        )

        logoutButton.setImage(
            logoutImage,
            for: .normal
        )

        logoutButton.tintColor = .systemRed

        logoutButton.backgroundColor = .clear
    }






    private func updateProfileDetails() {


        guard let profile =
                ProfileService.shared.profile
        else {

            print(
                "[ProfileViewController]: profile is nil"
            )

            return
        }



        nameLabel.text = profile.name

        usernameLabel.text =
            profile.loginName

        bioLabel.text =
            profile.bio
    }






    private func updateAvatar() {


        guard let avatarURLString =
                ProfileImageService.shared.avatarURL,

              let url =
                URL(string: avatarURLString)

        else {

            print(
                "[ProfileViewController]: avatarURL is nil"
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
                UIImage(
                    named: "ProfileAvatar"
                ),
            options: [
                .processor(processor),
                .cacheOriginalImage
            ]
        )
    }







    @objc
    private func profileImageDidChange() {

        updateAvatar()

    }







    @objc
    private func logoutButtonTapped() {



        let alert =
        UIAlertController(
            title:
                "Пока, пока!",
            message:
                "Уверены что хотите выйти?",
            preferredStyle:
                .alert
        )



        alert.addAction(
            UIAlertAction(
                title:
                    "Да",
                style:
                    .destructive
            )
            { [weak self] _ in



                OAuth2TokenStorage.shared.token = nil



                HTTPCookieStorage.shared.removeCookies(
                    since: .distantPast
                )



                let dataTypes =
                WKWebsiteDataStore
                    .allWebsiteDataTypes()



                WKWebsiteDataStore.default()
                    .removeData(
                        ofTypes: dataTypes,
                        modifiedSince: .distantPast
                    )
                {



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
        )




        alert.addAction(
            UIAlertAction(
                title:
                    "Нет",
                style:
                    .cancel
            )
        )



        present(
            alert,
            animated: true
        )
    }

}
