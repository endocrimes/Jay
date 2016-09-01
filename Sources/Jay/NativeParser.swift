//
//  NativeParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/18/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

//converts the intermediate Jay types into Swift types

struct NativeParser {
    
    let options: Jay.ParsingOptions
    
    func parse(_ data: [UInt8]) throws -> Any {
        return _postProcess(try Parser(parsing: options).parseJsonFromData(data))
    }
    
    func parse<R: Reader>(_ reader: R) throws -> Any {
        return _postProcess(try Parser(parsing: options).parseJsonFromReader(reader))
    }
    
    private func _postProcess(_ jsonValue: JSON) -> Any {
        //recursively convert into native types
        let native = jsonValue.toNative()
        return native
    }
}


