import Jay

let data = Array("{\t\"hello\" : \"wor🇨🇿ld\", \n\t \"val\": 1234, \"many\": [\n-12.32, null, \"yo\"\r], \"emptyDict\": {}, \"dict\": {\"arr\":[]}, \"name\": true}".utf8)
let exp: [String: Any] = [
    "hello": "wor🇨🇿ld",
    "val": 1234,
    "many": [Any]([
        -12.32,
        "yo"
        ]),
    "emptyDict": [String:Any](),
    "dict": [
        "arr": [Any]()
        ],
    "name": true
]
let expStr = "\(exp)"

let json = try! Jay().jsonFromData(data)
let retStr = "\(json)"

assert(expStr == retStr)
print("Parsing works")
