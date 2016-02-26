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

//with the new swiftpm we have to force it to create a static lib so that we can use it
//from xcode. this will become unnecessary once official xcode+swiftpm support is done.
//watch progress: https://github.com/apple/swift-package-manager/compare/xcodeproj?expand=1

let libJay = Product(name: "Jay", type: .Library(.Dynamic), modules: "Jay")
products.append(libJay)
