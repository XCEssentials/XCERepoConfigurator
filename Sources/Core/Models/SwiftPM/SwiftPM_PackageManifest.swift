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

import Version

//---

public
extension SwiftPM
{
    final
    class PackageManifest: FixedNameTextFile
    {
        // MARK: Type level members

        public
        static
        let relativeLocation: Path = ["Package.swift"]

        // MARK: Instance level members

        private
        let toolsVersion: String

        private
        let packageName: String

        private
        var platforms: DeploymentTargets = []

        private
        var products: [(kind: String, name: String, targets: [String])] = []

        private
        var packageDependencies: [SwiftPM.PackageDependency] = []

        private
        var targets: [(kind: String, name: String, deps: [SwiftPM.TargetDependency], path: String?)] = []

        public
        var fileContent: IndentedText
        {
            let result = IndentedTextBuffer()

            result <<< "// swift-tools-version:\(toolsVersion)"
            result <<< ""
            result <<< "import PackageDescription"
            result <<< ""
            result <<< "let package = Package("

            result.indentation.nest {

                result <<< "name: \"\(packageName)\","

                // platforms
                if !platforms.isEmpty
                {
                    result <<< "platforms: ["

                    result.indentation.nest {
                        for platform in platforms
                        {
                            result <<< ".\(platform.platform.spmPlatformId)(.\(spmVersionCase(platform.minimumVersion))),"
                        }
                    }

                    result <<< "],"
                }

                // products
                if !products.isEmpty
                {
                    result <<< "products: ["

                    result.indentation.nest {
                        for product in products
                        {
                            result <<< ".\(product.kind)("

                            result.indentation.nest {
                                result <<< "name: \"\(product.name)\","
                                result <<< "targets: ["

                                result.indentation.nest {
                                    for t in product.targets
                                    {
                                        result <<< "\"\(t)\""
                                    }
                                }

                                result <<< "]"
                            }

                            result <<< "),"
                        }
                    }

                    result <<< "],"
                }

                // dependencies
                if !packageDependencies.isEmpty
                {
                    result <<< "dependencies: ["

                    result.indentation.nest {
                        for dep in packageDependencies
                        {
                            result <<< ".package(url: \"\(dep.url)\", from: \"\(dep.from)\"),"
                        }
                    }

                    result <<< "],"
                }

                // targets
                if !targets.isEmpty
                {
                    result <<< "targets: ["

                    result.indentation.nest {
                        for target in targets
                        {
                            result <<< ".\(target.kind)("

                            result.indentation.nest {
                                result <<< "name: \"\(target.name)\","

                                if !target.deps.isEmpty
                                {
                                    result <<< "dependencies: ["

                                    result.indentation.nest {
                                        for dep in target.deps
                                        {
                                            switch dep
                                            {
                                            case .byName(let name):
                                                result <<< "\"\(name)\","

                                            case .product(let name, let pkg):
                                                result <<< ".product(name: \"\(name)\", package: \"\(pkg)\"),"
                                            }
                                        }
                                    }

                                    result <<< "],"
                                }

                                if let path = target.path
                                {
                                    result <<< "path: \"\(path)\""
                                }
                            }

                            result <<< "),"
                        }
                    }

                    result <<< "]"
                }
            }

            result <<< ")"

            return result.content
        }

        // MARK: Initializers

        public
        init(toolsVersion: String = "5.9", name: String)
        {
            self.toolsVersion = toolsVersion
            self.packageName = name
        }
    }
}


// MARK: - Builder

public
extension SwiftPM.PackageManifest
{
    @discardableResult
    func platforms(_ targets: DeploymentTargets) -> Self
    {
        platforms = targets
        return self
    }

    @discardableResult
    func library(name: String, targets: [String]) -> Self
    {
        products.append(("library", name, targets))
        return self
    }

    @discardableResult
    func executable(name: String, targets: [String]) -> Self
    {
        products.append(("executable", name, targets))
        return self
    }

    @discardableResult
    func dependency(url: String, from: Version) -> Self
    {
        packageDependencies.append(.init(url: url, from: from))
        return self
    }

    @discardableResult
    func target(
        _ name: String,
        dependencies: [SwiftPM.TargetDependency] = [],
        path: String? = nil
        ) -> Self
    {
        targets.append(("target", name, dependencies, path))
        return self
    }

    @discardableResult
    func testTarget(
        _ name: String,
        dependencies: [SwiftPM.TargetDependency] = [],
        path: String? = nil
        ) -> Self
    {
        targets.append(("testTarget", name, dependencies, path))
        return self
    }
}

// MARK: - Presets

public
extension SwiftPM.PackageManifest
{
    static
    func singleLibrary(
        toolsVersion: String = "5.9",
        name: String,
        platforms: DeploymentTargets = [],
        dependencies: [SwiftPM.PackageDependency] = [],
        targetDependencies: [SwiftPM.TargetDependency] = [],
        sourcesPath: String,
        testTargetName: String? = nil,
        testTargetPath: String? = nil,
        testTargetDependencies: [SwiftPM.TargetDependency] = []
        ) -> SwiftPM.PackageManifest
    {
        let resolvedTestTargetName = testTargetName ?? "\(name)AllTests"

        let manifest = SwiftPM.PackageManifest(toolsVersion: toolsVersion, name: name)

        if !platforms.isEmpty
        {
            manifest.platforms(platforms)
        }

        manifest.library(name: name, targets: [name])

        for dep in dependencies
        {
            manifest.dependency(url: dep.url, from: dep.from)
        }

        manifest.target(name, dependencies: targetDependencies, path: sourcesPath)
        manifest.testTarget(resolvedTestTargetName, dependencies: testTargetDependencies, path: testTargetPath)

        return manifest
    }
}

// MARK: - Helpers

public
extension SwiftPM.PackageManifest
{
    func prepare(
        removeSpacesAtEOL: Bool = true,
        removeRepeatingEmptyLines: Bool = true
        ) -> PendingTextFile<SwiftPM.PackageManifest>
    {
        return PendingTextFile(
            model: self,
            location: SwiftPM.PackageManifest.relativeLocation,
            shouldRemoveSpacesAtEOL: removeSpacesAtEOL,
            shouldRemoveRepeatingEmptyLines: removeRepeatingEmptyLines
        )
    }
}

// MARK: - Private helpers

private
func spmVersionCase(_ versionString: String) -> String
{
    // "10.11" → "v10_11", "13.0" → "v13", "7.0" → "v7"
    let components = versionString
        .split(separator: ".")
        .map(String.init)

    // Drop trailing "0" components
    var trimmed = components

    while trimmed.count > 1 && trimmed.last == "0"
    {
        trimmed.removeLast()
    }

    return "v" + trimmed.joined(separator: "_")
}