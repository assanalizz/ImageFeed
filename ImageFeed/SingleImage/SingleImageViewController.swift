import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!

    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        scrollView.delegate = self
        imageView.image = image
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImageLayout()
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    private func configureAppearance() {
        view.backgroundColor = .black
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false

        let shareConfiguration = UIImage.SymbolConfiguration(pointSize: 21, weight: .semibold)
        shareButton.setImage(
            UIImage(systemName: "square.and.arrow.up", withConfiguration: shareConfiguration),
            for: .normal
        )
        shareButton.tintColor = .white
        shareButton.backgroundColor = UIColor.black.withAlphaComponent(0.72)
        shareButton.layer.cornerRadius = 26

        let backConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        backButton.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: backConfiguration),
            for: .normal
        )
        backButton.tintColor = .white
    }

    private func updateImageLayout() {
        guard let image else { return }
        let boundsSize = scrollView.bounds.size
        guard boundsSize.width > 0, boundsSize.height > 0 else { return }

        let widthScale = boundsSize.width / image.size.width
        let heightScale = boundsSize.height / image.size.height
        let scale = max(widthScale, heightScale)
        let size = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        imageView.frame = CGRect(origin: .zero, size: size)
        scrollView.contentSize = size
        centerImageView()

        if scrollView.zoomScale == scrollView.minimumZoomScale {
            let offsetX = max((size.width - boundsSize.width) / 2, 0)
            let offsetY = max((size.height - boundsSize.height) / 2, 0)
            scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
        }
    }

    private func centerImageView() {
        let boundsSize = scrollView.bounds.size
        var frame = imageView.frame
        frame.origin.x = frame.size.width < boundsSize.width
            ? (boundsSize.width - frame.size.width) / 2
            : 0
        frame.origin.y = frame.size.height < boundsSize.height
            ? (boundsSize.height - frame.size.height) / 2
            : 0
        imageView.frame = frame
    }

    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }

    @IBAction private func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
}
