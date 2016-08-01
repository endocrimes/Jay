import Jay
import Foundation

func urlForFixture(_ name: String) -> URL {
    let parent = (#file).components(separatedBy: "/").dropLast(3).joined(separator: "/")
    let url = URL(string: "file://\(parent)/Tests/Jay/Fixtures/\(name).json")!
    print("Loading fixture from url \(url)")
    return url
}

func loadFixtureData(_ name: String) throws -> Data {
    let url = urlForFixture(name)
    let data = try Data(contentsOf: url)
    return data
}

func loadFixture(_ name: String) -> [UInt8] {
    let nsdata = try! loadFixtureData(name)
    let data = Array(nsdata)
    return data
}

let data = loadFixture("large")
let nsdata = try loadFixtureData("large")

let jay = Jay()

struct Result {
    var name: String
    let average: Double
    let median: Double
    let total: Double
}

extension Result: CustomStringConvertible {
    var description: String {
        let decimals = Double(1_000_000)
        let unit = Double(1_000)
        func _process(_ num: Double) -> Double { return unit*Double(Int(num*decimals))/decimals }
        let med = _process(median)
        let avg = _process(average)
        return "\(name): median: \(med) ms, average: \(avg) ms"
    }
}

struct Benchmark {
    let name: String
    let block: () throws -> ()
    init(_ name: String, _ block: () throws -> ()) {
        self.name = name
        self.block = block
    }
}

func measure(_ benchmark: Benchmark) throws -> Result {
    let count = 10
    let block = benchmark.block
    var measurements: [Double] = []
    for _ in 1...count {
        let start = Date()
        try block()
        let duration = -start.timeIntervalSinceNow
        measurements.append(duration)
    }
    let sorted = measurements.sorted()
    let median = sorted[count/2]
    let total = sorted.reduce(0, +)
    let average = total / Double(count)
    return Result(name: benchmark.name,
                  average: average,
                  median: median,
                  total: total)
}

// MARK: Benchmarks

let jayJSONParse = Benchmark("Jay - JSON - Parse") { _ = try jay.jsonFromData(data) }
let nsjsonAnyObjectParse = Benchmark("NSJSON - AnyObject - Parse") { _ = try JSONSerialization.jsonObject(with: nsdata, options: []) }

// MARK: Running

var benchmarks: [Benchmark] = [
    jayJSONParse,
    nsjsonAnyObjectParse
]

print("Starting benchmarks")
try benchmarks.forEach { bm in
    let res = try measure(bm)
    print(res)
}
print("Finished benchmarks")




