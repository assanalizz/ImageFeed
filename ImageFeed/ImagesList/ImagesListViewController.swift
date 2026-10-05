import UIKit

final class ImagesListViewController: UIViewController {

    private struct PhotoItem {
        let name: String
        let size: CGSize
    }

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let photos: [PhotoItem] = [
        PhotoItem(name: "0", size: CGSize(width: 1200, height: 900)),
        PhotoItem(name: "1", size: CGSize(width: 1200, height: 930)),
        PhotoItem(name: "2", size: CGSize(width: 1200, height: 760)),
        PhotoItem(name: "3", size: CGSize(width: 1200, height: 1000)),
        PhotoItem(name: "4", size: CGSize(width: 1200, height: 820)),
        PhotoItem(name: "5", size: CGSize(width: 1200, height: 1100)),
        PhotoItem(name: "6", size: CGSize(width: 1200, height: 880)),
        PhotoItem(name: "7", size: CGSize(width: 1200, height: 1250)),
        PhotoItem(name: "8", size: CGSize(width: 1200, height: 800)),
        PhotoItem(name: "9", size: CGSize(width: 1200, height: 950)),
        PhotoItem(name: "10", size: CGSize(width: 1200, height: 1050)),
        PhotoItem(name: "11", size: CGSize(width: 1200, height: 900)),
        PhotoItem(name: "12", size: CGSize(width: 1200, height: 780)),
        PhotoItem(name: "13", size: CGSize(width: 1200, height: 1200)),
        PhotoItem(name: "14", size: CGSize(width: 1200, height: 850)),
        PhotoItem(name: "15", size: CGSize(width: 1200, height: 980)),
        PhotoItem(name: "16", size: CGSize(width: 1200, height: 740)),
        PhotoItem(name: "17", size: CGSize(width: 1200, height: 1120)),
        PhotoItem(name: "18", size: CGSize(width: 1200, height: 890)),
        PhotoItem(name: "19", size: CGSize(width: 1200, height: 1020))
    ]

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupUI() {
        view.backgroundColor = .imageFeedBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(
            top: 8,
            left: 0,
            bottom: 4,
            right: 0
        )

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.reuseIdentifier
        )

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }
}

extension ImagesListViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        photos.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }

        let item = photos[indexPath.row]

        let image = UIImage(named: item.name)
            ?? UIImage(systemName: "photo")
            ?? UIImage()

        cell.configure(
            image: image,
            dateText: dateFormatter.string(from: Date()),
            isLiked: indexPath.row.isMultiple(of: 2)
        )

        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        let photoSize = photos[indexPath.row].size

        let horizontalInsets: CGFloat = 32
        let verticalSpacing: CGFloat = 4

        let imageWidth =
            tableView.bounds.width - horizontalInsets

        let scale =
            imageWidth / photoSize.width

        return photoSize.height * scale + verticalSpacing
    }
}

extension UIColor {

    static let imageFeedBackground = UIColor(
        red: 26.0 / 255.0,
        green: 27.0 / 255.0,
        blue: 34.0 / 255.0,
        alpha: 1.0
    )
}
