//
//  NativeTypeConversions.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/18/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import Foundation

public struct JaySON {
    public let json: Any
}

extension JaySON {
    public init(_ dict: NSDictionary) { self.json = dict }
    public init(_ array: NSArray) { self.json = array }
    public init(_ dict: [String: Any]) { self.json = dict }
    public init(_ array: [Any]) { self.json = array }
}

extension JsonValue {

    func toNative() -> Any {
        switch self {
            
        case .Object(let obj):
            var out: [Swift.String: Any] = [:]
            for i in obj { out[i.0] = i.1.toNative() }
            return out
            
        case .Array(let arr):
            return arr.map { $0.toNative() }
            
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
            return NSNull()
        }
    }
}

struct NativeTypeConverter {
    
    func convertPair(k: Any, v: Any) throws -> (String, JsonValue) {
        guard let key = k as? String else { throw Error.KeyIsNotString(k) }
        let value = try self.toJayType(v as Any)
        return (key, value)
    }
    
    func convertDict<T>(dict: [String: T]) throws -> JsonValue? {
        var obj = [String: JsonValue]()
        for i in dict { obj[i.0] = try self.toJayType(i.1) }
        return JsonValue.Object(obj)
    }
    
    func convertArray<T>(array: [T]) throws -> JsonValue? {
        let vals = try array.map { try self.toJayType($0) }
        return JsonValue.Array(vals)
    }
    
    func parseNSArray(array: NSArray) throws -> JsonValue? {
        return try self.convertArray(array.map { $0 as Any })
    }
    
    func parseNSDictionary(dict: NSDictionary) throws -> JsonValue? {
        var dOut = [String: Any]()
        for i in dict {
            //for Linux reasons we must cast into CustomStringConvertible instead of String  
            //revert once bridging works.
            // guard let key = i.key as? String else { throw Error.KeyIsNotString(i.key) }
            guard let key = i.key as? CustomStringConvertible else { throw Error.KeyIsNotString(i.key) }
            let value = i.value as Any
            dOut[key.description] = value
        }
        return try self.convertDict(dOut)
    }
    
    func arrayToJayType(maybeArray: Any) throws -> JsonValue? {
        
        switch maybeArray {
            
        case let a as [Any]: return try self.convertArray(a)
            
            //whenever bridging works properly, we can just keep the above [Any]
            
        case let a as [AnyObject]: return try self.convertArray(a)
        case let a as [String]: return try self.convertArray(a)
        case let a as [Double]: return try self.convertArray(a)
        case let a as [Float]: return try self.convertArray(a)
        case let a as [Int]: return try self.convertArray(a)
        case let a as [Bool]: return try self.convertArray(a)

        case let a as [NSArray]: return try self.convertArray(a)
        case let a as [NSDictionary]: return try self.convertArray(a)
        case let a as [NSNumber]: return try self.convertArray(a)
        case let a as [NSString]: return try self.convertArray(a)
        case let a as [NSNull]: return try self.convertArray(a)
        case let a as [NSObject]: return try self.convertArray(a)

        case let a as NSArray: return try self.parseNSArray(a)
            
        default: return nil
        }
    }
    
    func dictionaryToJayType(maybeDictionary: Any) throws -> JsonValue? {
        
        switch maybeDictionary {
            
        case let d as [String: Any]: return try self.convertDict(d)
            
            //whenever bridging works properly, we can just keep the above [Any]
        case let d as [String: AnyObject]: return try self.convertDict(d)
        case let d as [String: String]: return try self.convertDict(d)
        case let d as [String: Double]: return try self.convertDict(d)
        case let d as [String: Float]: return try self.convertDict(d)
        case let d as [String: Int]: return try self.convertDict(d)
        case let d as [String: Bool]: return try self.convertDict(d)
            
        case let d as [String: NSArray]: return try self.convertDict(d)
        case let d as [String: NSDictionary]: return try self.convertDict(d)
        case let d as [String: NSNumber]: return try self.convertDict(d)
        case let d as [String: NSString]: return try self.convertDict(d)
        case let d as [String: NSNull]: return try self.convertDict(d)
        case let d as [String: NSObject]: return try self.convertDict(d)

        case let d as NSDictionary: return try self.parseNSDictionary(d)

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

            //boolean
        case let bool as BooleanType:
            return JsonValue.Boolean(bool.boolValue ? JsonBoolean.True : JsonBoolean.False)
            
            //number
        case let dbl as FloatingPointType:
            guard let double = Double(String(dbl)) else {
                throw Error.UnsupportedFloatingPointType(dbl)
            }
            return JsonValue.Number(JsonNumber.JsonDbl(double))
        case let int as IntegerType:
            guard let integer = Int(String(int)) else {
                throw Error.UnsupportedIntegerType(int)
            }
            return JsonValue.Number(JsonNumber.JsonInt(integer))
        case let num as NSNumber:
            //if the double value equals the int->double value, let's call it
            //an int. otherwise call it a value.
            if Double(num.intValue) == num.doubleValue {
                return JsonValue.Number(JsonNumber.JsonInt(Int(num.intValue)))
            }
            return JsonValue.Number(JsonNumber.JsonDbl(num.doubleValue))
            
        //string (or anything representable as string that didn't match above)
        case let string as String:
            return JsonValue.String(string)
        case let string as CustomStringConvertible:
            return JsonValue.String(string.description)
            
        default: break
        }
        //nothing matched
        throw Error.UnsupportedType("\(Mirror(reflecting: json))")
    }
}



