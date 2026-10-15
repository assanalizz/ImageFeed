import UIKit

final class SceneDelegate:
    UIResponder,
    UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session:
            UISceneSession,
        options connectionOptions:
            UIScene.ConnectionOptions
    ) {
        guard let windowScene =
                scene as? UIWindowScene
        else {
            print(
                "[SceneDelegate]: UIWindowScene not found"
            )
            return
        }

        if ProcessInfo.processInfo.arguments
            .contains("-UITestResetAuth") {
            OAuth2TokenStorage.shared.token =
                nil
        }

        let window =
            UIWindow(
                windowScene: windowScene
            )

        window.rootViewController =
            SplashViewController()

        window.overrideUserInterfaceStyle =
            .dark

        window.makeKeyAndVisible()

        self.window = window
    }
}
