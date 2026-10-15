import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func fetchPhotosNextPage()
}

protocol ImagesListServiceProtocol: AnyObject {
    func fetchPhotosNextPage()
}

extension ImagesListService: ImagesListServiceProtocol {}

final class ImagesListViewPresenter:
    ImagesListViewPresenterProtocol {

    private let imagesListService:
        ImagesListServiceProtocol

    init(
        imagesListService: ImagesListServiceProtocol =
            ImagesListService.shared
    ) {
        self.imagesListService =
            imagesListService
    }

    func viewDidLoad() {
        fetchPhotosNextPage()
    }

    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
}
