//
//  RootParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct RootParser: JsonParser {
    
    static func parse<R: Reader>(with r: Unmanaged<R>) throws -> JSON {
        
        let reader = r.takeUnretainedValue()
        
        try self.prepareForReading(with: r)
        
        //the standard doesn't require handling of fragments, so here
        //we'll assume we're only parsing valid structured types (object/array)
        switch reader.curr() {
        case Const.BeginObject:
            return try ObjectParser.parse(with: r)
        case Const.BeginArray:
            return try ArrayParser.parse(with: r)
        default:
            throw JayError.unimplemented("ParseRoot")
        }
    }
}
