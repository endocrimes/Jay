import PackageDescription

let package = Package(
    name: "Jay",
    exclude: [],
    targets: [
        Target(
            name: "Jay"
        ),
        Target(
            name: "JayExample",
            dependencies: [
                .Target(name: "Jay")
            ]
        )
    ]
)
