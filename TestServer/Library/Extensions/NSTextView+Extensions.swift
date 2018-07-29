//
//  NSTextView+Extensions.swift
//  TestServer
//
//  Created by Baby on 7/29/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

import Cocoa

extension NSTextView {
    func addMessage(_ message: String) {
        appendAttributedString(NSAttributedString(string: message + "\n"))
    }

    func addErrorMessage(_ message: String) {
        let attrMessage = NSAttributedString(string: message + "\n", attributes: [NSForegroundColorAttributeName: NSColor.red])
        appendAttributedString(attrMessage)
    }

    private func appendAttributedString(_ attrString: NSAttributedString) {
        textStorage?.append(attrString)
        scrollToEndOfDocument(nil)
    }
}
