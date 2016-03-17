//
//  Types.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

//A string is a sequence of zero or more Unicode characters.
public typealias JsonString = String

//An object is an unordered collection of zero or more name/value
//pairs, where a name is a string and a value is a string, number,
//boolean, null, object, or array.
public typealias JsonObject = [String: JsonValue]

//An array is an ordered sequence of zero or more values.
public typealias JsonArray = [JsonValue]

typealias JChar = UTF8.CodeUnit

public enum JsonBoolean: JsonString {
    case True = "true"
    case False = "false"
}

public enum JsonNumber {
    case JsonInt(Int)
    case JsonDbl(Double)
}

let JsonNull = "null"

public enum JsonValue {
    case Object(JsonObject)
    case Array(JsonArray)
    case Number(JsonNumber)
    case String(JsonString)
    case Boolean(JsonBoolean)
    case Null
}

// Types with additional metadata attached by parser

public typealias JsonRange = Range<Int>

public typealias ParsedJsonObject = [String: ParsedJsonToken]
public typealias ParsedJsonArray = [ParsedJsonToken]

public enum ParsedJsonValue {
    case Object(ParsedJsonObject)
    case Array(ParsedJsonArray)
    case Number(JsonNumber)
    case String(JsonString)
    case Boolean(JsonBoolean)
    case Null
}

public struct ParsedJsonToken {
    public let value: ParsedJsonValue
    public let range: JsonRange
    
    init(_ value: ParsedJsonValue, _ range: JsonRange) {
        self.value = value
        self.range = range
    }
}



