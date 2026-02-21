import XCTest

import Hamcrest

// @testable
import XCERepoConfigurator

//---

final
class ReadMeTests: XCTestCase
{
    // MARK: Type level members

    static
    var allTests = [
        ("testGitHubLicenseBadge", testGitHubLicenseBadge),
        ("testGitHubTagBadge", testGitHubTagBadge),
        ("testSwiftPMCompatibleBadge", testSwiftPMCompatibleBadge),
        ("testWrittenInSwiftBadge", testWrittenInSwiftBadge),
        ("testStaticShieldsBadge", testStaticShieldsBadge),
        ("testAddRawContent", testAddRawContent),
        ("testMultipleBadgesComposed", testMultipleBadgesComposed),
    ]

}

//---

extension ReadMeTests
{
    func testGitHubLicenseBadge()
    {
        let result = try! ReadMe()
            .addGitHubLicenseBadge(account: "acme", repo: "MyRepo")
            .prepare(at: Some.path)
            .content

        //---

        assertThat(result == "[![GitHub License](https://img.shields.io/github/license/acme/MyRepo.svg?longCache=true)](LICENSE)")
    }

    func testGitHubTagBadge()
    {
        let result = try! ReadMe()
            .addGitHubTagBadge(account: "acme", repo: "MyRepo")
            .prepare(at: Some.path)
            .content

        //---

        assertThat(result == "[![GitHub Tag](https://img.shields.io/github/tag/acme/MyRepo.svg?longCache=true)](https://github.com/acme/MyRepo/tags)")
    }

    func testSwiftPMCompatibleBadge()
    {
        let result = try! ReadMe()
            .addSwiftPMCompatibleBadge()
            .prepare(at: Some.path)
            .content

        //---

        assertThat(result == "[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)")
    }

    func testWrittenInSwiftBadge()
    {
        let result = try! ReadMe()
            .addWrittenInSwiftBadge(version: "5.9")
            .prepare(at: Some.path)
            .content

        //---

        assertThat(result == "[![Written in Swift](https://img.shields.io/badge/Swift-5.9-orange.svg?longCache=true)](https://swift.org)")
    }

    func testStaticShieldsBadge()
    {
        let result = try! ReadMe()
            .addStaticShieldsBadge(
                "Platform",
                status: "macOS",
                color: "blue",
                title: "Platform Badge",
                link: "https://apple.com"
            )
            .prepare(at: Some.path)
            .content

        //---

        assertThat(result == "[![Platform Badge](https://img.shields.io/badge/Platform-macOS-blue.svg?longCache=true)](https://apple.com)")
    }

    func testAddRawContent()
    {
        let result = try! ReadMe()
            .add("# My Project\n\nSome description here.")
            .prepare(at: Some.path)
            .content

        //---

        let lines = result.split(separator: "\n", omittingEmptySubsequences: false)

        assertThat(lines.count == 3)
        assertThat(lines[0] == "# My Project")
        assertThat(lines[1] == "")
        assertThat(lines[2] == "Some description here.")
    }

    func testMultipleBadgesComposed()
    {
        let result = try! ReadMe()
            .addGitHubLicenseBadge(account: "acme", repo: "MyRepo")
            .addGitHubTagBadge(account: "acme", repo: "MyRepo")
            .addSwiftPMCompatibleBadge()
            .prepare(at: Some.path)
            .content

        //---

        let lines = result.split(separator: "\n")

        assertThat(lines.count == 3)
        assertThat(lines[0] == "[![GitHub License](https://img.shields.io/github/license/acme/MyRepo.svg?longCache=true)](LICENSE)")
        assertThat(lines[1] == "[![GitHub Tag](https://img.shields.io/github/tag/acme/MyRepo.svg?longCache=true)](https://github.com/acme/MyRepo/tags)")
        assertThat(lines[2] == "[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)")
    }
}

