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
    
    func convertArray(_ array: [Any]) throws -> JsonValue? {
        let vals = try array.map { try self.toJayType($0) }
        return JsonValue.Array(vals)
    }
    
    func arrayToJayType(_ maybeArray: Any) throws -> JsonValue? {
        
        let mirror = Mirror(reflecting: maybeArray)
        let childrenValues = mirror.children.map { $0.value }
        return try self.convertArray(childrenValues)
    }
    
    func dictionaryToJayType(_ maybeDictionary: Any) throws -> JsonValue? {
        
        let mirror = Mirror(reflecting: maybeDictionary)
        let childrenValues = mirror.children.map { $0.value }
        
        var obj = [String: JsonValue]()
        for i in childrenValues {
            
            let childMirror = Mirror(reflecting: i)
            let children = childMirror.children
            if childMirror.displayStyle == .tuple && children.count == 2 {
                let it = children.makeIterator()
                let maybeKey = it.next()!.value
                guard let key = maybeKey as? String else {
                    throw Error.KeyIsNotString(maybeKey)
                }
                let value = it.next()!.value
                obj[key] = try self.toJayType(value)
            } else {
                throw Error.UnsupportedType(childMirror)
            }
        }
        return JsonValue.Object(obj)
    }
    
    func toJayType(_ js: Any?) throws -> JsonValue {
        
        guard let json = js else { return JsonValue.Null }
        if json is NSNull { return JsonValue.Null }

        let mirror = Mirror(reflecting: json)
        
        if mirror.displayStyle == .dictionary {
            guard let dict = try self.dictionaryToJayType(json) else {
                throw Error.UnsupportedType(json)
            }
            return dict
        }
        
        if mirror.displayStyle == .collection {
            guard let array = try self.arrayToJayType(json) else {
                throw Error.UnsupportedType(json)
            }
            return array
        }
        
        switch json {

            //boolean
        case let bool as Boolean:
            return JsonValue.Boolean(bool.boolValue ? JsonBoolean.True : JsonBoolean.False)
            
            //number
        case let dbl as FloatingPoint:
            guard let double = Double(String(dbl)) else {
                throw Error.UnsupportedFloatingPointType(dbl)
            }
            return JsonValue.Number(JsonNumber.JsonDbl(double))
        case let int as Integer:
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



