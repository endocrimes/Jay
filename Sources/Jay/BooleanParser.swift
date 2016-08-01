//
//  BooleanParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct BooleanParser: JsonParser {
    
    static func parse<R: Reader>(with r: Unmanaged<R>) throws -> JSON {
    
        let reader = r.takeUnretainedValue()

        func parseTrue(_ rd: Unmanaged<R>) throws -> JSON {
            //try to read the "true" literal, throw if anything goes wrong
            try rd.takeUnretainedValue().stopAtFirstDifference(ByteReader(content: Const.True))
            return .boolean(true)
        }
        
        func parseFalse(_ rd: Unmanaged<R>) throws -> JSON {
            //try to read the "false" literal, throw if anything goes wrong
            try rd.takeUnretainedValue().stopAtFirstDifference(ByteReader(content: Const.False))
            return .boolean(false)
        }
        
        try self.prepareForReading(with: r)
        
        //find whether we're parsing "true" or "false"
        let char = reader.curr()
        switch char {
        case Const.True[0]: return try parseTrue(r)
        case Const.False[0]: return try parseFalse(r)
        default: throw JayError.unexpectedCharacter(reader)
        }
    }
}
