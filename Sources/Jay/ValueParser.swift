//
//  ValueParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

private let objectParser = ObjectParser()
private let stringParser = StringParser()
private let arrayParser = ArrayParser()
private let numberParser = NumberParser()
private let booleanParser = BooleanParser()
private let nullParser = NullParser()

struct ValueParser: JsonParser {
    
    func parse<R: Reader>(with reader: R) throws -> JSON {
        
        try self.prepareForReading(with: reader)
        
        switch reader.curr() {
        case let x where StartChars.Object.contains(x):
            return try objectParser.parse(with: reader)
        case let x where StartChars.Array.contains(x):
            return try arrayParser.parse(with: reader)
        case let x where StartChars.Number.contains(x):
            return try numberParser.parse(with: reader)
        case let x where StartChars.String.contains(x):
            return try stringParser.parse(with: reader)
        case let x where StartChars.Boolean.contains(x):
            return try booleanParser.parse(with: reader)
        case let x where StartChars.Null.contains(x):
            return try nullParser.parse(with: reader)
        default:
            throw JayError.unexpectedCharacter(reader)
        }
    }
}
