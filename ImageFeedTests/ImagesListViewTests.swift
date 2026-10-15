import XCTest
@testable import ImageFeed

final class ImagesListViewTests:
    XCTestCase {

    func testImagesListViewControllerCallsViewDidLoad() {
        let viewController =
            ImagesListViewController()

        let presenter =
            ImagesListViewPresenterSpy()

        viewController.configure(
            presenter
        )

        viewController.loadViewIfNeeded()

        XCTAssertTrue(
            presenter.viewDidLoadCalled
        )
    }

    func testImagesListPresenterFetchesPhotos() {
        let service =
            ImagesListServiceSpy()

        let presenter =
            ImagesListViewPresenter(
                imagesListService:
                    service
            )

        presenter.viewDidLoad()


        XCTAssertTrue(
            service
                .fetchPhotosNextPageCalled
        )
    }

    func testImagesListPresenterFetchesNextPage() {
        let service =
            ImagesListServiceSpy()

        let presenter =
            ImagesListViewPresenter(
                imagesListService:
                    service
            )

        presenter.fetchPhotosNextPage()

        XCTAssertTrue(
            service
                .fetchPhotosNextPageCalled
        )
    }
}


private final class
ImagesListViewPresenterSpy:
    ImagesListViewPresenterProtocol {

    var viewDidLoadCalled =
        false

    var fetchPhotosNextPageCalled =
        false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled =
            true
    }
}


private final class
ImagesListServiceSpy:
    ImagesListServiceProtocol {

    var fetchPhotosNextPageCalled =
        false

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled =
            true
    }
}
