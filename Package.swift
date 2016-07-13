import PackageDescription

let package = Package(
    name: "Jay",
    targets: [
        Target(name: "JayExample", dependencies: ["Jay"]),
        Target(name: "JayPerformance", dependencies: ["Jay"])
    ],
    dependencies: [
    	.Package(url: "https://github.com/open-swift/C7.git", versions: Version(0,8,0)..<Version(1,0,0))
    ]
)
