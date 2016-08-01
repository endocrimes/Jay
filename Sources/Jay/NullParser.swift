//
//  NullParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct NullParser: JsonParser {
    
    static func parse<R: Reader>(with r: Unmanaged<R>) throws -> JSON {
        
        let reader = r.takeUnretainedValue()
        try self.prepareForReading(with: r)
        
        //try to read the "null" literal, throw if anything goes wrong
        try reader.stopAtFirstDifference(ByteReader(content: Const.Null))
        return .null
    }
}
