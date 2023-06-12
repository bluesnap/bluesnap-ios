
import Foundation

public class BS3DSProcessResultResponse: NSObject {
    
    var authResult: String?
    
    override init() {
        super.init()
    }
    
    public static func parseJson(data: Data?) -> (BS3DSProcessResultResponse?, BSErrors?) {
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
                else {
                    let resultError = BSErrors.unknown
                    return (nil, resultError)
            }
            let authResponse: BS3DSProcessResultResponse = BS3DSProcessResultResponse()
            authResponse.authResult = json["authResult"] as? String
       
            return (authResponse, nil)
        } catch {
            NSLog("Parse error")
        }
        return (nil, BSErrors.unknown)
    }
    
}
