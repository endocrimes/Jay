struct CommentParser {
        
    func parse<R: Reader>(with reader: R) throws -> [JChar] {
        
        //ensure we're starting with a slash
        guard reader.curr() == Const.Solidus else {
            throw JayError.unexpectedCharacter(reader)
        }
        try reader.nextAndCheckNotDone()
        
        switch reader.curr() {
            
            //if another slash, it's a single-line comment
        case Const.Solidus:
            return try SingleLineCommentParser().parse(with: reader)
            
            //if a star, it's the beginning of a multi-line comment
        case Const.Star:
            return try MultiLineCommentParser().parse(with: reader)
            
            //if anything else, syntax error
        default:
            throw JayError.unexpectedCharacter(reader)
        }
    }
}

struct SingleLineCommentParser {
    
    func parse<R: Reader>(with reader: R) throws -> [JChar] {
        
        //single line comment starts with "//" and ends with "\n"
        //everything in between is a part of the comment string
        
        //move after the second slash
        try reader.nextAndCheckNotDone()
        
        //keep seeking until we find "\n", then terminate and return everything between
        let end = [Const.NewLine]
        let (collected, _) = try reader.collectUntil(terminator: end)
        
        //here we don't actually care if we don't find the terminator, it just means
        //the user didn't end their file with a newline
        return collected
    }
}

struct MultiLineCommentParser {
    
    func parse<R: Reader>(with reader: R) throws -> [JChar] {

        //multi line comment starts with "/*" and ends with "*/"
        //pretty simple!
        
        //move after the star slash
        try reader.nextAndCheckNotDone()

        //keep seeking until we find "\n", then terminate and return everything between
        let end = [Const.Star, Const.Solidus]
        let (collected, foundTerminator) = try reader.collectUntil(terminator: end)
        
        //multi-line comment must be terminated
        guard foundTerminator else {
            throw JayError.unterminatedComment(reader)
        }
        return collected
    }
}
