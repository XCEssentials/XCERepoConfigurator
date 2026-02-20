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

import Foundation
import XCTest

import PathKit
import Hamcrest

@testable
import XCERepoConfigurator

//---

fileprivate
let currentLocation: Path = [
    "Dev",
    "XCEssentials",
    "Pipeline"
]

// let localRepo = try! Spec.LocalRepo.current()

fileprivate
let localRepo = Spec.LocalRepo(
    location: currentLocation,
    context: currentLocation.parent().lastComponentWithoutExtension
)

fileprivate
let remoteRepo = try! Spec.RemoteRepo(
    accountName: localRepo.context,
    name: localRepo.name
)

fileprivate
let company = try! Spec.Company(
    prefix: "XCE",
    name: localRepo.context,
    identifier: "com.\(localRepo.context)",
    developmentTeamId: "XYZ"
)

fileprivate
let project = try! Spec.Project(
    name: localRepo.name,
    summary: "Project summary",
    copyrightYear: 2019,
    deploymentTargets: [
        .iOS : "9.0",
        .watchOS : "3.0",
        .tvOS : "9.0",
        .macOS : "10.11"
    ]
)

//---

final
class FrameworkConfigTests: XCTestCase
{
    // MARK: Type level members
    
    static
    var allTests = [
        ("testLocalRepo", testLocalRepo),
        ("testRemoteRepo", testRemoteRepo),
        ("testCompany", testCompany),
        ("testProject", testProject)
    ]
}

//---

extension FrameworkConfigTests
{
    func testLocalRepo()
    {
        assertThat(localRepo.location == currentLocation)
        assertThat(localRepo.context == currentLocation.parent().lastComponentWithoutExtension)
    }
    
    func testRemoteRepo()
    {
        assertThat(remoteRepo.serverAddress == "https://github.com")
        assertThat(remoteRepo.accountName == localRepo.context)
        assertThat(remoteRepo.name == localRepo.name)
    }
    
    func testCompany()
    {
        assertThat(company.prefix == "XCE")
        assertThat(company.name == localRepo.context)
        assertThat(company.identifier == "com.\(localRepo.context)")
        assertThat(company.developmentTeamId == "XYZ")
    }
    
    func testProject()
    {
        assertThat(project.name == localRepo.name)
        assertThat(project.summary == "Project summary")
        assertThat(project.copyrightYear == 2019)
        assertThat(project.deploymentTargets.count == 4)
        assertThat(project.deploymentTargets.map{ $0.platform }, hasItems(.iOS, .macOS))
        assertThat(project.location == [localRepo.name + "." + Xcode.Project.extension])
    }
    
}
