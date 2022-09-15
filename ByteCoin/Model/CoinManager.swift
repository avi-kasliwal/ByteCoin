//
//  CoinManager.swift
//  ByteCoin
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice (price: String, currency: String)
    func didFailWithError (error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "YOUR_API_KEY_HERE"
    
    var delegate : CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice (for currency : String) -> Void {      
        // Prepare the url string using target currency and apikey
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)&"
        
        if let url = URL (string: urlString) {
            let session = URLSession (configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                } else if let safeData = data {
                    if let btcPrice = parseJSON(safeData) {
                        let btcPriceString = String (format: "%.2f", btcPrice)
                        self.delegate?.didUpdatePrice(price: btcPriceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON (_ data: Data) -> Double? {
        let decoder = JSONDecoder ()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return Double (lastPrice)
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
