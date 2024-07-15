import Foundation
import FirebaseRemoteConfig

extension SCEPKitInternal {
    
    func remoteConfigValue<Type: Decodable>(for key: String) -> Type? {
        let data = RemoteConfig.remoteConfig().configValue(forKey: key).dataValue
        guard let value = try? JSONDecoder().decode(Type.self, from: data) else { return nil }
        return value
    }
    
    struct OnboardingConfig: Codable {
        
        let buttonTitle: String
        let slides: [Slide]
        
        struct Slide: Codable {
            let imageURL: URL
            let title: String
        }
    }
}
