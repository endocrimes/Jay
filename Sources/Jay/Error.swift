//
//  Error.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

enum JayError: Swift.Error {
    case unexpectedEnd(Reader)
    case unimplemented(String)
    case parseStringFromCharsFailed([JChar])
    case unexpectedCharacter(Reader)
    case mismatch(Reader, Reader)
    case numberParsingFailed(Reader)
    case invalidUnicodeSpecifier(Reader)
    case invalidEscape(Reader)
    case unescapedControlCharacterInString(Reader)
    case unicodeCharacterParsing([JChar], Reader)
    case invalidSurrogatePair(UInt16, UInt16, Reader)
    case objectNameSeparatorMissing(Reader)
    case failedToConvertIntoNativeType(JSON)
    case unsupportedType(Any)
    case unsupportedFloatingPointType(Any)
    case unsupportedIntegerType(Any)
    case keyIsNotString(Any)
    case extraTokensFound(Reader)
    case invalidUnicodeScalar(UInt16)
    case unterminatedComment(Reader)
}

