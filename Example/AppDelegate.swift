// Copyright (c) 2017 Christian Tietze
//
// See the file LICENSE for copying permission.

import Cocoa
import ErrorHandling

struct AmazingError: Error { }

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var errorMessageTextField: NSTextField!

    @IBAction func raiseError(_ sender: Any) {

        let error = AmazingError()
        let additionalInfo: String? = (!errorMessageTextField.stringValue.isEmpty)
            ? errorMessageTextField.stringValue
            : nil
        let report = Report(
            error: error,
            additionalInfo: additionalInfo)
        ErrorAlert(report: report).displayModal(instructions: "Please tell me what you did, what happened, and what you did expect to happen instead. This helps nail down the problem.\n\n# Original Error #\n")
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        ErrorAlert.emailer = TextEmailer()
    }
}

