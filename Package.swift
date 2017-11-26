// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Rc2Model",
    products: [
    	.library(name: "Rc2Model", targets: ["Rc2Model"]),
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.7.1"),
    ],
    targets: [
    	.target(name: "Rc2Model", dependencies: ["HeliumLogger"]),
    	.testTarget(name: "Rc2ModelTests", dependencies: ["Rc2Model"])
    ]
)
