//
//  Formatter.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/19/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

protocol JsonFormattable {
    func format(with formatter: Formatter) throws -> [JChar]
}

extension JsonValue: JsonFormattable {
    
    func format(with formatter: Formatter) throws -> [JChar] {
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
            return try self.formatArray(arr, with: formatter)
            
            //object
        case .object(let obj):
            return try self.formatObject(obj, with: formatter)
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
    
    func formatArray(_ array: [JsonValue], with formatter: Formatter) throws -> [JChar] {
        
        if array.count == 0 {
            return [Const.BeginArray, Const.EndArray]
        }

        let nested = formatter.nextLevel()

        //join all converted elements and join them with value separator
        let conv = try array.map { (item) -> [JChar] in
            var out: [JChar] = []
            out += nested.indent()
            out += try item.format(with: nested)
            return out
        }
        let separator = [Const.ValueSeparator] + nested.newline()
        let contents = conv
            .joined(separator: separator)
            .flatMap { $0 }
        var out: [JChar] = []
        out += [Const.BeginArray]
        out += formatter.newline()
        out += contents
        out += formatter.newlineAndIndent()
        out += [Const.EndArray]
        return out
    }
    
    func formatObject(_ object: [String: JsonValue], with formatter: Formatter) throws -> [JChar] {
        
        if object.count == 0 {
            return [Const.BeginObject, Const.EndObject]
        }
        
        //join all converted name/value pairs and join them with value separator
        //sort first however, to be good citizens
        let pairs = object.sorted { (a, b) -> Bool in a.0 <= b.0 }
        
        let nested = formatter.nextLevel()
        let convPairs = try pairs.map { (pair) -> [JChar] in
            let key = try self.formatString(pair.0)
            let val = try pair.1.format(with: nested)
            var out: [JChar] = []
            out += nested.indent()
            out += key
            out += [Const.NameSeparator]
            out += nested.separator()
            out += val
            return out
        }
        let separator = [Const.ValueSeparator] + nested.newline()
        let contents = convPairs
            .joined(separator: separator)
            .flatMap { $0 }
        var out: [JChar] = []
        out += [Const.BeginObject]
        out += formatter.newline()
        out += contents
        out += formatter.newlineAndIndent()
        out += [Const.EndObject]
        return out
    }
    
}
