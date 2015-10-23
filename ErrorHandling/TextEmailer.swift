// Copyright (c) 2015 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import AppKit

public class TextEmailer {
    
    static var appInfo: [String : AnyObject]? {
        return NSBundle.mainBundle().infoDictionary
    }
    
    static var appName: String? {
        return appInfo?["CFBundleName"] as? String
    }
    
    static var supportEmail: String? {
        return appInfo?["SupportEmail"] as? String
    }
    
    static func guardInfoPresent() {
        
        precondition(hasValue(appInfo), "Could not read app's Info dictionary.")
        precondition(hasValue(appName), "Expected CFBundleName in Info.plist to use as appName in e-mail.")
        precondition(hasValue(supportEmail), "Expected SupportEmail being set in Info.plist")
    }
    
    public init() {
        
        TextEmailer.guardInfoPresent()
    }

}

extension TextEmailer: ReportEmailer {
    
    public func email(error: NSError) {
        
        email(error.debugDescription)
    }
    
    public func email(text: String) {
        
        let recipient = TextEmailer.supportEmail!
        let subject = "Report for \(TextEmailer.appName!)"
        let query = "subject=\(subject)&body=\(text)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let mailtoAddress = "mailto:\(recipient)?\(query)"
        let URL = NSURL(string: mailtoAddress)!
        
        NSWorkspace.sharedWorkspace().openURL(URL)
    }
}