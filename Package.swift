import PackageDescription

let package = Package(
    name: "Jay",
    targets: [
        Target(name: "Jay"),
        Target(name: "JayExample", dependencies: [.Target(name: "Jay")])
    ]
)
