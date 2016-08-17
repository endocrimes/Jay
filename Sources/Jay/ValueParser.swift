//
//  ValueParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ValueParser: JsonParser {
    
    func parse<R: Reader>(with reader: R) throws -> JSON {
        
        try self.prepareForReading(with: reader)
        
        switch reader.curr() {
        case let x where StartChars.Object.contains(x):
            return try ObjectParser().parse(with: reader)
        case let x where StartChars.Array.contains(x):
            return try ArrayParser().parse(with: reader)
        case let x where StartChars.Number.contains(x):
            return try NumberParser().parse(with: reader)
        case let x where StartChars.String.contains(x):
            return try StringParser().parse(with: reader)
        case let x where StartChars.Boolean.contains(x):
            return try BooleanParser().parse(with: reader)
        case let x where StartChars.Null.contains(x):
            return try NullParser().parse(with: reader)
        default:
            throw JayError.unexpectedCharacter(reader)
        }
    }
}
