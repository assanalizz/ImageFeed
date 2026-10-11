import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    static func show() {
        ProgressHUD.animate("Please wait...", interaction: false)
    }

    static func dismiss() {
        ProgressHUD.dismiss()
    }
}
