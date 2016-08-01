//
//  Parser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import Foundation

struct Parser {
    
    //give any Reader-conforming object
    static func parseJsonFromReader<R: Reader>(_ r: Unmanaged<R>) throws -> JSON {
        
        let reader = r.takeUnretainedValue()
        
        //delegate parsing
        let json = try RootParser.parse(with: r)
        
        if !reader.finishParsingWhenValid() {
            //skip whitespace and ensure no more tokens are present, otherwise throw
            try reader.consumeWhitespace()
            guard reader.isDone() else {
                throw JayError.extraTokensFound(reader)
            }
        }
        
        return json
    }
}

extension Parser {
    
    //assuming data [Int8]
    static func parseJsonFromData(_ data: [JChar]) throws -> JSON {
        let reader = ByteReader(content: data)
        let ref = Unmanaged.passUnretained(reader)
        let json = try parseJsonFromReader(ref)
        return json
    }
}

protocol JsonParser {
    static func parse<R: Reader>(with reader: Unmanaged<R>) throws -> JSON
}

extension JsonParser {

    //MARK: Utils
    
    static func prepareForReading<R: Reader>(with r: Unmanaged<R>) throws {
        
        let reader = r.takeUnretainedValue()
        
        //ensure no leading whitespace
        try reader.consumeWhitespace()
        
        //if no more chars, then we encountered an unexpected end
        try reader.ensureNotDone()
    }
}

