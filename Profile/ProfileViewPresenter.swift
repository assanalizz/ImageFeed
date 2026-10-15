import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(
        name: String,
        loginName: String,
        bio: String
    )

    func updateAvatar(
        with url: URL?
    )
}

protocol ProfileViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func profileImageDidChange()
}

protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
}

protocol ProfileImageServiceProtocol: AnyObject {
    var avatarURL: String? { get }
}

extension ProfileService: ProfileServiceProtocol {}

extension ProfileImageService: ProfileImageServiceProtocol {}

final class ProfileViewPresenter:
    ProfileViewPresenterProtocol {

    private weak var view:
        ProfileViewControllerProtocol?

    private let profileService:
        ProfileServiceProtocol

    private let profileImageService:
        ProfileImageServiceProtocol

    init(
        view: ProfileViewControllerProtocol,
        profileService: ProfileServiceProtocol =
            ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol =
            ProfileImageService.shared
    ) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
    }

    func viewDidLoad() {
        updateProfileDetails()
        updateAvatar()
    }

    func profileImageDidChange() {
        updateAvatar()
    }

    private func updateProfileDetails() {
        guard let profile =
                profileService.profile else {
            return
        }

        view?.updateProfileDetails(
            name: profile.name,
            loginName: profile.loginName,
            bio: profile.bio
        )
    }

    private func updateAvatar() {
        guard let avatarURLString =
                profileImageService.avatarURL,
              let url =
                URL(string: avatarURLString)
        else {
            view?.updateAvatar(with: nil)
            return
        }

        view?.updateAvatar(with: url)
    }
}
