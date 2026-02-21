import XCTest

import Hamcrest

// @testable
import XCERepoConfigurator

//---

final
class GitIgnoreTests: XCTestCase
{
    // MARK: Type level members

    static
    var allTests = [
        ("testAppIgnore", testAppIgnore),
        ("testFrameworkIgnoreSourcesIgnored", testFrameworkIgnoreSourcesIgnored),
        ("testFrameworkIgnoreSourcesNotIgnored", testFrameworkIgnoreSourcesNotIgnored)
    ]
}

//---

extension GitIgnoreTests
{
    func testAppIgnore()
    {
        let result = try! Git
            .RepoIgnore
            .app()
            .prepare(
                at: Some.path
            )
            .content

        //---

        // Verify all expected sections are present
        XCTAssertTrue(result.contains("### macOS ###"))
        XCTAssertTrue(result.contains("### Cocoa ###"))
        XCTAssertTrue(result.contains("### Swift Package Manager ###"))
        XCTAssertTrue(result.contains("### Fastlane ###"))
        XCTAssertTrue(result.contains("### Archives Export Path (for apps only) ###"))

        // SPM section: sources NOT ignored by default for app()
        XCTAssertTrue(result.contains("# Packages/"))

        // Archives section present
        XCTAssertTrue(result.contains(".archives"))
    }

    func testFrameworkIgnoreSourcesIgnored()
    {
        let result = try! Git
            .RepoIgnore
            .framework(ignoreDependenciesSources: true)
            .prepare(
                at: Some.path
            )
            .content

        //---

        // SPM section: sources ARE ignored (no # prefix)
        let lines = result.split(separator: "\n").map(String.init)
        let packagesLine = lines.first(where: { $0.hasSuffix("Packages/") })
        XCTAssertNotNil(packagesLine)
        assertThat(packagesLine! == "Packages/")

        // No archives section for framework
        XCTAssertFalse(result.contains("### Archives Export Path (for apps only) ###"))
    }

    func testFrameworkIgnoreSourcesNotIgnored()
    {
        let result = try! Git
            .RepoIgnore
            .framework(ignoreDependenciesSources: false)
            .prepare(
                at: Some.path
            )
            .content

        //---

        // SPM section: sources NOT ignored (has # prefix)
        XCTAssertTrue(result.contains("# Packages/"))

        // No archives section for framework
        XCTAssertFalse(result.contains("### Archives Export Path (for apps only) ###"))
    }
}

