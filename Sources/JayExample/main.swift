import Jay

func tryParsing() {

    let data = Array("{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".utf8)
    let exp: JSON = [
        "hello": "wor🇨🇿ld",
        "val": .number(.unsignedInteger(1234)),
        "many": [
            -12.32,
            "yo"
        ],
        "emptyDict": [:],
        "dict": [
            "arr": []
        ],
        "name": true
    ]
    let expStr = "\(exp)"

    let json = try! Jay().jsonFromData(data)
    let retStr = "\(json)"

    assert(expStr == retStr, "Mismatch: Expected:\n\(expStr)\nReturned:\n\(retStr)")
    print("Parsing works")
}

func tryFormatting() {

    let origStr = "{\"dict\":{\"arr\":[]},\"emptyDict\":{},\"hello\":\"wor🇨🇿ld\",\"many\":[-12.32,null,\"yo\",{\"hola\":9.23,\"nums\":[1,2,3]}],\"name\":true,\"val\":1234}"
    let obj: JSON = [
        "hello": "wor🇨🇿ld",
        "val": 1234,
        "many": [
            -12.32,
            nil,
            "yo",
            ["hola": 9.23, "nums": [1,2,3]]
        ],
        "emptyDict": [:],
        "dict": [
            "arr": []
        ],
        "name": true
    ]

    let dataOut = try! Jay(formatting: .minified).dataFromJson(json: obj)
    let retStr = try! dataOut.string()

    assert(origStr == retStr, "Mismatch: Expected:\n\(origStr)\nReturned:\n\(retStr)")
    print("Formatting works:")
}

func tryFormattingToConsole() {
    
    let obj: JSON = [
                                 "hello": "wor🇨🇿ld",
                                 "val": 1234,
                                 "many": [
                                             -12.32,
                                             nil,
                                             "yo",
                                             ["hola": 9.23, "nums": [1,2,3]]
                                    ],
                                 "emptyDict": [:],
                                 "dict": [
                                             "arr": []
                                    ],
                                 "name": true
    ]
    
    let output = ConsoleOutputStream()
    print("Dumping to console:")
    try! Jay(formatting: .prettified).dataFromJson(json: obj, output: output)
}

tryFormatting()
tryParsing()
tryFormattingToConsole()





