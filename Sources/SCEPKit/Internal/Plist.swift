import Foundation

//extension SCEPKitInternal {
//    
//    enum PlistKey: String, CaseIterable {
//        case adaptyApiKey = "ADAPTY_API_KEY"
//        case mainFont = "MAIN_FONT", bold = "BOLD", semibold = "SEMIBOLD", medium = "MEDIUM"
//        case mainButton = "MAIN_BUTTON", cornerRadius = "CORNER_RADIUS", fontSize = "FONT_SIZE"
//        case termsURL = "TERMS_URL"
//        case privacyURL = "PRIVACY_URL"
//        case feedbackURL = "FEEDBACK_URL"
//        case appleId = "APPLE_ID"
//        case interfaceStyle = "INTERFACE_STYLE"
//    }
//    
//    func plistString(for path: PlistKey...) -> String {
//        var dict = plistDict!
//        for (index, key) in path.enumerated() {
//            guard index < path.count - 1 else { break }
//            guard let nextDict = dict[key.rawValue] as? [String: Any] else {
//                fatalError("Path \(path) not found in SCEPKit.plist")
//            }
//            dict = nextDict
//        }
//        guard let laskKey = path.last, let string = dict[laskKey.rawValue] as? String else {
//            fatalError("Path \(path) not found in SCEPKit.plist")
//        }
//        return string
//    }
//    
//    func plistValue<Type>(for path: PlistKey...) -> Type {
//        var dict = plistDict!
//        for (index, key) in path.enumerated() {
//            guard index < path.count - 1 else { break }
//            guard let nextDict = dict[key.rawValue] as? [String: Any] else {
//                fatalError("Path \(path.map(\.rawValue)) not found in SCEPKit.plist")
//            }
//            dict = nextDict
//        }
//        guard let laskKey = path.last, let value = dict[laskKey.rawValue] as? Type else {
//            fatalError("Path \(path.map(\.rawValue)) not found in SCEPKit.plist")
//        }
//        return value
//    }
//    
//    func loadPlist() {
//        guard
//            let url = Bundle.main.url(forResource: "SCEPKit", withExtension: "plist"),
//            let plistData = try? Data(contentsOf: url),
//            let plistDict = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any]
//        else {
//            fatalError("SCEPKit.plist not found in bundle")
//        }
////        for key in PlistKey.allCases {
////            guard plistDict.keys.contains(key.rawValue) else {
////                fatalError("\(key) not found in SCEPKit.plist")
////            }
////        }
//        self.plistDict = plistDict
//    }
//}
