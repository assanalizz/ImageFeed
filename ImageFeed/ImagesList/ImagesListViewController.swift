import UIKit


final class ImagesListViewController: UIViewController {

    private let tableView = UITableView(
        frame: .zero,
        style: .plain
    )


    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )

        ImagesListService.shared.fetchPhotosNextPage()
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
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



    @objc
    private func updateTableViewAnimated() {

        DispatchQueue.main.async {

            self.tableView.reloadData()

        }
    }

}



// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {


    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        ImagesListService.shared.photos.count

    }



    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {


        guard let cell =
                tableView.dequeueReusableCell(
                    withIdentifier:
                        ImagesListCell.reuseIdentifier,
                    for:
                        indexPath
                ) as? ImagesListCell

        else {

            return UITableViewCell()

        }



        let photo =
        ImagesListService.shared.photos[indexPath.row]


        cell.configure(photo: photo)



        cell.onLikeButtonTapped = {
            [weak self] in


            guard let self else {
                return
            }


            let currentPhoto =
            ImagesListService.shared.photos[indexPath.row]



            UIBlockingProgressHUD.show()



            ImagesListLikeService.shared.changeLike(
                photoId: currentPhoto.id,
                isLike: !currentPhoto.isLiked
            ) { result in


                UIBlockingProgressHUD.dismiss()



                switch result {


                case .success(let isLiked):


                    ImagesListService.shared.updateLike(
                        photoId: currentPhoto.id,
                        isLiked: isLiked
                    )


                    DispatchQueue.main.async {


                        self.tableView.reloadRows(
                            at: [indexPath],
                            with: .automatic
                        )

                    }



                case .failure(let error):

                    print(
                        "[ImagesListViewController.like]: \(error)"
                    )

                }

            }

        }



        return cell

    }

}



// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {


    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {


        let photo =
        ImagesListService.shared.photos[indexPath.row]



        let width =
        tableView.bounds.width - 32



        let ratio =
        photo.size.height /
        max(photo.size.width, 1)



        return width * ratio + 4

    }





    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {


        let photo =
        ImagesListService.shared.photos[indexPath.row]



        let controller =
        UIStoryboard(
            name: "Main",
            bundle: nil
        )
        .instantiateViewController(
            withIdentifier:
                "SingleImageViewController"
        ) as! SingleImageViewController



        controller.imageURL =
            photo.fullImageURL



        controller.modalPresentationStyle =
            .fullScreen



        present(
            controller,
            animated: true
        )

    }





    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {


        let offset =
        scrollView.contentOffset.y


        let height =
        scrollView.contentSize.height -
        scrollView.frame.height



        if offset > height - 1000 {

            ImagesListService.shared.fetchPhotosNextPage()

        }

    }

}
