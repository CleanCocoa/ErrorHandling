// Copyright (c) 2015 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import AppKit

public class TextEmailer {
    
    static var appInfo: [String : Any]? {
        return Bundle.main.infoDictionary
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
    
    public func email(error: Error) {

        email(text: (error as NSError).debugDescription)
    }

    public func email(report: Report) {

        email(text: report.localizedDescription)
    }

    public func email(text: String) {
        
        let recipient = TextEmailer.supportEmail!
        let subject = "Report for \(TextEmailer.appName!)"
        let query = "subject=\(subject)&body=\(text)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let mailtoAddress = "mailto:\(recipient)?\(query)"
        let url = URL(string: mailtoAddress)!
        
        NSWorkspace.shared().open(url)
    }
}
