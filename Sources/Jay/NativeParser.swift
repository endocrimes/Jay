//
//  NativeParser.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/18/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

//converts the intermediate Jay types into Swift types

struct NativeParser {
    
    func parse(data: [UInt8]) throws -> Any {
        
        let jsonValue = try Parser().parseJsonFromData(data)
        
        //recursively convert into native types
        guard let native = jsonValue.toNative() else {
            throw Error.FailedToConvertIntoNativeType(jsonValue)
        }
        
        return native
    }
}


