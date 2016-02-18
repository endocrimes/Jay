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
    
    // Special Characters
    static let Minus: CChar             = 0x2d // "-"
    static let Plus: CChar              = 0x2b // "+"
    static let QuotationMark: CChar     = 0x22 // """
    static let DecimalPoint: CChar      = 0x2e // "."
    
    //Convenience Collections
    static let Whitespace: Set<CChar> = [
        Const.Space,
        Const.HorizontalTab,
        Const.NewLine,
        Const.CarriageReturn
    ]
    
    static let Zero: CChar              = 0x30 // "0"
    static let Digits1to9: Set<CChar>   = Set(0x31...0x39) // 1...9
    static let Digits0to9: Set<CChar>   = Const.Digits1to9.union([Const.Zero]) // 0...9
    static let Exponent: Set<CChar>     = [0x65, 0x45] // "e", "E"
    
    static let NumberTerminators: Set<CChar> = Const.Whitespace.union([
        Const.EndArray,
        Const.EndObject,
        Const.ValueSeparator
    ])
}

struct StartChars {
    
    static let Object: Set<CChar>   = [Const.BeginObject]
    static let Array: Set<CChar>    = [Const.BeginArray]
    static let Number: Set<CChar>   = Const.Digits0to9.union([Const.Minus])
    static let String: Set<CChar>   = [Const.QuotationMark]
    static let Boolean: Set<CChar>  = [Const.False[0], Const.True[0]]
    static let Null: Set<CChar>     = [Const.Null[0]]
}


