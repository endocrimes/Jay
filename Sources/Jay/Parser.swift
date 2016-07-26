//
//  Parser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Parser {
    
    //give any Reader-conforming object
    func parseJsonFromReader(_ reader: Reader) throws -> JSON {
        
        //delegate parsing
        let result = try RootParser().parse(withReader: reader)
        let json = result.0
        var endReader = result.1
        
        if !reader.finishParsingWhenValid() {
            //skip whitespace and ensure no more tokens are present, otherwise throw
            try endReader.consumeWhitespace()
            guard endReader.isDone() else {
                throw JayError.extraTokensFound(endReader)
            }
        }
        
        return json
    }
}

extension Parser {
    
    //assuming data [Int8]
    func parseJsonFromData(_ data: [JChar]) throws -> JSON {
        
        return try parseJsonFromReader(ByteReader(content: data))
    }
}

protocol JsonParser {
    func parse(withReader r: Reader) throws -> (JSON, Reader)
}

extension JsonParser {

    //MARK: Utils
    
    func prepareForReading(withReader r: Reader) throws -> Reader {
        
        var reader = r
        
        //ensure no leading whitespace
        try reader.consumeWhitespace()
        
        //if no more chars, then we encountered an unexpected end
        try reader.ensureNotDone()
        
        return reader
    }
}

