//
// Created by oz on 28/11/2018.
// Copyright (c) 2018 Bluesnap. All rights reserved.
//

import Foundation

struct Configuration {
    static var bsAPIUser = "USER_UNDEFINED"
    static var bsAPIPassword = "PASSWORD_UNDEFINED"

    static func loadAPICredentialsFromBundle() {
        /*if let apiUsername = Bundle(for: AppDelegate.self).object(forInfoDictionaryKey: "BsAPIUser") as? String {
            Configuration.bsAPIUser = apiUsername
        }
         
        if let apiPassword = Bundle(for: AppDelegate.self).object(forInfoDictionaryKey: "BsAPIPassword") as? String {
            Configuration.bsAPIPassword = apiPassword
        }*/
        
        guard let credentialsURL = Bundle.main.url(forResource: "credentials", withExtension: "plist"),
              let dict = NSDictionary(contentsOfFile: credentialsURL.relativePath) as? Dictionary<String, String>
        else {
            return
        }
        
        Configuration.bsAPIUser = dict["BsAPIUser"]!
        Configuration.bsAPIPassword = dict["BsAPIPassword"]!
    }
}
