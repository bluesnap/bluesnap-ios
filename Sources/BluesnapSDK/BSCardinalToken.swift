//
//  BSToken.swift


import Foundation

public class BSCardinalToken: NSObject {

    internal var jwtStr: String! = ""

    public static func parseJson(data: Data?) -> (BSCardinalToken?, BSErrors?) {

        do {
            let resultData: BSCardinalToken = BSCardinalToken()
            guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
                    else {
                let resultError = BSErrors.cardinalTokenParseError
                return (nil, resultError)
            }
            let newToken: BSCardinalToken = BSCardinalToken()
            newToken.jwtStr = json["jwt"] as? String
            return (resultData, nil)
        } catch {
            NSLog("Parse error")
        }
        return (nil, BSErrors.cardinalTokenParseError)
    }
}
