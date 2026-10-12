import Foundation

enum ProfileServiceError: Error {
    case invalidURL
}

final class ProfileService {

    static let shared = ProfileService()

    private(set) var profile: Profile?

    private var task: URLSessionTask?

    private init() {}

    func fetchProfile(
        token: String,
        completion: @escaping (
            Result<Profile, Error>
        ) -> Void
    ) {
        task?.cancel()

        guard let url = URL(
            string: "\(Constants.defaultBaseURLString)/me"
        ) else {
            print(
                "[ProfileService.fetchProfile]: InvalidURL"
            )

            completion(
                .failure(ProfileServiceError.invalidURL)
            )
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        let newTask = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (
            result: Result<ProfileResult, Error>
        ) in

            switch result {

            case .success(let profileResult):
                let profile = Profile(
                    from: profileResult
                )

                self?.profile = profile

                completion(.success(profile))

            case .failure(let error):
                print(
                    "[ProfileService.fetchProfile]: \(error)"
                )

                completion(.failure(error))
            }

            self?.task = nil
        }

        task = newTask
    }
}
