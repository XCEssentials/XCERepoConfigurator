import XCTest

import Hamcrest
import Version

// @testable
import XCERepoConfigurator

//---

final
class SwiftPMTests: XCTestCase
{
    // MARK: Type level members

    static
    var allTests = [
        ("testSingleLibraryMinimal", testSingleLibraryMinimal),
        ("testSingleLibraryWithPlatforms", testSingleLibraryWithPlatforms),
        ("testSingleLibraryWithDependency", testSingleLibraryWithDependency),
        ("testSingleLibraryWithCustomTestTarget", testSingleLibraryWithCustomTestTarget)
    ]
}

//---

extension SwiftPMTests
{
    func testSingleLibraryMinimal()
    {
        let targetOutput = { """
            // swift-tools-version:5.9

            import PackageDescription

            let package = Package(
                name: "MyLib",
                products: [
                    .library(
                        name: "MyLib",
                        targets: [
                            "MyLib"
                        ]
                    ),
                ],
                targets: [
                    .target(
                        name: "MyLib",
                        path: "Sources"
                    ),
                    .testTarget(
                        name: "MyLibAllTests",
                    ),
                ]
            )
            """
        }()
        .split(separator: "\n")

        //---

        let result = SwiftPM
            .PackageManifest
            .singleLibrary(
                name: "MyLib",
                sourcesPath: "Sources"
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

    func testSingleLibraryWithPlatforms()
    {
        let targetOutput = { """
            // swift-tools-version:5.9

            import PackageDescription

            let package = Package(
                name: "MyLib",
                platforms: [
                    .iOS(.v13),
                    .macOS(.v10_15),
                ],
                products: [
                    .library(
                        name: "MyLib",
                        targets: [
                            "MyLib"
                        ]
                    ),
                ],
                targets: [
                    .target(
                        name: "MyLib",
                        path: "Sources"
                    ),
                    .testTarget(
                        name: "MyLibAllTests",
                    ),
                ]
            )
            """
        }()
        .split(separator: "\n")

        //---

        let result = SwiftPM
            .PackageManifest
            .singleLibrary(
                name: "MyLib",
                platforms: [(.iOS, "13.0"), (.macOS, "10.15")],
                sourcesPath: "Sources"
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

    func testSingleLibraryWithDependency()
    {
        let targetOutput = { """
            // swift-tools-version:5.9

            import PackageDescription

            let package = Package(
                name: "MyLib",
                products: [
                    .library(
                        name: "MyLib",
                        targets: [
                            "MyLib"
                        ]
                    ),
                ],
                dependencies: [
                    .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
                ],
                targets: [
                    .target(
                        name: "MyLib",
                        dependencies: [
                            .product(name: "PathKit", package: "PathKit"),
                        ],
                        path: "Sources"
                    ),
                    .testTarget(
                        name: "MyLibAllTests",
                    ),
                ]
            )
            """
        }()
        .split(separator: "\n")

        //---

        let result = SwiftPM
            .PackageManifest
            .singleLibrary(
                name: "MyLib",
                dependencies: [
                    SwiftPM.PackageDependency(
                        url: "https://github.com/kylef/PathKit",
                        from: Version(1, 0, 0)
                    )
                ],
                targetDependencies: [
                    .product(name: "PathKit", package: "PathKit")
                ],
                sourcesPath: "Sources"
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

    func testSingleLibraryWithCustomTestTarget()
    {
        let targetOutput = { """
            // swift-tools-version:5.9

            import PackageDescription

            let package = Package(
                name: "MyLib",
                products: [
                    .library(
                        name: "MyLib",
                        targets: [
                            "MyLib"
                        ]
                    ),
                ],
                targets: [
                    .target(
                        name: "MyLib",
                        path: "Sources"
                    ),
                    .testTarget(
                        name: "CustomTests",
                        path: "Tests/Custom"
                    ),
                ]
            )
            """
        }()
        .split(separator: "\n")

        //---

        let result = SwiftPM
            .PackageManifest
            .singleLibrary(
                name: "MyLib",
                sourcesPath: "Sources",
                testTargetName: "CustomTests",
                testTargetPath: "Tests/Custom"
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

