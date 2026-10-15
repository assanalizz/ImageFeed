import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"

    private let photoImageView = UIImageView()
    private let dateLabel = UILabel()
    private let likeButton = UIButton(type: .system)

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    var onLikeButtonTapped: (() -> Void)?

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    private func setupUI() {
        backgroundColor = .clear
        accessibilityIdentifier = "ImagesListCell"

        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 16
        photoImageView.accessibilityIdentifier = "FeedPhotoImage"

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .white
        dateLabel.font = .systemFont(ofSize: 13)

        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.accessibilityIdentifier = "LikeButton"

        likeButton.addTarget(
            self,
            action: #selector(likeButtonTapped),
            for: .touchUpInside
        )

        contentView.addSubview(photoImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4
            ),
            photoImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            photoImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            photoImageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -4
            ),
            likeButton.trailingAnchor.constraint(
                equalTo: photoImageView.trailingAnchor,
                constant: -12
            ),
            likeButton.topAnchor.constraint(
                equalTo: photoImageView.topAnchor,
                constant: 12
            ),
            dateLabel.leadingAnchor.constraint(
                equalTo: photoImageView.leadingAnchor,
                constant: 8
            ),
            dateLabel.bottomAnchor.constraint(
                equalTo: photoImageView.bottomAnchor,
                constant: -8
            )
        ])
    }

    func configure(
        photo: Photo
    ) {
        photoImageView.kf.setImage(
            with: photo.imageURL
        )

        if let date = photo.createdAt {
            dateLabel.text =
                Self.dateFormatter.string(
                    from: date
                )
        } else {
            dateLabel.text = ""
        }

        setIsLiked(
            photo.isLiked
        )
    }

    func setIsLiked(
        _ liked: Bool
    ) {
        let image = UIImage(
            systemName:
                liked
                ? "heart.fill"
                : "heart"
        )

        likeButton.setImage(
            image,
            for: .normal
        )

        likeButton.tintColor =
            liked
            ? .systemRed
            : .white

        likeButton.accessibilityValue =
            liked
            ? "liked"
            : "not liked"
    }

    @objc
    private func likeButtonTapped() {
        onLikeButtonTapped?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        photoImageView.image = nil
        onLikeButtonTapped = nil
    }
}
