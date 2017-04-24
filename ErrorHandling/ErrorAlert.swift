// Copyright (c) 2015 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import AppKit

let IsRunningTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

public protocol ReportEmailer {
    
    func email(text: String)
    func email(error: Error)
    func email(report: Report)
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
        case .error(_):
            return "()"
        case .report(_):
            return "()"
        }
    }

    func email(emailer: ReportEmailer) {
        switch self {
        case .error(let error):
            emailer.email(error: error)
        case .report(let report):
            emailer.email(report: report)
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
    
    public func displayModal() {
        
        guard !IsRunningTests else {
            fatalError("ErrorAlert involuntarily used in tests")
        }
        
        let response = alert().runModal()
        
        guard response == NSAlertFirstButtonReturn else {
            return
        }

        guard let emailer = ErrorAlert.emailer
            else { return }

        reportable.email(emailer: emailer)
    }
    
    private func alert() -> NSAlert {
        
        let alert = NSAlert()
        alert.messageText = "An unexpected error occured and the operation couldn't be completed."
        
        let reportButton = alert.addButton(withTitle: "Report Problem")
        alert.addButton(withTitle: "I don't want to help, just go on!")
        
        alert.accessoryView = scrollableErrorView()
        alert.window.initialFirstResponder = reportButton
        
        return alert
    }
    
    private func scrollableErrorView() -> NSScrollView {
        
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 400, height: 70))
        let contentSize = scrollView.contentSize
        scrollView.hasVerticalScroller = true
        scrollView.borderType = NSBorderType.bezelBorder
        scrollView.autoresizingMask = [ .viewWidthSizable, .viewHeightSizable ]
        scrollView.documentView = errorTextView(contentSize: contentSize)
        
        return scrollView
    }
    
    private func errorTextView(contentSize: NSSize) -> NSTextView {
        
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        textView.isVerticallyResizable = true
        textView.isEditable = false
        textView.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        
        textView.string = "Reported error: \(reportable.localizedDescription)\n\n\(reportable.debugDescription)"
        
        return textView
    }
}
