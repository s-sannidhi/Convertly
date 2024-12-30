import Foundation

struct ExchangeRates: Codable {
    let result: String
    let rates: [String: Double]
    var timestamp: TimeInterval
    
    private enum CodingKeys: String, CodingKey {
        case result
        case rates = "conversion_rates"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        result = try container.decode(String.self, forKey: .result)
        rates = try container.decode([String: Double].self, forKey: .rates)
        timestamp = Date().timeIntervalSince1970
    }
    
    init(rates: [String: Double], timestamp: TimeInterval) {
        self.result = "success"
        self.rates = rates
        self.timestamp = timestamp
    }
}

enum CurrencyError: Error {
    case networkError(String)
    case invalidData
    case rateLimitExceeded
    case apiKeyMissing
}

class CurrencyAPI: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var lastUpdated: Date?
    @Published var error: String?
    @Published var isLoading = false
    
    private let apiKey = "f99f79e3b8862ac42fd7f2f8" // Get from https://www.exchangerate-api.com
    private let cache = UserDefaults.standard
    private let cacheKey = "cached_exchange_rates"
    private let updateInterval: TimeInterval = 3600 // Update every hour
    
    // Extended currency list
    static let availableCurrencies = [
        "USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "HKD", "NZD",
        "SEK", "KRW", "SGD", "NOK", "MXN", "INR", "RUB", "ZAR", "TRY", "BRL",
        "TWD", "DKK", "PLN", "THB", "IDR", "HUF", "CZK", "ILS", "CLP", "PHP"
    ]
    
    init() {
        loadCachedRates()
        setupPeriodicUpdate()
    }
    
    private func loadCachedRates() {
        if let cached = cache.object(forKey: cacheKey) as? Data {
            do {
                let decoder = JSONDecoder()
                let cachedRates = try decoder.decode(ExchangeRates.self, from: cached)
                
                // Only use cached rates if they're less than 24 hours old
                if Date().timeIntervalSince1970 - cachedRates.timestamp < 86400 {
                    DispatchQueue.main.async {
                        self.rates = cachedRates.rates
                        self.lastUpdated = Date(timeIntervalSince1970: cachedRates.timestamp)
                    }
                }
            } catch {
                print("Error loading cached rates: \(error)")
            }
        }
    }
    
    private func setupPeriodicUpdate() {
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchExchangeRates()
            }
        }
    }
    
    func fetchExchangeRates() async {
        guard apiKey != "YOUR_API_KEY" else {
            DispatchQueue.main.async {
                self.error = "API key not configured"
            }
            return
        }
        
        // Using USD as base currency
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/USD") else {
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    break // Success
                case 404:
                    throw CurrencyError.networkError("API endpoint not found")
                case 429:
                    throw CurrencyError.rateLimitExceeded
                default:
                    throw CurrencyError.networkError("Server returned status code \(httpResponse.statusCode)")
                }
            }
            
            let decoder = JSONDecoder()
            let exchangeRates = try decoder.decode(ExchangeRates.self, from: data)
            
            // Cache the response
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(exchangeRates) {
                cache.set(encoded, forKey: cacheKey)
            }
            
            DispatchQueue.main.async {
                self.rates = exchangeRates.rates
                self.lastUpdated = Date(timeIntervalSince1970: exchangeRates.timestamp)
                self.isLoading = false
            }
            
        } catch {
            setError("Failed to fetch exchange rates: \(error.localizedDescription)")
        }
    }
    
    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.error = message
            self.isLoading = false
        }
    }
    
    func getLastUpdateTimeString() -> String {
        guard let lastUpdated = lastUpdated else {
            return "Never updated"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "Last updated \(formatter.localizedString(for: lastUpdated, relativeTo: Date()))"
    }
} 
