// Copyright (c) 2015 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import AppKit

let IsRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

public protocol ReportEmailer {
    
    func email(text: String, instructions: String?)
    func email(error: Error, instructions: String?)
    func email(report: Report, instructions: String?)
}

enum Reportable: CustomDebugStringConvertible {

    case error(Error)
    case report(Report)

    var localizedDescription: String {
        switch self {
        case .error(let error):
            return error.localizedDescription
        case .report(let report):
            return report.localizedDescription
        }
    }

    var debugDescription: String {
        switch self {
        case .error(let error as NSError):
            return error.debugDescription
        case .report(_):
            return "()"
        }
    }

    func email(emailer: ReportEmailer, instructions: String?) {
        switch self {
        case .error(let error):
            emailer.email(error: error, instructions: instructions)
        case .report(let report):
            emailer.email(report: report, instructions: instructions)
        }
    }
}

public class ErrorAlert {
    
    public static var emailer: ReportEmailer?
    
    let reportable: Reportable

    public init(report: Report) {

        precondition(hasValue(ErrorAlert.emailer), "Set ErrorAlert.emailer first.")

        self.reportable = .report(report)
    }

    public init(error: NSError) {
        
        precondition(hasValue(ErrorAlert.emailer), "Set ErrorAlert.emailer first.")

        self.reportable = .error(error)
    }

    /// - parameter instructions: Optional text prepended to the email message used to ask for details. Defaults to `nil`.
    public func displayModal(instructions: String? = nil) {
        
        guard !IsRunningTests else {
            fatalError("ErrorAlert involuntarily used in tests")
        }
        
        let response = alert().runModal()
        
        guard response == .alertFirstButtonReturn else { return }
        guard let emailer = ErrorAlert.emailer else { return }

        reportable.email(emailer: emailer, instructions: instructions)
    }
    
    private func alert() -> NSAlert {
        
        let alert = NSAlert()
        alert.messageText = NSLocalizedString(
            "de.christiantietze.ErrorHandling alert title",
            value: "An unexpected error occured and the operation couldn't be completed.",
            comment: "Alert title text")
        alert.informativeText = NSLocalizedString(
            "de.christiantietze.ErrorHandling alert text",
            value: "The report will not be sent directly. Reporting the error will compose an email draft that you can edit. You can also edit in the text field below.",
            comment: "Description of the reporting procedure")

        let reportButton = alert.addButton(withTitle: NSLocalizedString(
            "de.christiantietze.ErrorHandling report button title",
            value: "Report Problem",
            comment: "Default button to report the error"))
        let cancelButton = alert.addButton(withTitle: NSLocalizedString(
            "de.christiantietze.ErrorHandling cancel button title",
            value: "Ignore and Continue",
            comment: "Cancel button, indicating that the app can continue"))
        cancelButton.keyEquivalent = "."
        cancelButton.keyEquivalentModifierMask = [.command]
        
        alert.accessoryView = scrollableErrorView()
        alert.window.initialFirstResponder = reportButton
        
        return alert
    }
    
    private func scrollableErrorView() -> NSScrollView {
        
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 400, height: 150))
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = NSBorderType.bezelBorder
        scrollView.autoresizingMask = [ .width, .height ]

        let contentSize = scrollView.contentSize
        scrollView.documentView = errorTextView(contentSize: contentSize)
        
        return scrollView
    }
    
    private func errorTextView(contentSize: NSSize) -> NSTextView {
        
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        textView.isVerticallyResizable = true
        textView.isEditable = true
        textView.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        textView.string = "Reported error: \(reportable.localizedDescription)\n\n\(reportable.debugDescription)"
        
        return textView
    }
}
