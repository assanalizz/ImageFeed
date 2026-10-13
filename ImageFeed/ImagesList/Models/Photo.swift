import Foundation

struct Photo {

    let id: String
    let size: CGSize
    let createdAt: Date?
    let imageURL: URL
    let fullImageURL: URL
    var isLiked: Bool


    private static let iso8601Formatter = ISO8601DateFormatter()


    init?(photoResult: PhotoResult) {

        guard let imageURL = URL(
            string: photoResult.urls.regular
        ),
        let fullImageURL = URL(
            string: photoResult.urls.full
        ) else {
            return nil
        }


        id = photoResult.id


        size = CGSize(
            width: photoResult.width,
            height: photoResult.height
        )


        if let createdAtString = photoResult.createdAt {
            createdAt = Photo.iso8601Formatter.date(
                from: createdAtString
            )
        } else {
            createdAt = nil
        }


        self.imageURL = imageURL
        self.fullImageURL = fullImageURL


        isLiked = photoResult.likedByUser
    }
}
