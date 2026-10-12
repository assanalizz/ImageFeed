import Foundation

struct Photo {

    let id: String
    let size: CGSize
    let createdAt: Date?
    let imageURL: URL
    let fullImageURL: URL
    var isLiked: Bool


    init(photoResult: PhotoResult) {

        id = photoResult.id

        size = CGSize(
            width: photoResult.width,
            height: photoResult.height
        )

        createdAt =
        ISO8601DateFormatter()
            .date(
                from: photoResult.createdAt ?? ""
            )


        imageURL =
        URL(
            string: photoResult.urls.regular
        )!


        fullImageURL =
        URL(
            string: photoResult.urls.full
        )!


        isLiked =
        photoResult.likedByUser
    }
}
