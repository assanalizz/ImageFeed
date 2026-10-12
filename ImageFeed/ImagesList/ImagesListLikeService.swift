import Foundation

final class ImagesListLikeService {

    static let shared = ImagesListLikeService()

    private var task: URLSessionTask?

    private init() {}


    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {

        guard task == nil else {
            print(
                "[ImagesListLikeService.changeLike]: request already running"
            )
            return
        }

        guard let url = URL(
            string:
                "\(Constants.defaultBaseURLString)/photos/\(photoId)/like"
        ) else {

            print(
                "[ImagesListLikeService.changeLike]: invalid URL photoId=\(photoId)"
            )
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = isLike
            ? "POST"
            : "DELETE"

        request.setValue(
            "Bearer \(OAuth2TokenStorage.shared.token ?? "")",
            forHTTPHeaderField: "Authorization"
        )

        task = URLSession.shared.data(
            for: request
        ) { [weak self] result in

            self?.task = nil

            switch result {

            case .success:

                DispatchQueue.main.async {
                    completion(
                        .success(isLike)
                    )
                }

            case .failure(let error):

                print(
                    "[ImagesListLikeService.changeLike]: \(error)"
                )

                DispatchQueue.main.async {
                    completion(
                        .failure(error)
                    )
                }
            }
        }
    }
}
