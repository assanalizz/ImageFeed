import Foundation

enum OAuth2ServiceError: Error {
    case invalidURL
    case invalidRequestBody
    case network(Error)
    case invalidResponse
    case httpStatus(Int)
    case emptyData
    case decoding(Error)
}

final class OAuth2Service {
    static let shared = OAuth2Service()

    private var task: URLSessionDataTask?
    private var lastCode: String?

    private init() {}

    func fetchAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if lastCode == code, task != nil {
            print("OAuth2Service: duplicate authorization code request ignored")
            return
        }

        guard let url = URL(string: Constants.tokenURLString) else {
            print("OAuth2Service: failed to create token URL")
            complete(.failure(OAuth2ServiceError.invalidURL), completion: completion)
            return
        }

        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let body = bodyComponents.percentEncodedQuery?.data(using: .utf8) else {
            print("OAuth2Service: failed to create request body")
            complete(.failure(OAuth2ServiceError.invalidRequestBody), completion: completion)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = body

        lastCode = code
        task?.cancel()

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.task = nil
                self?.lastCode = nil
            }

            if let error {
                print("OAuth2Service network error: \(error.localizedDescription)")
                self?.complete(.failure(OAuth2ServiceError.network(error)), completion: completion)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("OAuth2Service: response is not HTTPURLResponse")
                self?.complete(.failure(OAuth2ServiceError.invalidResponse), completion: completion)
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                print("OAuth2Service: Unsplash returned HTTP \(httpResponse.statusCode)")
                if let data, let responseText = String(data: data, encoding: .utf8) {
                    print("OAuth2Service response: \(responseText)")
                }
                self?.complete(
                    .failure(OAuth2ServiceError.httpStatus(httpResponse.statusCode)),
                    completion: completion
                )
                return
            }

            guard let data else {
                print("OAuth2Service: response data is empty")
                self?.complete(.failure(OAuth2ServiceError.emptyData), completion: completion)
                return
            }

            do {
                let responseBody = try JSONDecoder().decode(
                    OAuthTokenResponseBody.self,
                    from: data
                )
                self?.complete(.success(responseBody.accessToken), completion: completion)
            } catch {
                print("OAuth2Service decoder error: \(error.localizedDescription)")
                self?.complete(.failure(OAuth2ServiceError.decoding(error)), completion: completion)
            }
        }

        self.task = task
        task.resume()
    }

    private func complete(
        _ result: Result<String, Error>,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
