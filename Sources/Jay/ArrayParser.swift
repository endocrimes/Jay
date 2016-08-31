//
//  ArrayParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct ArrayParser: JsonParser {
    
    var parsing: Jay.ParsingOptions

    func parse<R: Reader>(with reader: R) throws -> JSON {
        
        try prepareForReading(with: reader)
        
        //detect opening bracket
        guard reader.curr() == Const.BeginArray else {
            throw JayError.unexpectedCharacter(reader)
        }
        try reader.nextAndCheckNotDone()
        
        //move along, now start looking for values
        try prepareForReading(with: reader)
        
        //check curr value for closing bracket, to handle empty array
        if reader.curr() == Const.EndArray {
            //empty array
            try reader.next()
            return .array([])
        }
        
        //now start scanning for values
        var values = [JSON]()
        let valueParser = ValueParser(parsing: parsing)
        repeat {
            
            //scan for value
            let ret = try valueParser.parse(with: reader)
            values.append(ret)
            
            //scan for either a comma, in which case there must be another
            //value OR for a closing bracket
            try prepareForReading(with: reader)
            switch reader.curr() {
            case Const.EndArray: try reader.next(); return .array(values)
            case Const.ValueSeparator: try reader.next(); break //comma, so another value must come. let the loop repeat.
            default: throw JayError.unexpectedCharacter(reader)
            }
        } while true
    }
}

