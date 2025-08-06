import Foundation
#if canImport(StoreKit)
import StoreKit
#endif

final class ReceiptValidator {
    func validateReceipt() -> Bool {
#if canImport(StoreKit)
        guard let url = Bundle.main.appStoreReceiptURL,
              let data = try? Data(contentsOf: url) else { return false }
        return !data.isEmpty
#else
        // Assume valid in environments without StoreKit
        return true
#endif
    }
}
