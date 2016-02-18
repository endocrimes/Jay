//
//  Jay.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

//Implemented from scratch based on http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf and https://www.ietf.org/rfc/rfc4627.txt

public struct Jay {
    
    public init() { }
    
    //Parses data into a dictionary [String: Any] or array [Any].
    //Does not allow fragments. Test by conditional
    //casting whether you received what you expected.
    //Throws a descriptive error in case of any problem.
    public func jsonFromData(data: [UInt8]) throws -> Any {
        return try NativeParser().parse(data)
    }
}



