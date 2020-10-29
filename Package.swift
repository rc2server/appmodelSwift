// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Rc2Model",
    products: [
    	.library(name: "Rc2Model", targets: ["Rc2Model"]),
    ],
    dependencies: [
    	.package(url: "https://github.com/apple/swift-log.git", from: "1.1.1"),
//    	.package(url: "https://github.com/Kitura/HeliumLogger.git", from: "1.9.0"),
//		 .package(url: "https://github.com/mlilback/MJLLogger.git", .revision("c38f8d6")),
    ],
    targets: [
    	.target(name: "Rc2Model", dependencies:["Logging"]),
//    	.target(name: "Rc2Model", dependencies: ["MJLLogger"]),
    	.testTarget(name: "Rc2ModelTests", dependencies: ["Rc2Model"])
    ]
)
