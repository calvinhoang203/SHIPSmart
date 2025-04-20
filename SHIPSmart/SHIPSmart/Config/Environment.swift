import Foundation

enum EnvironmentKeys {
    static let cerebrasApiKey = "CEREBRAS_API_KEY"
}

final class AppEnvironment {
    static func value(for key: String) -> String? {
        // First try to get from environment variables
        if let environmentValue = ProcessInfo.processInfo.environment[key] {
            return environmentValue
        }
        
        // Then try to get from .env file
        if let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
           let envContent = try? String(contentsOfFile: envPath, encoding: .utf8) {
            let lines = envContent.components(separatedBy: .newlines)
            for line in lines {
                let parts = line.components(separatedBy: "=")
                if parts.count == 2 && parts[0].trimmingCharacters(in: .whitespaces) == key {
                    return parts[1].trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        return nil
    }
    
    static var cerebrasApiKey: String {
        guard let apiKey = value(for: EnvironmentKeys.cerebrasApiKey) else {
            fatalError("CEREBRAS_API_KEY not found in environment")
        }
        return apiKey
    }
}

#if DEBUG
extension AppEnvironment {
    static func loadEnvFile() {
        guard let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
              let envContent = try? String(contentsOfFile: envPath, encoding: .utf8) else {
            print("⚠️ No .env file found")
            return
        }
        
        let lines: [String] = envContent.components(separatedBy: .newlines)
        for line in lines {
            let parts: [String] = line.components(separatedBy: "=")
            if parts.count == 2 {
                let key: String = parts[0].trimmingCharacters(in: .whitespaces)
                let value: String = parts[1].trimmingCharacters(in: .whitespaces)
                setenv(key, value, 1)
            }
        }
    }
}
#endif