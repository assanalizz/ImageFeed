import Foundation

struct PhotoResult: Decodable {

    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case urls
    }
}
