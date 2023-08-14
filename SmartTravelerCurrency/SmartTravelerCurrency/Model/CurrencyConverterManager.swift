//
//  CurrencyConverterManager.swift
//  SmartTravelerCurrency
//
//  Created by BIT on 10.08.2023.
//

import Foundation

protocol CurrencyConverterDelegate {
    func didUpdateCurrencies(_ currencyConverterManager:CurrencyConverterManager, currencyConverter: CurrencyConverterResponse)
    func didFailWithError(error: Error)
    func saveDataToUserDefaults(data:Data, baseCurrency:String)
}
struct CurrencyConverterManager{
    let urlString=String("https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_zOpaTPOXHpaQ902J6uYswYhQA9Gd7EFCpgn1zf2m&currencies=")
    var delegate:CurrencyConverterDelegate?
    
    func getExchangeRates(for baseCurrency:String = "USD", to currencies: [String] ) {
        var reqUrl = urlString
        for currency in currencies {
            reqUrl += currency + "%2C"
        }
        reqUrl.removeLast(3)
        reqUrl+="&base_currency=\(baseCurrency)"

        let url = URL(string:reqUrl)!
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url){ data, response, error in
                    
               if let caughtError = error {
                   delegate?.didFailWithError(error: caughtError)
                   return
               }
                    
               if let safeData = data {
                   self.delegate?.saveDataToUserDefaults(data: safeData, baseCurrency: baseCurrency)
                 if let res =  self.parseJSON(currencyResponseData:safeData){
                     self.delegate?.didUpdateCurrencies(self, currencyConverter: res)
                     return

                   }

               }
           }
           task.resume()
    }

    func parseJSON(currencyResponseData:Data) -> CurrencyConverterResponse? {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(CurrencyConverterResponse.self, from: currencyResponseData)
            return response
        } catch {
            print("Error decoding JSON: \(error)")
        }
        return nil
    }
}
