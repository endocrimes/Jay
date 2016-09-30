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
  
    /// Construct an instance representing the provided `NSDictionary`.
    public init(_ dict: NSDictionary) { self.json = dict }
  
    /// Construct an instance representing the provided `NSArray`.
    public init(_ array: NSArray) { self.json = array }
  
    /// Construct an instance representing the provided `[String: Any]`-dictionary.
    public init(_ dict: [String: Any]) { self.json = dict }
  
    /// Construct an instance representing the provided `[Any]`-array.
    public init(_ array: [Any]) { self.json = array }
}

extension JSON {

    func toNative() -> Any {
        switch self {
            
        case .object(let obj):
            var out: [Swift.String: Any] = [:]
            for i in obj { out[i.0] = i.1.toNative() }
            return out
            
        case .array(let arr):
            return arr.map { $0.toNative() }
            
        case .number(let num):
            switch num {
            case .double(let dbl): return dbl
            case .integer(let int): return int
            case .unsignedInteger(let uint): return uint
            }
            
        case .string(let str):
            return str
            
        case .boolean(let bool):
            return bool
            
        case .null:
            return NSNull()
        }
    }
}

struct NativeTypeConverter {
    
    func convertPair(k: Any, v: Any) throws -> (String, JSON) {
        guard let key = k as? String else { throw JayError.keyIsNotString(k) }
        let value = try self.toJayType(v as Any)
        return (key, value)
    }
    
    func convertArray(_ array: [Any]) throws -> JSON? {
        let vals = try array.map { try self.toJayType($0) }
        return .array(vals)
    }
    
    func parseNSArray(_ array: NSArray) throws -> JSON? {
        return try self.convertArray(array.map { $0 as Any })
    }

    func parseArray(_ array: [Any]) throws -> JSON? {
        return try self.convertArray(array)
    }
    
    func parseNSDictionary(_ dict: NSDictionary) throws -> JSON? {
        var dOut = [String: Any]()
        for i in dict {
            //for Linux reasons we must cast into CustomStringConvertible instead of String
            //revert once bridging works.
            // guard let key = i.key as? String else { throw Error.KeyIsNotString(i.key) }
            guard let key = i.key as? CustomStringConvertible else { throw JayError.keyIsNotString(i.key) }
            let value = i.value as Any
            dOut[key.description] = value
        }
        return try self.dictionaryToJayType(dOut)
    }

    func parseDictionary(_ dict: [String: Any]) throws -> JSON? {
        return try self.dictionaryToJayType(dict)
    }
    
    func arrayToJayType(_ maybeArray: Any) throws -> JSON? {
        
        let mirror = Mirror(reflecting: maybeArray)
        let childrenValues = mirror.children.map { $0.value }
        return try self.convertArray(childrenValues)
    }
    
    func dictionaryToJayType(_ maybeDictionary: Any) throws -> JSON? {
        
        let mirror = Mirror(reflecting: maybeDictionary)
        let childrenValues = mirror.children.map { $0.value }
        
        var obj = [String: JSON]()
        for i in childrenValues {
            
            let childMirror = Mirror(reflecting: i)
            let children = childMirror.children
            if childMirror.displayStyle == .tuple && children.count == 2 {
                let it = children.makeIterator()
                let maybeKey = it.next()!.value
                guard let key = maybeKey as? String else {
                    throw JayError.keyIsNotString(maybeKey)
                }
                let value = it.next()!.value
                obj[key] = try self.toJayType(value)
            } else {
                throw JayError.unsupportedType(childMirror)
            }
        }
        return .object(obj)
    }
    
    func toJayType(_ js: Any?) throws -> JSON {
        
        guard let json = js else { return .null }
        if json is NSNull { return .null }

        if let nativeDict = json as? [String: Any] {
            guard let dict = try self.parseDictionary(nativeDict) else {
                throw JayError.unsupportedType(nativeDict)
            }
            return dict
        }

        // On OS X, this check also succeeds for [:] dicts, so this check needs
        // to come after the previous one.
        if let nsdict = json as? NSDictionary {
            guard let dict = try self.parseNSDictionary(nsdict) else {
                throw JayError.unsupportedType(nsdict)
            }
            return dict
        }

        if let nativeArray = json as? [Any] {
            guard let array = try self.parseArray(nativeArray) else {
                throw JayError.unsupportedType(nativeArray)
            }
            return array
        }
        
        // On OS X, this check also succeeds for [] arrays, so this check needs
        // to come after the previous one.
        if let nsarray = json as? NSArray {
            guard let array = try self.parseNSArray(nsarray) else {
                throw JayError.unsupportedType(nsarray)
            }
            return array
        }
        
        let mirror = Mirror(reflecting: json)
        
        if mirror.displayStyle == .dictionary {
            guard let dict = try self.dictionaryToJayType(json) else {
                throw JayError.unsupportedType(json)
            }
            return dict
        }
        
        if mirror.displayStyle == .collection {
            guard let array = try self.arrayToJayType(json) else {
                throw JayError.unsupportedType(json)
            }
            return array
        }
        
        switch json {

            //boolean
        case let bool as Bool:
            return .boolean(bool)
            //number
        case let dbl as FloatingPoint:
            guard let double = Double(String(describing: dbl)) else {
                throw JayError.unsupportedFloatingPointType(dbl)
            }
            return .number(.double(double))
        case let int as Int:
            guard let integer = Int(String(int)) else {
                throw JayError.unsupportedIntegerType(int)
            }
            return .number(.integer(integer))
        case let num as NSNumber:
            //if the double value equals the int->double value, let's call it
            //an int. otherwise call it a value.
            if Double(num.intValue) == num.doubleValue {
                return .number(.integer(Int(num.intValue)))
            }
            return .number(.double(num.doubleValue))
        //string (or anything representable as string that didn't match above)
        case let string as String:
            return .string(string)
        case let string as CustomStringConvertible:
            return .string(string.description)
            
        default: break
        }
        //nothing matched
        throw JayError.unsupportedType("\(Mirror(reflecting: json))")
    }
}



