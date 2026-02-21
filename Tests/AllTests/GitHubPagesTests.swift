import XCTest

import Hamcrest

// @testable
import XCERepoConfigurator

//---

final
class GitHubPagesTests: XCTestCase
{
    // MARK: Type level members

    static
    var allTests = [
        ("testGitHubPagesConfigDefault", testGitHubPagesConfigDefault),
        ("testGitHubPagesConfigCustom", testGitHubPagesConfigCustom)
    ]
}

//---

extension GitHubPagesTests
{
    func testGitHubPagesConfigDefault()
    {
        let targetOutput = { """
            theme: jekyll-theme-cayman
            """
        }()
        .split(separator: "\n")

        //---

        let result = try! GitHub
            .PagesConfig()
            .prepare()
            .content
            .split(separator: "\n")

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }

    func testGitHubPagesConfigCustom()
    {
        let targetOutput = { """
            theme: minima

            foo: bar
            """
        }()
        .split(separator: "\n", omittingEmptySubsequences: false)

        //---

        let result = try! GitHub
            .PagesConfig(themeName: "minima", otherEntries: ["foo: bar"])
            .prepare()
            .content
            .split(separator: "\n", omittingEmptySubsequences: false)

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }
}

