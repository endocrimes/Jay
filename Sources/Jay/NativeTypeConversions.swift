//
//  NativeTypeConversions.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/18/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import Foundation

extension JsonValue {

    func toNative() -> Any? {
        switch self {
            
        case .Object(let obj):
            var out: [Swift.String: Any] = [:]
            for i in obj {
                if let val = i.1.toNative() {
                    out[i.0] = val
                }
            }
            return out
            
        case .Array(let arr):
            var out: [Any] = []
            for i in arr {
                if let val = i.toNative() {
                    out.append(val)
                }
            }
            return out
            
        case .Number(let num):
            switch num {
            case .JsonDbl(let dbl): return dbl
            case .JsonInt(let int): return int
            }
            
        case .String(let str):
            return str
            
        case .Boolean(let bool):
            switch bool {
            case .True: return true
            case .False: return false
            }
            
        case .Null:
            return nil
        }
    }
}

struct NativeTypeConverter {
    
    func convertPair(k: Any, v: Any) throws -> (String, JsonValue) {
        guard let key = k as? String else { throw Error.KeyIsNotString(k) }
        let value = try self.toJayType(v as Any)
        return (key, value)
    }
    
    func convertDict(dict: [String: Any]) throws -> JsonValue? {
        var obj = [String: JsonValue]()
        for i in dict { obj[i.0] = try self.toJayType(i.1) }
        return JsonValue.Object(obj)
    }
    
    func convertArray(array: [Any]) throws -> JsonValue? {
        let vals = try array.map { try self.toJayType($0) }
        return JsonValue.Array(vals)
    }
    
    func parseNSArray(array: NSArray) throws -> JsonValue? {
        return try self.convertArray(array.map { $0 as Any })
    }
    
    func parseNSDictionary(dict: NSDictionary) throws -> JsonValue? {
        var dOut = [String: Any]()
        for i in dict {
            guard let key = i.key as? String else { throw Error.KeyIsNotString(i.key) }
            let value = i.value as Any
            dOut[key] = value
        }
        return try self.convertDict(dOut)
    }
    
    func arrayToJayType<T>(maybeArray: T) throws -> JsonValue? {
        
        switch maybeArray {
            
        case let a as [Any]: return try self.convertArray(a)
            
            //whenever bridging works properly, we can just keep the above [Any]
        case let a as NSArray: return try self.parseNSArray(a)
            
        case let a as [NSArray]: return try self.convertArray(a)
        case let a as [NSDictionary]: return try self.convertArray(a)
        case let a as [NSNumber]: return try self.convertArray(a)
        case let a as [NSString]: return try self.convertArray(a)
        case let a as [NSNull]: return try self.convertArray(a)
        case let a as [String]: return try self.convertArray(a)
        case let a as [Double]: return try self.convertArray(a)
        case let a as [Float]: return try self.convertArray(a)
        case let a as [Int]: return try self.convertArray(a)
        case let a as [Bool]: return try self.convertArray(a)
        default: return nil
        }
    }
    
    func dictionaryToJayType<T>(maybeDictionary: T) throws -> JsonValue? {
        
        switch maybeDictionary {
            
        case let d as [String: Any]: return try self.convertDict(d)
            
            //whenever bridging works properly, we can just keep the above [Any]
        case let d as NSDictionary: return try self.parseNSDictionary(d)
            
        case let d as [String: NSArray]: return try self.convertDict(d)
        case let d as [String: NSDictionary]: return try self.convertDict(d)
        case let d as [String: NSNumber]: return try self.convertDict(d)
        case let d as [String: NSString]: return try self.convertDict(d)
        case let d as [String: NSNull]: return try self.convertDict(d)
        case let d as [String: String]: return try self.convertDict(d)
        case let d as [String: Double]: return try self.convertDict(d)
        case let d as [String: Float]: return try self.convertDict(d)
        case let d as [String: Int]: return try self.convertDict(d)
        case let d as [String: Bool]: return try self.convertDict(d)
        default: return nil
        }
    }
    
    func toJayType(js: Any?) throws -> JsonValue {
        
        guard let json = js else { return JsonValue.Null }
        if json is NSNull { return JsonValue.Null }
        
        if let dict = try self.dictionaryToJayType(json) {
            return dict
        }
        
        if let array = try self.arrayToJayType(json) {
            return array
        }

        switch json {

            //string
        case let string as String:
            return JsonValue.String(string)
            
            //boolean
        case let bool as BooleanType:
            return JsonValue.Boolean(bool.boolValue ? JsonBoolean.True : JsonBoolean.False)
            
            //number
        default:

            //only valid object is an int type or a double type.
            //bc we can't directly match IntegerType and FloatingPointType,
            //wrap them as strings and then try to parse them as int or double.
            //if both fail, then fail.
            
            //number
            let str = String(json)
            if let int = Int(str) {
                return JsonValue.Number(JsonNumber.JsonInt(int))
            }
            if let dbl = Double(str) {
                return JsonValue.Number(JsonNumber.JsonDbl(dbl))
            }
        }
        //nothing matched
        throw Error.UnsupportedType(json)
    }
}



