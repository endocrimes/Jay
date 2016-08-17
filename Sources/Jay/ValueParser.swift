//
//  ValueParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ValueParser: JsonParser {
    
    func parse(with reader: Reader) throws -> JSON {
        
        try self.prepareForReading(with: reader)
        
        let parser: JsonParser
        switch reader.curr() {
        case let x where StartChars.Object.contains(x):
            parser = ObjectParser()
        case let x where StartChars.Array.contains(x):
            parser = ArrayParser()
        case let x where StartChars.Number.contains(x):
            parser = NumberParser()
        case let x where StartChars.String.contains(x):
            parser = StringParser()
        case let x where StartChars.Boolean.contains(x):
            parser = BooleanParser()
        case let x where StartChars.Null.contains(x):
            parser = NullParser()
        default:
            throw JayError.unexpectedCharacter(reader)
        }
        
        let val = try parser.parse(with: reader)
        return val
    }
}
