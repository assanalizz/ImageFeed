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

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = feedViewController
        window.makeKeyAndVisible()

        self.window = window
    }
}
