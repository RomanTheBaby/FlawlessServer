//
//  NSError+Extension.swift
//  TestServer
//
//  Created by Baby on 7/29/18.
//  Copyright © 2018 babyorg. All rights reserved.
//

import Cocoa

extension NSError {
    static func describing(_ description: String) -> NSError {
        return NSError(domain: "com.baby", code: 404, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
