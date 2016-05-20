//
//  Types.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

typealias JChar = UTF8.CodeUnit

public enum JsonValue {
    
    public enum Number {
        case integer(Int)
        case double(Double)
    }

    case object([String: JsonValue])
    case array([JsonValue])
    case number(Number)
    case string(String)
    case boolean(Bool)
    case null
}





