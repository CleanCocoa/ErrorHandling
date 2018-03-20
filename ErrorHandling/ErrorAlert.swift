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
        alert.messageText = "An unexpected error occured and the operation couldn't be completed."
        alert.informativeText = "The report will not be sent directly. Reporting the error will compose an email draft. You can also edit the text below."

        let reportButton = alert.addButton(withTitle: "Report Problem")
        let cancelButton = alert.addButton(withTitle: "I don't want to help, just go on!")
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
