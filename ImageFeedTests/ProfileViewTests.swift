import XCTest
import UIKit
@testable import ImageFeed

final class ProfileViewTests:
    XCTestCase {

    func testProfileViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let viewController =
                storyboard.instantiateViewController(
                    withIdentifier:
                        "ProfileViewController"
                ) as? ProfileViewController
        else {
            XCTFail(
                "Could not create ProfileViewController"
            )
            return
        }

        let presenter =
            ProfileViewPresenterSpy()

        viewController.configure(
            presenter
        )

        viewController.loadViewIfNeeded()


        XCTAssertTrue(
            presenter.viewDidLoadCalled
        )
    }

    func testPresenterUpdatesProfileDetails() {
        let view =
            ProfileViewControllerSpy()

        let profile = Profile(
            username: "testuser",
            name: "Test User",
            loginName: "@testuser",
            bio: "Test bio"
        )

        let profileService =
            ProfileServiceStub(
                profile: profile
            )

        let imageService =
            ProfileImageServiceStub(
                avatarURL: nil
            )

        let presenter =
            ProfileViewPresenter(
                view: view,
                profileService:
                    profileService,
                profileImageService:
                    imageService
            )

        presenter.viewDidLoad()


        XCTAssertEqual(
            view.name,
            "Test User"
        )

        XCTAssertEqual(
            view.loginName,
            "@testuser"
        )

        XCTAssertEqual(
            view.bio,
            "Test bio"
        )
    }

    func testPresenterUpdatesAvatar() {
        let view =
            ProfileViewControllerSpy()

        let profileService =
            ProfileServiceStub(
                profile: nil
            )

        let imageService =
            ProfileImageServiceStub(
                avatarURL:
                    "https://example.com/avatar.jpg"
            )

        let presenter =
            ProfileViewPresenter(
                view: view,
                profileService:
                    profileService,
                profileImageService:
                    imageService
            )

        presenter.viewDidLoad()

        XCTAssertEqual(
            view.avatarURL?.absoluteString,
            "https://example.com/avatar.jpg"
        )
    }
}


private final class
ProfileViewPresenterSpy:
    ProfileViewPresenterProtocol {

    var viewDidLoadCalled = false
    var profileImageDidChangeCalled =
        false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func profileImageDidChange() {
        profileImageDidChangeCalled =
            true
    }
}


private final class
ProfileViewControllerSpy:
    ProfileViewControllerProtocol {

    var name: String?
    var loginName: String?
    var bio: String?
    var avatarURL: URL?

    func updateProfileDetails(
        name: String,
        loginName: String,
        bio: String
    ) {
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }

    func updateAvatar(
        with url: URL?
    ) {
        avatarURL = url
    }
}


private final class
ProfileServiceStub:
    ProfileServiceProtocol {

    let profile: Profile?

    init(
        profile: Profile?
    ) {
        self.profile = profile
    }
}

private final class
ProfileImageServiceStub:
    ProfileImageServiceProtocol {

    let avatarURL: String?

    init(
        avatarURL: String?
    ) {
        self.avatarURL = avatarURL
    }
}
