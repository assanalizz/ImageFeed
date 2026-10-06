import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var bioLabel: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func configureAppearance() {
        view.backgroundColor = .imageFeedBackground

        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image = UIImage(named: "ProfileAvatar")

        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white

        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        usernameLabel.textColor = UIColor.white.withAlphaComponent(0.5)

        bioLabel.text = "Hello, world!"
        bioLabel.font = .systemFont(ofSize: 13, weight: .regular)
        bioLabel.textColor = .white

        let logoutImage = UIImage(named: "LogoutIcon")?
            .withRenderingMode(.alwaysOriginal)

        logoutButton.configuration = nil
        logoutButton.setImage(logoutImage, for: .normal)
        logoutButton.backgroundColor = .clear
        logoutButton.tintColor = .clear
        logoutButton.imageView?.contentMode = .scaleAspectFit
        logoutButton.adjustsImageWhenHighlighted = false
    }
}
