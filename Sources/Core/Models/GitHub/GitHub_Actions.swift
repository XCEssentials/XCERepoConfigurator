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

import PathKit

//---

public
extension GitHub
{
    enum Actions {}
}

public
extension GitHub.Actions
{
    struct Workflow: ArbitraryNamedTextFile
    {
        // MARK: Type level members

        public
        static
        let relativeDirectoryLocation: Path = [".github", "workflows"]

        // MARK: Instance level members

        public
        let fileContent: IndentedText

        public
        let fileName: String

        public
        var relativeLocation: Path
        {
            return Workflow.relativeDirectoryLocation + "\(fileName).yml"
        }

        // MARK: Initializers

        init(
            fileName: String,
            content: IndentedText
            )
        {
            self.fileName = fileName
            self.fileContent = content
        }
    }
}

// MARK: - Presets

public
extension GitHub.Actions.Workflow
{
    static
    func standard(
        name: String = "CI",
        branches: [String] = ["main", "master"],
        runsOn: String = "macos-latest"
        ) -> GitHub.Actions.Workflow
    {
        let result = IndentedTextBuffer()

        //---

        let branchList = branches
            .map{ "'\($0)'" }
            .joined(separator: ", ")

        result <<< """
            name: \(name)

            "on":
              push:
                branches: [ \(branchList) ]
              pull_request:
                branches: [ \(branchList) ]

            jobs:
              build:
                runs-on: \(runsOn)

                steps:
                  - uses: actions/checkout@v4

                  - name: Build
                    run: swift build -v

                  - name: Run tests
                    run: swift test -v
            """

        //---

        return GitHub.Actions.Workflow(
            fileName: name.lowercased(),
            content: result.content
        )
    }
}

// MARK: - Helpers

public
extension GitHub.Actions.Workflow
{
    func prepare(
        removeSpacesAtEOL: Bool = true,
        removeRepeatingEmptyLines: Bool = true
        ) throws -> PendingTextFile<GitHub.Actions.Workflow>
    {
        return PendingTextFile(
            model: self,
            location: relativeLocation,
            shouldRemoveSpacesAtEOL: removeSpacesAtEOL,
            shouldRemoveRepeatingEmptyLines: removeRepeatingEmptyLines
        )
    }
}

