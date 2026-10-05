import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white

        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.75
        label.layer.shadowRadius = 2
        label.layer.shadowOffset = CGSize(width: 0, height: 1)

        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 0, height: 1)

        return button
    }()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        photoImageView.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(photoImageView)

        photoImageView.addSubview(dateLabel)
        photoImageView.addSubview(likeButton)

        NSLayoutConstraint.activate([

            photoImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),

            photoImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),

            photoImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 2
            ),

            photoImageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -2
            ),

            dateLabel.leadingAnchor.constraint(
                equalTo: photoImageView.leadingAnchor,
                constant: 8
            ),

            dateLabel.bottomAnchor.constraint(
                equalTo: photoImageView.bottomAnchor,
                constant: -8
            ),

            likeButton.trailingAnchor.constraint(
                equalTo: photoImageView.trailingAnchor,
                constant: -8
            ),

            likeButton.topAnchor.constraint(
                equalTo: photoImageView.topAnchor,
                constant: 8
            ),

            likeButton.widthAnchor.constraint(
                equalToConstant: 24
            ),

            likeButton.heightAnchor.constraint(
                equalToConstant: 24
            )
        ])
    }

    func configure(
        image: UIImage,
        dateText: String,
        isLiked: Bool
    ) {
        photoImageView.image = image
        dateLabel.text = dateText

        let configuration = UIImage.SymbolConfiguration(
            pointSize: 17,
            weight: .semibold
        )

        let heart = UIImage(
            systemName: "heart.fill",
            withConfiguration: configuration
        )

        likeButton.setImage(heart, for: .normal)

        likeButton.tintColor = isLiked
            ? UIColor(
                red: 1.0,
                green: 0.25,
                blue: 0.32,
                alpha: 1.0
            )
            : UIColor.white.withAlphaComponent(0.72)
    }
}
