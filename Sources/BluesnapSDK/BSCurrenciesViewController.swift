//
//  BSCurrenciesViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 11/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSCurrenciesViewController: BSBaseListController {
    
    // MARK: private properties
    
    fileprivate var oldSelectedItem : (name: String, code: String)?
    fileprivate var bsCurrencies : BSCurrencies?
    fileprivate var filteredItems : BSCurrencies?
    // the callback function that gets called when a currency is selected;
    // this is just a default
    fileprivate var updateFunc : (BSCurrency?, BSCurrency)->Void = {
        oldCurrency, newCurrency in
        NSLog("Currency \(newCurrency.getCode() ?? "None") was selected")
    }

    // MARK: init currencies
    
    /**
     init the screen variables, re-load rates
     */
    func initCurrencies(currencyCode : String,
                        currencies : BSCurrencies,
                        updateFunc : @escaping (BSCurrency?, BSCurrency)->Void) {
        
        self.updateFunc = updateFunc
        self.bsCurrencies = currencies
        if let bsCurrency = currencies.getCurrencyByCode(code: currencyCode) {
            self.selectedItem = (name: bsCurrency.getName(), code: bsCurrency.getCode())
            self.oldSelectedItem = self.selectedItem
        }
    }
    
    
    // MARK: Override functions of BSBaseListController
    
    override func setTitle() {
    
        self.title = BSLocalizedStrings.getString(BSLocalizedString.Title_Currency_Screen)
    }
    
    override func doFilter(_ searchText : String) {
        
        if searchText == "" {
            filteredItems = self.bsCurrencies
        } else if let bsCurrencies = self.bsCurrencies {
            let filtered = bsCurrencies.currencies.filter{(x) -> Bool in (x.name.uppercased().range(of:searchText.uppercased())) != nil }
            filteredItems = BSCurrencies(baseCurrency: bsCurrencies.baseCurrency, currencies: filtered)
        } else {
            filteredItems = BSCurrencies(baseCurrency: "USD", currencies: [])
        }
        generateGroups()
        self.tableView.reloadData()
    }
    
    override func selectItem(newItem: (name: String, code: String)) {
        
        if let bsCurrencies = bsCurrencies {
            var oldBsCurrency : BSCurrency?
            if let oldItem = oldSelectedItem {
                oldBsCurrency = bsCurrencies.getCurrencyByCode(code: oldItem.code)
            }
            oldSelectedItem = newItem
            let newBsCurrency = bsCurrencies.getCurrencyByCode(code: newItem.code)
            
            // call updateFunc
            updateFunc(oldBsCurrency, newBsCurrency!)
        }
    }
    
    override func createTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell", for: indexPath)
        let cell = reusableCell as! BSCurrencyTableViewCell
        
        let firstLetter = groupSections[indexPath.section]
        if let currency = groups[firstLetter]?[indexPath.row] {
            cell.CurrencyUILabel.text = currency.name + " " + currency.code
            cell.checkMarkImage.image = nil
            if (currency.code == selectedItem.code) {
                if let image = BSViewsManager.getImage(imageName: "blue_check_mark") {
                    cell.checkMarkImage.image = image
                }
            } else {
                cell.checkMarkImage.image = nil
            }
        }
        return cell
    }
    
    // MARK: private functions
    
    private func generateGroups() {
        
        groups = [String: [(name: String, code: String)]]()
        for bsCurrency: BSCurrency in (filteredItems?.currencies)! {
            let currency: (name: String, code: String) = (name: bsCurrency.getName(), code: bsCurrency.getCode())
            let name = currency.name 
            let firstLetter = "\(name[name.startIndex])".uppercased()
            if var currenciesByFirstLetter = groups[firstLetter] {
                currenciesByFirstLetter.append(currency)
                groups[firstLetter] = currenciesByFirstLetter
            } else {
                groups[firstLetter] = [currency]
            }
        }
        groupSections = [String](groups.keys)
        groupSections = groupSections.sorted()
    }
}
