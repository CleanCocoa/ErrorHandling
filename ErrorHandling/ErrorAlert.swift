// Copyright (c) 2015 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import AppKit

let IsRunningTests = NSClassFromString("XCTestCase") != nil

public protocol ReportEmailer {
    
    func email(text: String)
    func email(error: NSError)
}

public class ErrorAlert {
    
    public static var emailer: ReportEmailer?
    
    let error: NSError
    
    public init(error: NSError) {
        
        precondition(hasValue(ErrorAlert.emailer), "Set ErrorAlert.emailer first.")
        
        self.error = error
    }
    
    public func displayModal() {
        
        guard !IsRunningTests else {
            fatalError("ErrorAlert involuntarily used in tests")
        }
        
        let response = alert().runModal()
        
        guard response == NSAlertFirstButtonReturn else {
            return
        }
        
        ErrorAlert.emailer?.email(error)
    }
    
    private func alert() -> NSAlert {
        
        let alert = NSAlert()
        alert.messageText = "An unexpected error occured and the operation couldn't be completed."
        
        let reportButton = alert.addButtonWithTitle("Report Problem")
        alert.addButtonWithTitle("I don't want to help, just go on!")
        
        alert.accessoryView = scrollableErrorView()
        alert.window.initialFirstResponder = reportButton
        
        return alert
    }
    
    private func scrollableErrorView() -> NSScrollView {
        
        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 400, height: 70))
        let contentSize = scrollView.contentSize
        scrollView.hasVerticalScroller = true
        scrollView.borderType = NSBorderType.BezelBorder
        scrollView.autoresizingMask = [ .ViewWidthSizable, .ViewHeightSizable ]
        scrollView.documentView = errorTextView(contentSize)
        
        return scrollView
    }
    
    private func errorTextView(contentSize: NSSize) -> NSTextView {
        
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
        textView.verticallyResizable = true
        textView.editable = false
        textView.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.max)
        textView.textContainer?.widthTracksTextView = true
        
        textView.string = "Reported error: \(error.localizedDescription)\n\n\(error.debugDescription)"
        
        return textView
    }
}
