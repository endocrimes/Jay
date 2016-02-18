//
//  Types.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

enum JsonNumber {
    case JsonInt(Int)
    case JsonDbl(Double)
}

//A string is a sequence of zero or more Unicode characters.
typealias JsonString = String

//An object is an unordered collection of zero or more name/value
//pairs, where a name is a string and a value is a string, number,
//boolean, null, object, or array.
typealias JsonObject = [String: JsonValue]

//An array is an ordered sequence of zero or more values.
typealias JsonArray = [JsonValue]

typealias JChar = UTF8.CodeUnit

enum JsonBoolean: JsonString {
    case True = "true"
    case False = "false"
}

let JsonNull = "null"

enum JsonValue {
    case Object(JsonObject)
    case Array(JsonArray)
    case Number(JsonNumber)
    case String(JsonString)
    case Boolean(JsonBoolean)
    case Null
}

enum JsonPrimitiveType {
    case Number(JsonNumber)
    case String(JsonString)
    case Boolean(JsonBoolean)
    case Null
}

enum JsonStructuredType {
    case Object(JsonObject)
    case Array(JsonArray)
}






