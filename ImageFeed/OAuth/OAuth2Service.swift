import Foundation

enum OAuth2ServiceError: Error {
    case invalidURL
    case invalidRequestBody
}

final class OAuth2Service {

    static let shared = OAuth2Service()

    private var task: URLSessionTask?
    private var lastCode: String?
    private var activeRequestID: UUID?

    private init() {}

    func fetchAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Повторный запрос с тем же code не запускаем
        if lastCode == code, task != nil {
            print(
                "[OAuth2Service.fetchAuthToken]: duplicate code ignored"
            )
            return
        }

        // Если пришёл новый code — старый запрос отменяем
        task?.cancel()

        guard let url = URL(
            string: Constants.tokenURLString
        ) else {
            print(
                "[OAuth2Service.fetchAuthToken]: InvalidURL"
            )

            completeOnMain(
                .failure(OAuth2ServiceError.invalidURL),
                completion: completion
            )
            return
        }

        var components = URLComponents()

        components.queryItems = [
            URLQueryItem(
                name: "client_id",
                value: Constants.accessKey
            ),
            URLQueryItem(
                name: "client_secret",
                value: Constants.secretKey
            ),
            URLQueryItem(
                name: "redirect_uri",
                value: Constants.redirectURI
            ),
            URLQueryItem(
                name: "code",
                value: code
            ),
            URLQueryItem(
                name: "grant_type",
                value: "authorization_code"
            )
        ]

        guard let query = components.percentEncodedQuery,
              let body = query.data(using: .utf8) else {
            print(
                "[OAuth2Service.fetchAuthToken]: InvalidRequestBody"
            )

            completeOnMain(
                .failure(
                    OAuth2ServiceError.invalidRequestBody
                ),
                completion: completion
            )
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.httpBody = body

        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        let requestID = UUID()

        lastCode = code
        activeRequestID = requestID

        let newTask = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (
            result: Result<OAuthTokenResponseBody, Error>
        ) in
            guard let self else {
                return
            }

            // Результат старого отменённого запроса игнорируем
            guard self.activeRequestID == requestID else {
                return
            }

            self.task = nil
            self.lastCode = nil
            self.activeRequestID = nil

            switch result {

            case .success(let responseBody):
                completion(
                    .success(responseBody.accessToken)
                )

            case .failure(let error):
                print(
                    "[OAuth2Service.fetchAuthToken]: \(error)"
                )

                completion(.failure(error))
            }
        }

        task = newTask
    }

    private func completeOnMain(
        _ result: Result<String, Error>,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if Thread.isMainThread {
            completion(result)
        } else {
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
