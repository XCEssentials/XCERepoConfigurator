import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BundlerTests.allTests),
        testCase(CustomTextFileTests.allTests),
        testCase(FastlaneTests.allTests),
        testCase(FrameworkConfigExample.allTests),
        testCase(GitHubActionsTests.allTests),
        testCase(GitHubPagesTests.allTests),
        testCase(GitIgnoreTests.allTests),
        testCase(LicenseTests.allTests),
        testCase(ReadMeTests.allTests),
        testCase(SwiftLintTests.allTests),
        testCase(SwiftPMTests.allTests),
        testCase(UtilsTests.allTests),
    ]
}
#endif
