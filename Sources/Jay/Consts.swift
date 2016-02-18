//
//  Consts.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Const {
    
    // Structural Characters
    static let BeginArray: JChar        = 0x5b // "["
    static let BeginObject: JChar       = 0x7b // "{"
    static let EndArray: JChar          = 0x5d // "]"
    static let EndObject: JChar         = 0x7d // "}"
    static let NameSeparator: JChar     = 0x3a // ":"
    static let ValueSeparator: JChar    = 0x2c // ","
    
    // Insignificant Whitespace
    static let Space: JChar             = 0x20 // " "
    static let HorizontalTab: JChar     = 0x09 // "\t"
    static let NewLine: JChar           = 0x0a // "\n"
    static let CarriageReturn: JChar    = 0x0d // "\r"
    
    // Literals
    static let False: [JChar]   = [0x66, 0x61, 0x6c, 0x73, 0x65] // "false"
    static let Null: [JChar]    = [0x6e, 0x75, 0x6c, 0x6c] // "null"
    static let True: [JChar]    = [0x74, 0x72, 0x75, 0x65] // "true"
    
    // Special Characters
    static let Minus: JChar             = 0x2d // "-"
    static let Plus: JChar              = 0x2b // "+"
    static let DecimalPoint: JChar      = 0x2e // "."
    
    // Strings
    static let QuotationMark: JChar     = 0x22 // """
    static let ReverseSolidus: JChar    = 0x5c // "\"
    static let Solidus: JChar           = 0x2f // "/"
    static let Backspace: JChar         = 0x08 // "b"
    static let FormFeed: JChar          = 0x0c // "f"
    static let UnicodeStart: JChar      = 0x75 // "u"
    
    static let Escape: JChar            = Const.ReverseSolidus
    
    static let Escaped: Set<JChar> = [
        Const.QuotationMark,
        Const.ReverseSolidus,
        Const.Solidus,
        Const.Backspace,
        Const.FormFeed,
        Const.NewLine,
        Const.CarriageReturn,
        Const.HorizontalTab
    ]
    
    //Convenience Collections
    static let Whitespace: Set<JChar> = [
        Const.Space,
        Const.HorizontalTab,
        Const.NewLine,
        Const.CarriageReturn
    ]
    
    static let Zero: JChar              = 0x30 // "0"
    static let Digits1to9: Set<JChar>   = Set(0x31...0x39) // 1...9
    static let Digits0to9: Set<JChar>   = Const.Digits1to9.union([Const.Zero]) // 0...9
    static let HexLettersUp: Set<JChar> = Set(0x41...0x46) // A...F
    static let HexLettersDo: Set<JChar> = Set(0x61...0x66) // a...f
    static let HexDigits: Set<JChar>    = Const.Digits0to9.union(Const.HexLettersUp).union(Const.HexLettersDo)
    static let Exponent: Set<JChar>     = [0x65, 0x45] // "e", "E"
    
    static let NumberTerminators: Set<JChar> = Const.Whitespace.union([
        Const.EndArray,
        Const.EndObject,
        Const.ValueSeparator
    ])
}

struct StartChars {
    
    static let Object: Set<JChar>   = [Const.BeginObject]
    static let Array: Set<JChar>    = [Const.BeginArray]
    static let Number: Set<JChar>   = Const.Digits0to9.union([Const.Minus])
    static let String: Set<JChar>   = [Const.QuotationMark]
    static let Boolean: Set<JChar>  = [Const.False[0], Const.True[0]]
    static let Null: Set<JChar>     = [Const.Null[0]]
}


