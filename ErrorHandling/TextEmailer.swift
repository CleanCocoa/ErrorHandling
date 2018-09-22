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

    static var build: String {
        guard let build = appInfo?["CFBundleVersion"] as? String else { return "" }
        return "b\(build)"
    }

    static var version: String {
        guard let version = appInfo?["CFBundleShortVersionString"] as? String else { return "" }
        return "v\(version)"
    }

    static var versionString: String? {
        let combined = [version, build].filter { !$0.isEmpty }.joined(separator: " ")
        guard !combined.isEmpty else { return nil }
        return "(\(combined))"
    }

    static var emailSubject: String {
        let base = "Report for \(appName!)"
        guard let buildAndVersion = versionString else { return base }
        return "\(base)  \(buildAndVersion)"
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
    
    public func email(error: Error, instructions: String? = nil) {

        email(text: (error as NSError).debugDescription, instructions: instructions)
    }

    public func email(report: Report, instructions: String? = nil) {

        email(text: report.localizedDescription, instructions: instructions)
    }

    public func email(text: String, instructions: String?) {

        guard let emailService = NSSharingService(named: .composeEmail) else {
            legacyURLEmailer(text: text)
            return
        }

        emailService.recipients = [TextEmailer.supportEmail!]
        emailService.subject = TextEmailer.emailSubject
        emailService.perform(withItems: [instructions, text].compactMap { $0 })
    }

    private func legacyURLEmailer(text: String) {

        let recipient = TextEmailer.supportEmail!
        let subject = TextEmailer.emailSubject
        let query = "subject=\(subject)&body=\(text)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let mailtoAddress = "mailto:\(recipient)?\(query)"
        let url = URL(string: mailtoAddress)!

        NSWorkspace.shared.open(url)
    }
}
