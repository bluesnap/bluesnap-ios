//
//  BSBaseListController.swift
//  BluesnapSDK
//
//  Base class for the list screens: currencies, countries and states
//
//  Created by Shevie Chen on 03/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSBaseListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // The currently selected currency/country/state code
    internal var selectedItem : (name: String, code: String) = (name: "", code: "")
    internal var groups = [String: [(name: String, code: String)]]()
    internal var groupSections = [String]()

    let SECTION_HEADER_LABEL_HEIGHT: CGFloat = 18
    let SECTION_HEADER_MARGIN: CGFloat = 5
    let sectionColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1)

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: abstract functions - need to be overridden by the actual list classes
    
    func doFilter(_ searchText: String) {}
    
    func createTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func selectItem(newItem: (name: String, code: String)) {}
    
    func setTitle() {}

    // MARK: - UIViewController's methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // add thin border below the searchBar
        let border = CALayer()
        border.frame = CGRect(x: 0, y: searchBar.frame.height-1, width: searchBar.frame.width, height: 0.5)
        border.backgroundColor = BSColorCompat.systemBackground.cgColor
        searchBar.layer.addSublayer(border)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setTitle()
        
        doFilter(searchBar.text ?? "")
        
        super.viewWillAppear(animated)
        self.navigationController!.isNavigationBarHidden = false
        
        // scroll to selected
        if let indexPath = getIndex(ofItem: selectedItem) {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
    }

    
    // UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //self.searchBar = searchBar
        doFilter(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar : UISearchBar) {
        searchBar.text = ""
        doFilter("")
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    // MARK: UITableViewDataSource & UITableViewDelegate functions

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupSections.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return groupSections
    }
    
    // return height of section header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_HEADER_LABEL_HEIGHT + 2*SECTION_HEADER_MARGIN
    }
    
    // return height of section footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    // Create a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createTableViewCell(tableView, cellForRowAt: indexPath)
    }
    
    // Tells the delegate that the specified row is now selected.
    func tableView(_: UITableView, didSelectRowAt: IndexPath) {
        
        // find and deselect previous option
        if let indexPath = getIndex(ofItem: selectedItem) {
            selectedItem = (name: "", code: "")
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        // select current option
        let firstLetter = groupSections[didSelectRowAt.section]
        selectedItem = groups[firstLetter]![didSelectRowAt.row]
        tableView.reloadRows(at: [didSelectRowAt], with: .none)
        
        // call updateFunc
        selectItem(newItem: selectedItem)

        // go back
        _ = navigationController?.popViewController(animated: true)
    }

    // Return # rows to display in the section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let firstLetter = groupSections[section]
        if let valuesOfSection = groups[firstLetter] {
            return valuesOfSection.count
        } else {
            return 0
        }
    }
    
    
    // create a section cell
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel(frame: CGRect(x: 0, y: SECTION_HEADER_MARGIN, width: self.view.frame.width, height: SECTION_HEADER_LABEL_HEIGHT))
        label.text = groupSections[section]
        label.font.withSize(SECTION_HEADER_LABEL_HEIGHT)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: SECTION_HEADER_LABEL_HEIGHT + 2*SECTION_HEADER_MARGIN))
        view.backgroundColor = sectionColor
        view.addSubview(label)
        
        return view
    }
    
    // MARK: gereric functionality
    
    func getIndex(ofItem: (name: String, code: String)) -> IndexPath? {
        
        let name = ofItem.name
        if name.count > 0 {
            let firstLetter = "\(name[name.startIndex])".uppercased()
            if let section = groups[firstLetter] {
                var index = 0
                for item: (name: String, code: String) in section {
                    if item.code == ofItem.code {
                        let row = groupSections.firstIndex(of: firstLetter)
                        let indexPath = IndexPath(row: index, section: row!)
                        return indexPath
                    }
                    index = index + 1
                }
            }
        }
        return nil
    }
}
