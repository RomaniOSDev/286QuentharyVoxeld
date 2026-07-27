import Foundation

enum AppLinks {
    case privacy
    case terms

    var url: URL {
        switch self {
        case .privacy:
            return URL(string: "https://quenthary286voxeld.site/privacy/377") ?? URL(fileURLWithPath: "/")
        case .terms:
            return URL(string: "https://quenthary286voxeld.site/terms/377") ?? URL(fileURLWithPath: "/")
        }
    }
}
