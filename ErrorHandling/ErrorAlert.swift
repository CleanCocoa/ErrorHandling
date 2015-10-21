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
        
        let errorDetailsField = NSTextField(frame: NSRect(x: 0, y: 0, width: 400, height: 100))
        errorDetailsField.stringValue = "Reported error: \(error.localizedDescription)\n\n\(error.debugDescription)"
        errorDetailsField.editable = false
        alert.accessoryView = errorDetailsField
        
        alert.window.initialFirstResponder = reportButton
        
        return alert
    }
}
