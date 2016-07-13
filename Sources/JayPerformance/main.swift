
import Jay
import Foundation
//uses old, optimized Objc Foundation on Foundation, new, Swift Foundation on Linux
//so careful when interpreting results on macOS vs Linux

let runCount = 10

func processMeasurements(_ measurements: [Double]) -> Double {
    let mean = measurements.reduce(0, combine: +) / Double(runCount)
    //TODO: compute std? filter out outliers?
    return mean
}

func measure(_ block: @noescape () throws -> ()) throws -> Double {
    var measurements: [Double] = []
    for _ in 0..<runCount {
        let start = Date()
        try block()
        let dur = -start.timeIntervalSinceNow
        measurements.append(dur)
    }
    return processMeasurements(measurements)
}

func urlForFixture(_ name: String) -> URL {
    let parent = (#file).components(separatedBy: "/").dropLast(3).joined(separator: "/")
    let url = URL(string: "file://\(parent)/Tests/Jay/Fixtures/\(name).json")!
//    print("Loading fixture from url \(url)")
    return url
}

func loadFixture(_ name: String) throws -> [UInt8] {
    let url = urlForFixture(name)
    let data = Array(try String(contentsOf: url).utf8)
    return data
}

func loadFixtureNSData(_ name: String) throws -> Data {
    
    let url = urlForFixture(name)
    let data = try Data(contentsOf: url)
    return data
}

func measureParsing() throws {
    
    func runJay() throws -> Double {
        let data = try loadFixture("large")
        let jay = Jay()
        return try measure {
            _ = try jay.jsonFromData(data)
        }
    }
    
    func runFoundation() throws -> Double {
        let data = try loadFixtureNSData("large")
        return try measure {
            _ = try! JSONSerialization.jsonObject(with: data, options: [])
        }
    }
    
    let resJay = try runJay()
    let resFoundation = try runFoundation()
    let results = [
        "Jay": resJay,
        "Foundation": resFoundation
    ]
    print("Parsing results: \n\(results)")
    print("Foundation is \(resJay / resFoundation) times faster than Jay")
}

func measureFormatting() throws {
    
    func runJay() throws -> Double {
        let data = try loadFixture("large")
        let jay = Jay()
        let json = try jay.jsonFromData(data)
        return try measure {
            _ = try jay.dataFromJson(json: json)
        }
    }
    
    func runFoundation() throws -> Double {
        let data = try loadFixtureNSData("large")
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        return try measure {
            _ = try! JSONSerialization.data(withJSONObject: json, options: [])
        }
    }

    let resJay = try runJay()
    let resFoundation = try runFoundation()
    let results = [
        "Jay": resJay,
        "Foundation": resFoundation
    ]
    print("Formatting results: \n\(results)")
    print("Foundation is \(resJay / resFoundation) times faster than Jay")
}

do {
    try measureParsing()
    try measureFormatting()
} catch {
    print("Error: \(error)")
    exit(1)
}
