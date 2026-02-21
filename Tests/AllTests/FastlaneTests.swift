/*
 
 MIT License
 
 Copyright (c) 2018 Maxim Khatskevich
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import XCTest

import PathKit
import Hamcrest

// @testable
import XCERepoConfigurator

//---

final
class FastlaneTests: XCTestCase
{
    // MARK: Type level members

    static
    var allTests = [
        ("testGemName", testGemName),
        ("testFileNames", testFileNames),
        ("testDefaultHeader", testDefaultHeader),
        ("testRequireGemsSingle", testRequireGemsSingle),
        ("testRequireGemsMultipleSorted", testRequireGemsMultipleSorted),
        ("testRequireGemsDeduplication", testRequireGemsDeduplication)
        ]

}

//---

extension FastlaneTests
{
    func testGemName()
    {
        XCTAssertEqual(Fastlane.gemName, "fastlane")
    }
    
    func testFileNames()
    {
        let expectedRelativeLocation: Path = Fastlane.Fastfile.relativeLocation
        let expectedAbsolutePrefixLocation: Path = Some.path + expectedRelativeLocation
        
        assertThat(
            Fastlane
                .Fastfile
                .ForApp
                .relativeLocation
                == expectedRelativeLocation
        )
        
        assertThat(
            Fastlane
                .Fastfile
                .ForLibrary
                .relativeLocation
                == expectedRelativeLocation
        )
        
        assertThat(
            try! Fastlane
                .Fastfile()
                .prepare(
                    at: Some.path
                )
                .location
                == expectedAbsolutePrefixLocation
        )

        assertThat(
            try! Fastlane
                .Fastfile
                .ForApp()
                .prepare(
                    at: Some.path
                )
                .location
                == expectedAbsolutePrefixLocation
        )

        assertThat(
            try! Fastlane
                .Fastfile
                .ForLibrary()
                .prepare(
                    at: Some.path
                )
                .location
            == expectedAbsolutePrefixLocation
        )
    }
    
    func testDefaultHeader()
    {
        let targetOutput = { """
            # Customise this file, documentation can be found here:
            # https://docs.fastlane.tools
            # All available actions: https://docs.fastlane.tools/actions
            # can also be listed using the `fastlane actions` command

            # Change the syntax highlighting to Ruby
            # All lines starting with a # are ignored when running `fastlane`

            # More information about multiple platforms in fastlane: https://docs.fastlane.tools/advanced/lanes/#platform
            # All available actions: https://docs.fastlane.tools/actions

            # By default, fastlane will send which actions are used
            # No personal data is shared, more information on https://docs.fastlane.tools/actions/opt_out_usage/
            # Uncomment the following line to opt out
            # opt_out_usage

            # If you want to automatically update fastlane if a new version is available:
            # update_fastlane

            # This is the minimum version number required.
            # Update this, if you use features of a newer version
            fastlane_version '2.100.0'
            
            """
        }()
        .split(separator: "\n")
        
        //---
        
        let result = try! Fastlane
            .Fastfile()
            .defaultHeader()
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

    func testRequireGemsSingle()
    {
        let result = try! Fastlane
            .Fastfile(enableRequiredGems: true)
            .require("cocoapods")
            .prepare(
                at: Some.path
            )
            .content

        //---

        let lines = result.split(separator: "\n").map(String.init)
        let requireLines = lines.filter { $0.contains("fastlane_require") }

        assertThat(requireLines.count == 1)
        assertThat(requireLines[0] == "fastlane_require 'cocoapods'")
    }

    func testRequireGemsMultipleSorted()
    {
        let result = try! Fastlane
            .Fastfile(enableRequiredGems: true)
            .require("zebra", "apple")
            .prepare(
                at: Some.path
            )
            .content

        //---

        let lines = result.split(separator: "\n").map(String.init)
        let requireLines = lines.filter { $0.contains("fastlane_require") }

        assertThat(requireLines.count == 2)
        assertThat(requireLines[0] == "fastlane_require 'apple'")
        assertThat(requireLines[1] == "fastlane_require 'zebra'")
    }

    func testRequireGemsDeduplication()
    {
        let result = try! Fastlane
            .Fastfile(enableRequiredGems: true)
            .require("cocoapods")
            .require("cocoapods")
            .prepare(
                at: Some.path
            )
            .content

        //---

        let lines = result.split(separator: "\n").map(String.init)
        let requireLines = lines.filter { $0.contains("fastlane_require") }

        assertThat(requireLines.count == 1)
        assertThat(requireLines[0] == "fastlane_require 'cocoapods'")
    }

}

