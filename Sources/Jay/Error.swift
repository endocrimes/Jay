//
//  Error.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Error: ErrorType {
    let str: String
    init(_ str: String) {
        self.str = str
    }
}

