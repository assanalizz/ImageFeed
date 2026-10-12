import Foundation

enum ProfileImageServiceError: Error {
    case invalidURL
    case missingImageURL
}

final class ProfileImageService {

    static let shared = ProfileImageService()

    static let didChangeNotification =
        Notification.Name(
            "ProfileImageServiceDidChange"
        )

    private(set) var avatarURL: String?

    private var task: URLSessionTask?

    private init() {}

    func fetchProfileImageURL(
        username: String,
        completion: @escaping (
            Result<String, Error>
        ) -> Void
    ) {
        task?.cancel()

        guard var components = URLComponents(
            string: Constants.defaultBaseURLString
        ) else {
            print(
                "[ProfileImageService.fetchProfileImageURL]: InvalidURLComponents username=\(username)"
            )

            completion(
                .failure(
                    ProfileImageServiceError.invalidURL
                )
            )
            return
        }

        components.path =
            "/users/\(username)"

        guard let url = components.url else {
            print(
                "[ProfileImageService.fetchProfileImageURL]: InvalidURL username=\(username)"
            )

            completion(
                .failure(
                    ProfileImageServiceError.invalidURL
                )
            )
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        if let token =
            OAuth2TokenStorage.shared.token {

            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        let newTask = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (
            result: Result<UserResult, Error>
        ) in

            switch result {

            case .success(let userResult):

                guard let imageURL =
                        userResult.profileImage.large
                        ?? userResult.profileImage.medium
                        ?? userResult.profileImage.small else {

                    print(
                        "[ProfileImageService.fetchProfileImageURL]: MissingImageURL username=\(username)"
                    )

                    completion(
                        .failure(
                            ProfileImageServiceError
                                .missingImageURL
                        )
                    )

                    self?.task = nil
                    return
                }

                self?.avatarURL = imageURL

                NotificationCenter.default.post(
                    name: ProfileImageService
                        .didChangeNotification,
                    object: self
                )

                completion(.success(imageURL))

            case .failure(let error):

                print(
                    "[ProfileImageService.fetchProfileImageURL]: \(error) username=\(username)"
                )

                completion(.failure(error))
            }

            self?.task = nil
        }

        task = newTask
    }
}
