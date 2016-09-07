//
//  Formatter.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/19/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

protocol JsonFormattable {
    func format(to stream: JsonOutputStream, with formatter: Formatter) throws
}

extension JSON: JsonFormattable {
    
    func format(to stream: JsonOutputStream, with formatter: Formatter) throws {
        switch self {
            
            //null
        case .null:
            stream <<< Const.Null
            
            //number
        case .number(let num):
            switch num {
            case .integer(let i):
                stream <<< String(i).chars()
            case .unsignedInteger(let ui):
                stream <<< String(ui).chars()
            case .double(let d):
                stream <<< String(d).chars()
            }
            
            //boolean
        case .boolean(let bool):
            stream <<< (bool ? Const.True : Const.False)
            
            //string
        case .string(let str):
            try self.format(to: stream, string: str)
            
            //array
        case .array(let arr):
            try self.format(to: stream, array: arr, with: formatter)
            
            //object
        case .object(let obj):
            return try self.format(to: stream, object: obj, with: formatter)
        }
    }
    
    func format(to stream: JsonOutputStream, string: String) throws {
        
        var contents: [JChar] = []
        for c in string.utf8 {
            
            //if this is an escapable character, escape it
            //first check for specific rules
            if let replacement = Const.EscapingRulesInv[c] {
                contents.append(contentsOf: [Const.Escape, replacement])
                continue
            }
            
            //simple escape, just prepend with the escape char
            if Const.SimpleEscaped.contains(c) {
                contents.append(contentsOf: [Const.Escape, c])
                continue
            }
            
            //control character that wasn't escaped above, just convert to 
            //an escaped unicode sequence, i.e. "\u0006" for "ACK"
            if Const.ControlCharacters.contains(c) {
                contents.append(contentsOf: c.controlCharacterHexString())
                continue
            }
            
            //nothing to escape, just append byte
            contents.append(c)
        }
        
        //now we have the contents of the string, we need to add
        //quotes before and after
        stream <<< Const.QuotationMark
        stream <<< contents
        stream <<< Const.QuotationMark
    }
    
    func format(to stream: JsonOutputStream, array: [JSON], with formatter: Formatter) throws {
        
        guard array.count > 0 else {
            stream <<< Const.BeginArray <<< Const.EndArray
            return
        }

        let nested = formatter.nextLevel()
        stream <<< Const.BeginArray <<< formatter.newline()
        for (idx, item) in array.enumerated() {
            if idx > 0 { stream <<< Const.ValueSeparator <<< nested.newline() }
            stream <<< nested.indent()
            try item.format(to: stream, with: nested)
        }
        stream <<< formatter.newlineAndIndent() <<< Const.EndArray
    }
    
    func format(to stream: JsonOutputStream, object: [String: JSON], with formatter: Formatter) throws {
        
        if object.count == 0 {
            stream <<< Const.BeginObject <<< Const.EndObject
            return
        }
        
        //sort first however, to be good citizens
        let pairs = object.sorted { (a, b) -> Bool in a.0 <= b.0 }
        let nested = formatter.nextLevel()

        stream <<< Const.BeginObject <<< formatter.newline()
        
        for (idx, pair) in pairs.enumerated() {
            if idx > 0 { stream <<< Const.ValueSeparator <<< nested.newline() }
            stream <<< nested.indent()
            try self.format(to: stream, string: pair.0)
            stream <<< Const.NameSeparator <<< nested.separator()
            try pair.1.format(to: stream, with: nested)
        }
        
        stream <<< formatter.newlineAndIndent() <<< Const.EndObject
    }
    
}
