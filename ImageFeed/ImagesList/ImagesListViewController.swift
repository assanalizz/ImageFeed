import UIKit

final class ImagesListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let photoNames = (0..<20).map(String.init)

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupTableView() {
        view.backgroundColor = .imageFeedBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 4, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.reuseIdentifier
        )

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoNames.count
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

        let image = UIImage(named: photoNames[indexPath.row]) ?? UIImage()
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
        let image = UIImage(named: photoNames[indexPath.row])
        let imageSize = image?.size ?? CGSize(width: 1, height: 1)
        let imageWidth = tableView.bounds.width - 32
        let aspectRatio = imageSize.height / max(imageSize.width, 1)
        return imageWidth * aspectRatio + 4
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "SingleImageViewController"
        ) as? SingleImageViewController else {
            return
        }

        viewController.image = UIImage(named: photoNames[indexPath.row])
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
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
