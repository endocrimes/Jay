import PackageDescription

let package = Package(
    name: "Jay",
    targets: [
        Target(name: "JayExample", dependencies: ["Jay"])
    ]
)
