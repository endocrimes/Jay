//
//  RootParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct RootParser: JsonParser {
    
    func parse<R: Reader>(with reader: R) throws -> JSON {
        
        try prepareForReading(with: reader)
        
        //the standard doesn't require handling of fragments, so here
        //we'll assume we're only parsing valid structured types (object/array)
        let root: JSON
        switch reader.curr() {
        case Const.BeginObject:
            root = try ObjectParser().parse(with: reader)
        case Const.BeginArray:
            root = try ArrayParser().parse(with: reader)
        default:
            throw JayError.unimplemented("ParseRoot")
        }
        return root
    }
}
