import XCTest
@testable import Rc2ModelTests

XCTMain([
    testCase(SessionCommandTest.allTests),
    testCase(FileTypeTest.allTests),
])
