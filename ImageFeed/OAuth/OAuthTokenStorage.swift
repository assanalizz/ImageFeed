import Foundation

final class OAuth2TokenStorage {

    static let shared = OAuth2TokenStorage()

    private let tokenKey = "bearerToken"

    private init() {}

    var token: String? {
        get {
            UserDefaults.standard.string(
                forKey: tokenKey
            )
        }

        set {
            if let newValue {
                UserDefaults.standard.set(
                    newValue,
                    forKey: tokenKey
                )
            } else {
                UserDefaults.standard.removeObject(
                    forKey: tokenKey
                )
            }
        }
    }
}
