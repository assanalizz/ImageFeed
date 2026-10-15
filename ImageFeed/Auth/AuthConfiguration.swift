import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String

    let defaultBaseURLString: String
    let authURLString: String
    let tokenURLString: String

    static let standard = AuthConfiguration(
        accessKey: Constants.accessKey,
        secretKey: Constants.secretKey,
        redirectURI: Constants.redirectURI,
        accessScope: Constants.accessScope,
        defaultBaseURLString: Constants.defaultBaseURLString,
        authURLString: Constants.authorizeURLString,
        tokenURLString: Constants.tokenURLString
    )
}
