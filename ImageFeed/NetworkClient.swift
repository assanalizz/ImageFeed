import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case emptyData
}

extension URLSession {

    @discardableResult
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {

        let task = dataTask(with: request) { data, response, error in

            if let error {
                print(
                    "[data(for:)]: NetworkError \(error.localizedDescription)"
                )

                fulfillCompletionOnMainThread(
                    .failure(
                        NetworkError.urlRequestError(error)
                    ),
                    completion: completion
                )
                return
            }

            guard let httpResponse =
                    response as? HTTPURLResponse else {

                print(
                    "[data(for:)]: URLSessionError - invalid response"
                )

                fulfillCompletionOnMainThread(
                    .failure(
                        NetworkError.urlSessionError
                    ),
                    completion: completion
                )
                return
            }

            guard (200...299).contains(
                httpResponse.statusCode
            ) else {

                print(
                    "[data(for:)]: HTTPError - code \(httpResponse.statusCode)"
                )

                fulfillCompletionOnMainThread(
                    .failure(
                        NetworkError.httpStatusCode(
                            httpResponse.statusCode
                        )
                    ),
                    completion: completion
                )
                return
            }

            guard let data else {

                print(
                    "[data(for:)]: EmptyData"
                )

                fulfillCompletionOnMainThread(
                    .failure(
                        NetworkError.emptyData
                    ),
                    completion: completion
                )
                return
            }

            fulfillCompletionOnMainThread(
                .success(data),
                completion: completion
            )
        }

        task.resume()
        return task
    }

    @discardableResult
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {

        let task = data(
            for: request
        ) { result in

            switch result {

            case .success(let data):

                do {
                    let object = try JSONDecoder().decode(
                        T.self,
                        from: data
                    )

                    fulfillCompletionOnMainThread(
                        .success(object),
                        completion: completion
                    )

                } catch {

                    print(
                        "[objectTask(for:)]: DecodingError \(error)"
                    )

                    if let rawData = String(
                        data: data,
                        encoding: .utf8
                    ) {
                        print(
                            "[objectTask(for:)]: data = \(rawData)"
                        )
                    }

                    fulfillCompletionOnMainThread(
                        .failure(error),
                        completion: completion
                    )
                }

            case .failure(let error):

                print(
                    "[objectTask(for:)]: \(error)"
                )

                fulfillCompletionOnMainThread(
                    .failure(error),
                    completion: completion
                )
            }
        }

        return task
    }
}

private func fulfillCompletionOnMainThread<T>(
    _ result: Result<T, Error>,
    completion: @escaping (Result<T, Error>) -> Void
) {
    if Thread.isMainThread {
        completion(result)
    } else {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
