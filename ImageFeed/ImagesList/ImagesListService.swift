import Foundation


final class ImagesListService {

    static let shared = ImagesListService()


    static let didChangeNotification =
    Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )


    private(set) var photos: [Photo] = []


    private var task: URLSessionTask?


    private var page: Int = 1


    private init() {}



    func fetchPhotosNextPage() {

        guard task == nil else {

            print(
                "[ImagesListService.fetchPhotosNextPage]: request already running"
            )

            return
        }


        guard let url = URL(
            string:
                "\(Constants.defaultBaseURLString)/photos?page=\(page)&per_page=10"
        )
        else {

            print(
                "[ImagesListService.fetchPhotosNextPage]: invalid URL"
            )

            return
        }


        var request = URLRequest(
            url: url
        )


        request.setValue(
            "Bearer \(OAuth2TokenStorage.shared.token ?? "")",
            forHTTPHeaderField: "Authorization"
        )



        task = URLSession.shared.objectTask(
            for: request
        ) { [weak self]
            (result: Result<[PhotoResult], Error>) in


            guard let self else {
                return
            }


            self.task = nil



            switch result {


            case .success(let photoResults):


                let newPhotos = photoResults.compactMap {
                    Photo(photoResult: $0)
                }



                DispatchQueue.main.async {


                    self.photos.append(
                        contentsOf: newPhotos
                    )


                    self.page += 1



                    NotificationCenter.default.post(
                        name:
                            ImagesListService.didChangeNotification,
                        object: nil
                    )

                }



            case .failure(let error):

                print(
                    "[ImagesListService.fetchPhotosNextPage]: \(error)"
                )
            }

        }

    }
    func updateLike(
        photoId: String,
        isLiked: Bool
    ) {

        guard let index = photos.firstIndex(where: {
            $0.id == photoId
        }) else {
            return
        }


        photos[index].isLiked = isLiked

    }
}
