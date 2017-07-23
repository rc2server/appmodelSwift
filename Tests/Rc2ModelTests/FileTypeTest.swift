//
//  FileTypeTest.swift
//
//  Copyright ©2017 Mark Lilback. This file is licensed under the ISC license.
//

import XCTest
@testable import Rc2Model

class FileTypeTest: XCTestCase, Rc2TestAdditions {
	var encoder: JSONEncoder!
	var decoder: JSONDecoder!
	
	override func setUp() {
		encoder = createEncoder()
		decoder = createDecoder()
	}
	
	func testRmd() {
		let rmdJson = """
    {
      "Extension": "Rmd",
      "UTTypeIdentifier": "org.r-project.Rmd",
      "Importable": true,
      "Creatable": true,
      "IsSrc": true,
      "Executable": true,
      "IsRMarkdown": true,
      "Name": "R markdown",
      "IsTextFile": true,
      "Description": "R markdown file (.Rmd)",
      "IconName": "Rmd"
    }
"""
		let rmd = try! decoder.decode(FileType.self, from: rmdJson.data(using: .utf8)!)
		XCTAssertTrue(rmd.isImportable)
		XCTAssertTrue(rmd.isSource)
		XCTAssertTrue(rmd.isCreatable)
		XCTAssertTrue(rmd.isExecutable)
		XCTAssertTrue(rmd.isText)
		XCTAssertFalse(rmd.isImage)
		XCTAssertEqual(rmd.name, "R markdown")
		XCTAssertEqual(rmd.rawMimeType, nil)
		XCTAssertEqual(rmd.uti, "org.r-project.Rmd")
		XCTAssertEqual(rmd.details, "R markdown file (.Rmd)")
	}

	static var allTests = [
		("testRmd", testRmd),
		]

}
