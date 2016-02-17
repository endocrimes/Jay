//
//  Consts.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Const {
    
    // Structural Characters
    static let BeginArray: CChar        = 0x5b // "["
    static let BeginObject: CChar       = 0x7b // "{"
    static let EndArray: CChar          = 0x5d // "]"
    static let EndObject: CChar         = 0x7d // "}"
    static let NameSeparator: CChar     = 0x3a // ":"
    static let ValueSeparator: CChar    = 0x2c // ","
    
    // Insignificant Whitespace
    static let Space: CChar             = 0x20 // " "
    static let HorizontalTab: CChar     = 0x09 // "\t"
    static let NewLine: CChar           = 0x0a // "\n"
    static let CarriageReturn: CChar    = 0x0d // "\r"
    
    // Literals
    static let False: [CChar]   = [0x66, 0x61, 0x6c, 0x73, 0x65] // "false"
    static let Null: [CChar]    = [0x6e, 0x75, 0x6c, 0x6c] // "null"
    static let True: [CChar]    = [0x74, 0x72, 0x75, 0x65] // "true"
}


