//
//  NativeTypeConversions.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/18/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

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
