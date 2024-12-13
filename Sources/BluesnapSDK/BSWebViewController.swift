//
//  BSWebViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 05/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//
import UIKit
import WebKit

class BSWebViewController: UIViewController {
    
    // MARK: private properties
    
    @IBOutlet weak var webView: WKWebView!
    fileprivate var url : String = ""
    fileprivate var shouldGoToUrlFunc : ((_ url : String) -> Bool)?
    fileprivate var activityIndicator : UIActivityIndicatorView?
    
    // MARK: init
    
    /**
    * Initialize the web viw to go to URL; when URL changes, we call shouldGoToUrlFunc and nacvigate only if it returns true.
    */
    func initScreen(url: String, shouldGoToUrlFunc: ((_ url : String) -> Bool)?) {
        self.url = url
        self.shouldGoToUrlFunc = shouldGoToUrlFunc
    }
    
    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //webView.delegate = self
        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        
        let wUrl = URL(string: self.url)
        NSLog("WebView loading URL")
        webView.load(URLRequest(url: wUrl!))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
