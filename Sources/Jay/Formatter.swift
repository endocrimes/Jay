//
//  Formatter.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/19/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

protocol JsonFormattable {
    func format() throws -> [JChar]
}

extension JsonValue: JsonFormattable {
    
    func format() throws -> [JChar] {
        switch self {
            
            //null
        case .null:
            return Const.Null
            
            //number
        case .number(let num):
            switch num {
            case .integer(let i):
                return String(i).chars()
            case .double(let d):
                return String(d).chars()
            }
            
            //boolean
        case .boolean(let bool):
            return bool ? Const.True : Const.False
            
            //string
        case .string(let str):
            return try self.formatString(str)
            
            //array
        case .array(let arr):
            return try self.formatArray(arr)
            
            //object
        case .object(let obj):
            return try self.formatObject(obj)
        }
    }
    
    func formatString(_ string: String) throws -> [JChar] {
        
        var contents = [JChar]()
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
            
            //nothing to escape, just append byte
            contents.append(c)
        }
        
        //now we have the contents of the string, we need to add
        //quotes before and after
        let out = [Const.QuotationMark] + contents + [Const.QuotationMark]
        return out
    }
    
    func formatArray(_ array: [JsonValue]) throws -> [JChar] {
        
        //join all converted elements and join them with value separator
        let conv = try array.map { try $0.format() }
        let contents = conv
            .joined(separator: [Const.ValueSeparator])
            .flatMap { $0 }
        let out = [Const.BeginArray] + contents + [Const.EndArray]
        return out
    }
    
    func formatObject(_ object: [String: JsonValue]) throws -> [JChar] {
        
        //join all converted name/value pairs and join them with value separator
        //sort first however, to be good citizens
        let pairs = object.sorted { (a, b) -> Bool in a.0 <= b.0 }
        
        let convPairs = try pairs.map { (pair) -> [JChar] in
            let val = try pair.1.format()
            return try self.formatString(pair.0) + [Const.NameSeparator] + val
        }
        let contents = convPairs
            .joined(separator:[Const.ValueSeparator])
            .flatMap { $0 }
        let out = [Const.BeginObject] + contents + [Const.EndObject]
        return out
    }
    
}
