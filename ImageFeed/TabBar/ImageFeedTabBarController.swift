import UIKit

final class ImageFeedTabBarController: UITabBarController {
    private let customTabBar = UIView()
    private let feedButton = UIButton(type: .system)
    private let profileButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        setupCustomTabBar()
        updateSelection()
    }

    private func setupCustomTabBar() {
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.backgroundColor = .imageFeedBackground
        customTabBar.layer.zPosition = 1000
        view.addSubview(customTabBar)

        configureButton(feedButton, systemName: "photo.on.rectangle")
        configureButton(profileButton, systemName: "person.crop.circle")

        feedButton.addTarget(self, action: #selector(didTapFeed), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(didTapProfile), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [feedButton, profileButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        customTabBar.addSubview(stackView)

        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -52
            ),

            stackView.topAnchor.constraint(equalTo: customTabBar.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: customTabBar.leadingAnchor, constant: 46),
            stackView.trailingAnchor.constraint(equalTo: customTabBar.trailingAnchor, constant: -46),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        viewControllers?.forEach {
            $0.additionalSafeAreaInsets.bottom = 52
        }
    }

    private func configureButton(_ button: UIButton, systemName: String) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(UIImage(systemName: systemName, withConfiguration: configuration), for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.45)
    }

    @objc private func didTapFeed() {
        selectedIndex = 0
        updateSelection()
    }

    @objc private func didTapProfile() {
        selectedIndex = 1
        updateSelection()
    }

    private func updateSelection() {
        feedButton.tintColor = selectedIndex == 0 ? .white : UIColor.white.withAlphaComponent(0.45)
        profileButton.tintColor = selectedIndex == 1 ? .white : UIColor.white.withAlphaComponent(0.45)
    }
}
