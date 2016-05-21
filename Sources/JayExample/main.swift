import Jay
import Foundation

func tryParsing() {

    let data = Array("{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".utf8)
    let exp: [String: Any] = [
        "hello": "wor🇨🇿ld",
        "val": 1234,
        "many": [
            -12.32,
            // null, add NSNull back once we can reliably compare object hierarchies
            "yo"
        ] as [Any],
        "emptyDict": [String:Any](),
        "dict": [
            "arr": [Any]()
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
    let inObj: [String: Any] = ["hola": 9.23, "nums": [1,2,3]]
    let obj: [String: Any] = [
        "hello": "wor🇨🇿ld",
        "val": 1234,
        "many": [
            -12.32,
            NSNull(),
            "yo",
            inObj
        ] as [Any],
        "emptyDict": [String: Any](),
        "dict": [
            "arr": [Int]()
        ] as [String: Any],
        "name": true
    ]

    let dataOut = try! Jay(formatting: .minified).dataFromJson(obj)
    let retStr = try! dataOut.string()

    assert(origStr == retStr, "Mismatch: Expected:\n\(origStr)\nReturned:\n\(retStr)")
    print("Formatting works:")
}

tryFormatting()
tryParsing()






