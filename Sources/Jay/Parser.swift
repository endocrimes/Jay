//
//  Parser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

struct Parser {
    
    //assuming data [Int8]
    func parseJsonFromData(data: [JChar]) throws -> JsonValue {
        
        //create a reader for this data
        let reader = ByteReader(content: data)
        
        //delegate parsing
        let result = try RootParser().parse(withReader: reader)
        let json = result.0
        var endReader = result.1
        
        //skip whitespace and ensure no more tokens are present, otherwise throw
        endReader.consumeWhitespace()
        guard endReader.isDone() else {
            throw Error.ExtraTokensFound(endReader)
        }
        
        return json
    }
}

protocol JsonParser {
    func parse(withReader r: Reader) throws -> (JsonValue, Reader)
}

extension JsonParser {

    //MARK: Utils
    
    func prepareForReading(withReader r: Reader) throws -> Reader {
        
        var reader = r
        
        //ensure no leading whitespace
        reader.consumeWhitespace()
        
        //if no more chars, then we encountered an unexpected end
        try reader.ensureNotDone()
        
        return reader
    }
}

