import XCTest

import Hamcrest

// @testable
import XCERepoConfigurator

//---

final
class BundlerTests: XCTestCase
{
    // MARK: Type level members

    static
    var allTests = [
        ("testGemfileWithFastlane", testGemfileWithFastlane),
        ("testGemfileWithoutFastlane", testGemfileWithoutFastlane),
        ("testGemfileWithOtherEntry", testGemfileWithOtherEntry)
    ]
}

//---

extension BundlerTests
{
    func testGemfileWithFastlane()
    {
        let targetOutput = { """
            source "https://rubygems.org"

            gem 'fastlane'
            """
        }()
        .split(separator: "\n")

        //---

        let result = try! Bundler
            .Gemfile(basicFastlane: true)
            .prepare(
                at: Some.path
            )
            .content
            .split(separator: "\n")

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }

    func testGemfileWithoutFastlane()
    {
        let targetOutput = { """
            source "https://rubygems.org"
            """
        }()
        .split(separator: "\n")

        //---

        let result = try! Bundler
            .Gemfile(basicFastlane: false)
            .prepare(
                at: Some.path
            )
            .content
            .split(separator: "\n")

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }

    func testGemfileWithOtherEntry()
    {
        let targetOutput = { """
            source "https://rubygems.org"

            gem 'fastlane'
            gem 'cocoapods'
            """
        }()
        .split(separator: "\n")

        //---

        let result = try! Bundler
            .Gemfile(basicFastlane: true, "gem 'cocoapods'")
            .prepare(
                at: Some.path
            )
            .content
            .split(separator: "\n")

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }
}

