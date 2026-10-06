import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let feedViewController = ImagesListViewController()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileViewController = storyboard.instantiateViewController(
            withIdentifier: "ProfileViewController"
        ) as? ProfileViewController else {
            return
        }

        let tabBarController = ImageFeedTabBarController()
        tabBarController.viewControllers = [feedViewController, profileViewController]
        tabBarController.selectedIndex = 0
        tabBarController.overrideUserInterfaceStyle = .dark

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.overrideUserInterfaceStyle = .dark
        window.makeKeyAndVisible()
        self.window = window
    }
}
