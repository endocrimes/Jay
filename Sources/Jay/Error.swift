//
//  Error.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

enum Error: ErrorType {
    case UnexpectedEnd(Reader)
    case Unimplemented(String)
    case ParseStringFromCharsFailed([CChar])
    case UnexpectedCharacter(CChar)
}

