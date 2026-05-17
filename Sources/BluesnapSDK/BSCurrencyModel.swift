import Foundation

/**
 This class represents a currency: name, ISO code, and exchange rate
 */
// todo: add function for currency symbol
  public class BSCurrency: NSObject {
    
    internal var name : String!
    internal var code : String!
    internal var rate: Double!
    
    internal init(name: String!, code: String!, rate: Double!) {
        self.name = name
        self.code = code
        self.rate = rate
    }
    
    public func getName() -> String! {
        return self.name
    }
    
    public func getCode() -> String! {
        return self.code
    }
    
    public func getRate() -> Double! {
        return self.rate
    }

    public func getRateNSNumber() -> NSNumber {
        return NSNumber.init(value: self.rate)
    }
    
}

/**
 This class represents a currency dictionary: it contains a list of currencies and 
 the base currency (according to which we get the exchange rates)
 */
  public class BSCurrencies: NSObject {
    
    internal var baseCurrency : String = "USD"
    internal var creationDate : Date = Date()
    internal var currencies : [BSCurrency] = []

    internal init(baseCurrency: String, currencies : [BSCurrency]) {
        
        self.baseCurrency = baseCurrency
        self.currencies = currencies
    }

    func getCreationDate() -> Date {
        return creationDate
    }
    
      public func getCurrencyByCode(code: String!) -> BSCurrency? {
        
        for currency in currencies {
            if currency.code == code {
                return currency
            }
        }
        return nil
    }
    
    public func getCurrencyIndex(code : String) -> Int? {
        
        for (index, currency) in currencies.enumerated() {
            if currency.code == code {
                return index
            }
        }
        return nil
    }

      public func getCurrencyRateByCurrencyCode(code: String!) -> NSNumber? {

        return NSNumber.init(value: (getCurrencyByCode(code: code)?.rate)!)
    }

    public func getCurrencyRateByCurrencyCode(code : String!) -> Double? {
        
        return getCurrencyByCode(code: code)?.rate
    }
}
