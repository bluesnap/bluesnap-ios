import Foundation
import PassKit

public class BSEchAchSdkResult: BSBaseSdkResult {
    
    public override init(sdkRequestBase: BSSdkRequestProtocol) {
        super.init(sdkRequestBase: sdkRequestBase)
        storeCard = nil
        chosenPaymentMethodType = BSPaymentType.ECP
    }
}