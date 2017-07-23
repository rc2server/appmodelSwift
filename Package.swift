// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Rc2Model",
    products: [
    	.library(name: "Rc2Model", targets: ["Rc2Model"]),
    ],
    dependencies: [],
    targets: [
    	.target(name: "Rc2Model", dependencies: []),
    	.testTarget(name: "Rc2ModelTests", dependencies: ["Rc2Model"])
    ]
)
