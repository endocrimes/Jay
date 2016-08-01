//
//  BooleanParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct BooleanParser: JsonParser {
    
    static func parse<R: Reader>(with reader: R) throws -> JSON {
        
        func parseTrue(_ rd: R) throws -> JSON {
            //try to read the "true" literal, throw if anything goes wrong
            try rd.stopAtFirstDifference(ByteReader(content: Const.True))
            return .boolean(true)
        }
        
        func parseFalse(_ rd: R) throws -> JSON {
            //try to read the "false" literal, throw if anything goes wrong
            try rd.stopAtFirstDifference(ByteReader(content: Const.False))
            return .boolean(false)
        }
        
        try self.prepareForReading(with: reader)
        
        //find whether we're parsing "true" or "false"
        let char = reader.curr()
        switch char {
        case Const.True[0]: return try parseTrue(reader)
        case Const.False[0]: return try parseFalse(reader)
        default: throw JayError.unexpectedCharacter(reader)
        }
    }
}
