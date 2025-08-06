import SwiftUI

/// UIKit wrapper for the SwiftUI dashboard screen.
class DashboardViewController: UIHostingController<DashboardView> {
    init() {
        super.init(rootView: DashboardView())
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: DashboardView())
    }
}
