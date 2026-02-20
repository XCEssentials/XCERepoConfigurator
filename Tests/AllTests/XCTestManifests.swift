import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FastlaneTests.allTests),
        testCase(FrameworkConfigExample.allTests),
        testCase(SwiftLintTests.allTests),
        testCase(UtilsTests.allTests),
    ]
}
#endif
