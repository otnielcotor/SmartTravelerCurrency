import Foundation
struct Constants {
    struct CurrencyNames {
        static let usDollar = "USD"
        static let euro = "EUR"
        static let greatBritainPound = "GBP"
        static let romanianLeu = "RON"
    }
    struct StatusMessages {
        static let noInternet = "No internet. Please connect to a network."
        static let Connected = "Connected"
        static let updatedFromCache = "No internet. Updated from cache"
    }
    struct UserDefaultsKeys {
        static let data = "DATA"
        static func dateKey(baseCurrency:String)->String{
            return "DATE"+baseCurrency
        }
    }
}
