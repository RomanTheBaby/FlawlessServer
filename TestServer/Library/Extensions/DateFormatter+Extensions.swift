//
//  DateFormatter+Extensions.swift
//  TestServer
//
//  Created by Baby on 7/29/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

import Cocoa

extension DateFormatter {
    static let MessageDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormats.MessageDate
        return formatter
    }()

    struct DateFormats {
        static let MessageDate = "dd.MM.yy"
    }
}
