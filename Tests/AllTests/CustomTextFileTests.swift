import XCTest

import Hamcrest

// @testable
import XCERepoConfigurator

//---

final
class CustomTextFileTests: XCTestCase
{
    // MARK: Type level members

    static
    var allTests = [
        ("testCustomTextFileEmpty", testCustomTextFileEmpty),
        ("testCustomTextFileWithEntries", testCustomTextFileWithEntries)
    ]
}

//---

extension CustomTextFileTests
{
    func testCustomTextFileEmpty()
    {
        let targetOutput = { """
            // empty file

            """
        }()
        .split(separator: "\n", omittingEmptySubsequences: false)

        //---

        let result = try! CustomTextFile()
            .prepare(at: Some.path)
            .content
            .split(separator: "\n", omittingEmptySubsequences: false)

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }

    func testCustomTextFileWithEntries()
    {
        let targetOutput = { """
            line one
            line two
            """
        }()
        .split(separator: "\n")

        //---

        let result = try! CustomTextFile("line one", "line two")
            .prepare(at: Some.path)
            .content
            .split(separator: "\n")

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }
}

