import Foundation

public class BS3DSAuthResponse: NSObject {

    var enrollmentStatus: String?
    var acsUrl: String?
    var payload: String?
    var transactionId: String?
    var threeDSVersion: String?


    override init() {
        super.init()
    }


    public static func parseJson(data: Data?) -> (BS3DSAuthResponse?, BSErrors?) {

        do {
            guard let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
                    else {
                let resultError = BSErrors.unknown
                return (nil, resultError)
            }
            let authResponse: BS3DSAuthResponse = BS3DSAuthResponse()
            authResponse.enrollmentStatus = json["enrollmentStatus"] as? String
            authResponse.acsUrl = json["acsUrl"] as? String
            authResponse.payload = json["payload"] as? String
            authResponse.transactionId = json["transactionId"] as? String
            authResponse.threeDSVersion = json["threeDSVersion"] as? String
            return (authResponse, nil)
        } catch {
            NSLog("Parse error")
        }
        return (nil, BSErrors.unknown)
    }

}
