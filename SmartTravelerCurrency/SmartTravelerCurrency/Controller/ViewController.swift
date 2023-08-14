import UIKit
import SystemConfiguration

class ViewController: UIViewController{
   
    
    
    @IBOutlet private var usdView: CurrencyView!
    @IBOutlet private var ronView: CurrencyView!
    @IBOutlet private var gbpView: CurrencyView!
    @IBOutlet private var eurView: CurrencyView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    private var currencyViews:[CurrencyView]=[]
    var requestCurrency=CurrencyModel(value: 1, abbreviation: Constants.CurrencyNames.usDollar)
    var currencyConverterManager=CurrencyConverterManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usdView.currencyAbbreviation = Constants.CurrencyNames.usDollar
        ronView.currencyAbbreviation = Constants.CurrencyNames.romanianLeu
        gbpView.currencyAbbreviation = Constants.CurrencyNames.greatBritainPound
        eurView.currencyAbbreviation = Constants.CurrencyNames.euro
    
        currencyViews.append(usdView)
        currencyViews.append(ronView)
        currencyViews.append(gbpView)
        currencyViews.append(eurView)
        
        for currencyView in currencyViews {
            currencyView.delegate = self
            currencyView.currencyValue = 0
        }
        
        currencyConverterManager.delegate=self
        updateCurrencyData()
        updateViewData()
    }
    
    private func updateCurrencyData()
    {
        if Reachability.isConnectedToNetwork()
        {
            let currencyNames = currencyViews.map{cv in cv.currencyAbbreviation!}
            for currencyName in currencyNames
            {
                currencyConverterManager.getExchangeRates(for: currencyName, to: currencyNames)
            }
        }
        
    }
    
    private func updateStatusForInternetConnection(isAvailable:Bool){
        statusLabel.text = isAvailable ? Constants.StatusMessages.Connected : Constants.StatusMessages.noInternet
    }
    
    private func getCachedExchangeRate(for baseCurrency:String) -> CurrencyConverterResponse? {
        if let cachedData = UserDefaults.standard.object(forKey:baseCurrency) as? Data {
            do {
                let decoder = JSONDecoder()
                let cachedCurrencyConverter = try decoder.decode(CurrencyConverterResponse.self, from: cachedData)
                return cachedCurrencyConverter
            } catch {
                print("Error decoding JSON: \(error)")
            }
            return nil
        }
        else {
            return nil
        }
        
    }

    
    private func updateViewData()
    {   updateStatusForInternetConnection(isAvailable: Reachability.isConnectedToNetwork())
        if (Reachability.isConnectedToNetwork())
        {
            let currencyNames = currencyViews.map{cv in cv.currencyAbbreviation!}
            currencyConverterManager.getExchangeRates(for: requestCurrency.abbreviation, to: currencyNames)
        }
        else
            if let cachedRates = getCachedExchangeRate(for: requestCurrency.abbreviation)
            {
                if let dateString = getDataTimeStamp(for: requestCurrency.abbreviation)
                {
                    lastUpdatedLabel.text = dateString
                }
                
                updateViews(with: cachedRates)
                statusLabel.text = Constants.StatusMessages.updatedFromCache
                
            }
                else
                {
                    statusLabel.text = Constants.StatusMessages.noInternet
                }
    }
    

    
    private func updateViews(with currencyConverter:CurrencyConverterResponse)
    {
        for currencyView in self.currencyViews {
        let value = self.requestCurrency.value * currencyConverter.data[currencyView.currencyAbbreviation!]!
            currencyView.currencyValue = value
    }
        self.lastUpdatedLabel.text = getDataTimeStamp(for: requestCurrency.abbreviation)
    }
    
     func saveDataToUserDefaults(data: Data, baseCurrency: String) {
        UserDefaults.standard.set(data, forKey: baseCurrency)
        UserDefaults.standard.set(Date(),forKey: Constants.UserDefaultsKeys.dateKey(baseCurrency: baseCurrency))
    }
    
//     func getDataFromUserDefaults(baseCurrency:String)->Data? {
//        return UserDefaults.standard.data(forKey: "cachedData")
//    }
    
     func getDataTimeStamp(for currency:String)->String?{
         if let date =  UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.dateKey(baseCurrency: currency)) as? Date
        {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .long
            return formatter.string(from: date)
        }
        return nil
    }
    

    
}

    //MARK: - CurrencyConverter Delegate
extension ViewController:CurrencyConverterDelegate {
    
    func didUpdateCurrencies(_ currencyConverterManager: CurrencyConverterManager, currencyConverter: CurrencyConverterResponse) {
        DispatchQueue.main.async {
            self.updateViews(with:currencyConverter)
            self.statusLabel.text=Constants.StatusMessages.Connected
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
        if let error = error as? URLError {
                       switch error.code {
                       case .notConnectedToInternet:
                           self.updateStatusForInternetConnection(isAvailable: false)
                       case .timedOut:
                           self.statusLabel.text = "There has been an issue. Try again!"
                       default:
                           print("Error: \(error.localizedDescription)")
                       }
                   }
        }
    }
}

//MARK: - CurrencyViewDelegate
extension ViewController: CurrencyViewDelegate {
    
    func currencyValueChanged(_ newValue: CurrencyModel, view: CurrencyView)
    {
        requestCurrency = newValue
        updateViewData()
    }
}

