import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BundlerTests.allTests),
        testCase(FastlaneTests.allTests),
        testCase(FrameworkConfigExample.allTests),
        testCase(GitHubActionsTests.allTests),
        testCase(GitIgnoreTests.allTests),
        testCase(SwiftLintTests.allTests),
        testCase(SwiftPMTests.allTests),
        testCase(UtilsTests.allTests),
    ]
}
#endif
