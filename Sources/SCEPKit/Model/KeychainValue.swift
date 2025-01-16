import Foundation

@propertyWrapper
struct KeychainValue<Value> where Value: Codable {
    
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    
    private var namespacedKey: String { "SCEPKit." + key }
    
    var wrappedValue: Value {
        get {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: namespacedKey,
                kSecReturnData: true,
                kSecMatchLimit: kSecMatchLimitOne
            ] as CFDictionary
            
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query, &dataTypeRef)
            
            guard status == errSecSuccess, let data = dataTypeRef as? Data else {
                return defaultValue
            }
            
            let value = try? JSONDecoder().decode(Value.self, from: data)
            return value ?? defaultValue
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: namespacedKey,
                kSecValueData: data
            ] as CFDictionary
            
            SecItemDelete(query)
            let status = SecItemAdd(query, nil)
            
            if status != errSecSuccess {
                logger.error("Keychain save failed with status: \(status)")
            }
        }
    }
}
