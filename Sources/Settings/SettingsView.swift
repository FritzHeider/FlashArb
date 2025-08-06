#if canImport(SwiftUI)
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Pricing")) {
                Text("Standard - $4.99/month")
                Text("Premium - $9.99/month")
            }
            Section(header: Text("Legal")) {
                Text("Subscriptions renew automatically. Terms of Use and Privacy Policy apply.")
            }
        }
    }
}
#endif
