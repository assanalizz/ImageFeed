import UIKit

private final class DateGradientView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureGradient()
    }

    private func configureGradient() {
        guard let gradient = layer as? CAGradientLayer else { return }
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.58).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        isUserInteractionEnabled = false
    }
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        return imageView
    }()

    private let gradientView: DateGradientView = {
        let view = DateGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        photoImageView.addSubview(gradientView)
        photoImageView.addSubview(dateLabel)
        photoImageView.addSubview(likeButton)

        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),

            gradientView.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 74),

            dateLabel.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: -8),

            likeButton.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: -2),
            likeButton.topAnchor.constraint(equalTo: photoImageView.topAnchor, constant: 2),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func configure(image: UIImage, dateText: String, isLiked: Bool) {
        photoImageView.image = image
        dateLabel.text = dateText

        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let heart = UIImage(systemName: "heart.fill", withConfiguration: configuration)
        likeButton.setImage(heart, for: .normal)
        likeButton.tintColor = isLiked
            ? UIColor(red: 1.0, green: 0.25, blue: 0.32, alpha: 1.0)
            : UIColor.white.withAlphaComponent(0.72)
    }
}
