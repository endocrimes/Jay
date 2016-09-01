//
//  NullParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct NullParser: JsonParser {
    
    var parsing: Jay.ParsingOptions

    func parse<R: Reader>(with reader: R) throws -> JSON {
        
        try prepareForReading(with: reader)
        
        //try to read the "null" literal, throw if anything goes wrong
        try reader.stopAtFirstDifference(ByteReader(content: Const.Null))
        return .null
    }
}
