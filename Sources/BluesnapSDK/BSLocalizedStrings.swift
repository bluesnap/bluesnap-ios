//
//  BsLocalizedStrings.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 13/08/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

class BSLocalizedStrings {

    open class func getString(_ str: BSLocalizedString) -> String {
        
        let key = str.rawValue
        let stringsBundle = BSViewsManager.getBundle()
        
        let res : String = NSLocalizedString(key, tableName: "BSLocalizable", bundle: stringsBundle, value: "", comment: "")
        return res
    }
}

public enum BSLocalizedString : String {
    
    /* ------- General ------- */
    
    case Alert_OK_Button_Text
    case Keyboard_Done_Button_Text
    
    /* ------- BSCcInputLine ------- */
    
    case Error_General_CC_Validation_Error
    case Error_Card_Type_Not_Supported_1
    case Error_Card_Type_Not_Supported_2
    case Error_Cc_Submit_Token_expired
    case Error_Cc_Submit_Token_not_found
    case Error_General_CC_Submit_Error
    
    /* ------- Validation errors ------- */
    
    case Error_Invalid_CCN
    case Error_Invalid_CVV
    case Error_Invalid_ExpMonth
    case Error_Invalid_ExpIsInThePast
    case Error_Invalid_EXP
    case Error_Invalid_Name
    case Error_Invalid_Email
    case Error_Invalid_Address
    case Error_Invalid_City
    case Error_Invalid_Country
    case Error_Invalid_State
    case Error_Invalid_ZipCode
    case Error_Invalid_PostalCode
    
    /* ------- Zip/Postal code labels ------- */

    case Placeholder_Billing_Zip
    case Placeholder_Shipping_Zip
    case Placeholder_Postal_Code


    /* ------- Payment Type screen ------- */
    
    case Title_Payment_Type
    case Label_Or
    case Navigate_Back_to_payment_type_screen
    
    /* ------- Pay Pal functionality ------- */
    
    case Error_Title_PayPal
    case Error_PayPal_Currency_Not_Supported
    case Error_General_PayPal_error
    
    /* ------- Apple Pay functionality ------- */
    
    case Error_Title_Apple_Pay
    case Error_Not_available_on_this_device
    case Error_No_cards_set
    case Error_Setup_error
    case Error_General_ApplePay_error
    
    /* ------- (CC) Payment screen ------- */

    case Error_Title_Payment
    case Error_General_Payment_error
    case Error_Three_DS_Authentication_Error
    
    case Title_Payment_Screen
    
    case Placeholder_Name
    case Placeholder_Email
    case Placeholder_Address
    case Placeholder_City
    case Placeholder_State
    

    case Label_Subtotal_Amount
    case Label_Tax_Amount
    
    case Label_Shipping_Same_As_Billing
    case Label_Store_Card

    case Payment_Pay_Button_Format
    case Payment_subtotal_and_tax_format
    case Payment_Shipping_Button
    
    case Subscription_Pay_Button_Format
    case Subscription_with_price_details_Pay_Button_Format
    
    case Three_DS_Authentication_Required_Error

    /* ------- Menu in Payment screen ------- */
    
    case Menu_Item_Currency
    case Menu_Item_Cancel
    
    /* ------- Labels for shipping screens ------- */

    case Title_Shipping_Screen
    case Label_Phone
    
    /* ------- List screens ------- */

    case Title_Currency_Screen
    case Title_Country_Screen
    case Title_State_Screen
    
    /* ------- Existing CC screen labels ------- */

    case Label_Billing
    case Label_Shipping
    case Edit_Button_Title
    
}
