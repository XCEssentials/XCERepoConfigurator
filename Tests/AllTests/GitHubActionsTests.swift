import XCTest

import Hamcrest

// @testable
import XCERepoConfigurator

//---

final
class GitHubActionsTests: XCTestCase
{
    // MARK: Type level members

    static
    var allTests = [
        ("testStandardWorkflowDefaults", testStandardWorkflowDefaults),
        ("testStandardWorkflowCustom", testStandardWorkflowCustom)
    ]
}

//---

extension GitHubActionsTests
{
    func testStandardWorkflowDefaults()
    {
        let targetOutput = { """
            name: CI

            "on":
              push:
                branches: [ 'main', 'master' ]
              pull_request:
                branches: [ 'main', 'master' ]

            jobs:
              build:
                runs-on: macos-latest

                steps:
                  - uses: actions/checkout@v4

                  - name: Build
                    run: swift build -v

                  - name: Run tests
                    run: swift test -v
            """
        }()
        .split(separator: "\n")

        //---

        let result = try! GitHub
            .Actions
            .Workflow
            .standard()
            .prepare()
            .content
            .split(separator: "\n")

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }

    func testStandardWorkflowCustom()
    {
        let targetOutput = { """
            name: Build

            "on":
              push:
                branches: [ 'main' ]
              pull_request:
                branches: [ 'main' ]

            jobs:
              build:
                runs-on: ubuntu-latest

                steps:
                  - uses: actions/checkout@v4

                  - name: Build
                    run: swift build -v

                  - name: Run tests
                    run: swift test -v
            """
        }()
        .split(separator: "\n")

        //---

        let result = try! GitHub
            .Actions
            .Workflow
            .standard(
                name: "Build",
                branches: ["main"],
                runsOn: "ubuntu-latest"
            )
            .prepare()
            .content
            .split(separator: "\n")

        //---

        for (i, expected) in targetOutput.enumerated()
        {
            assertThat(expected == result[i])
        }
    }
}

