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
        case .Null:
            return Const.Null
            
            //number
        case .Number(let num):
            switch num {
            case .JsonInt(let i):
                return Swift.String(i).chars()
            case .JsonDbl(let d):
                return Swift.String(d).chars()
            }
            
            //boolean
        case .Boolean(let bool):
            switch bool {
            case .True:
                return Const.True
            case .False:
                return Const.False
            }
            
            //string
        case .String(let str):
            return try self.formatString(str)
            
            //array
        case .Array(let arr):
            return try self.formatArray(arr)
            
            //object
        case.Object(let obj):
            return try self.formatObject(obj)
        }
    }
    
    func formatString(string: JsonString) throws -> [JChar] {
        return try self.formatSwiftString(string)
    }
    
    func formatSwiftString(string: Swift.String) throws -> [JChar] {
        
        var contents = [JChar]()
        for c in string.utf8 {
            
            //if this is an escapable character, escape it
            //first check for specific rules
            if let replacement = Const.EscapingRulesInv[c] {
                contents.appendContentsOf([Const.Escape, replacement])
                continue
            }
            
            //simple escape, just prepend with the escape char
            if Const.SimpleEscaped.contains(c) {
                contents.appendContentsOf([Const.Escape, c])
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
    
    func formatArray(array: JsonArray) throws -> [JChar] {
        
        //join all converted elements and join them with value separator
        let conv = try array.map { try $0.format() }
        let contents = conv
            .joinWithSeparator([Const.ValueSeparator])
            .flatMap { $0 }
        let out = [Const.BeginArray] + contents + [Const.EndArray]
        return out
    }
    
    func formatObject(object: JsonObject) throws -> [JChar] {
        
        //join all converted name/value pairs and join them with value separator
        //sort first however, to be good citizens
        let pairs = object.sort { (a, b) -> Bool in a.0 <= b.0 }
        let convPairs = try pairs.map { (pair) -> [JChar] in
            let val = try pair.1.format()
            return try self.formatSwiftString(pair.0) + [Const.NameSeparator] + val
        }
        let contents = convPairs
            .joinWithSeparator([Const.ValueSeparator])
            .flatMap { $0 }
        let out = [Const.BeginObject] + contents + [Const.EndObject]
        return out
    }
    
}
