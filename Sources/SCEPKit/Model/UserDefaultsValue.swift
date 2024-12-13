import Foundation

@propertyWrapper
struct UserDefaultsValue<Value> where Value: Codable {
    
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    
    private var namespacedKey: String { "SCEPKit." + key }
    
    var wrappedValue: Value {
        get {
            if let data = container.data(forKey: namespacedKey), let value = try? JSONDecoder().decode(Value.self, from: data) {
                return value
            } else {
                return defaultValue
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                container.set(data, forKey: namespacedKey)
            }
        }
    }
}
