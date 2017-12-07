//
//  PoolTests.swift
//  Reswifq
//
//  Created by Valerio Mazzeo on 18/02/2017.
//  Copyright © 2017 VMLabs Limited. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
import Dispatch
@testable import Pool

class PoolTests: XCTestCase {

    static let allTests = [
        ("testInitialization", testInitialization),
        ("testDraw", testDraw),
        ("testDrawWhenNoElementIsAvailable", testDrawWhenNoElementIsAvailable),
        ("testDrawWithFactoryError", testDrawWithFactoryError),
        ("testRelease", testRelease),
        ("testDeinitAutomaticRelease", testDeinitAutomaticRelease)
    ]

    func testInitialization() {

        let pool = Pool(maxElementCount: 10) { String() }

        XCTAssertEqual(pool.maxElementCount, 10)
    }

    func testDraw() throws {

        let pool = Pool(maxElementCount: 10) { String() }
        _ = try pool.draw()

        XCTAssertEqual(pool.elementCount, 1)
        XCTAssertTrue(pool.elements.isEmpty)
    }

    func testDrawWhenNoElementIsAvailable() throws {

        let pool = Pool(maxElementCount: 1) { String() }
        let element = try pool.draw()

        DispatchQueue.global().async {
            pool.release(element)
        }

        // This should block the main thread
        _ = try pool.draw()


        XCTAssertEqual(pool.elementCount, 1)
        XCTAssertTrue(pool.elements.isEmpty)
    }

    func testDrawWithFactoryError() throws {

        let pool = Pool(maxElementCount: 5) { () -> String in
            throw URLError(.badURL)
        }

        XCTAssertEqual(pool.elementCount, 0)
        XCTAssertTrue(pool.elements.isEmpty)

        XCTAssertThrowsError(try pool.draw(), "factoryError") { error in
            XCTAssertTrue(error is PoolError)
        }

        XCTAssertEqual(pool.elementCount, 0)
        XCTAssertTrue(pool.elements.isEmpty)
    }

    func testRelease() throws {

        let pool = Pool(maxElementCount: 10) { String() }
        let element = try pool.draw()

        let expectation = self.expectation(description: "completion")

        pool.release(element) {
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10.0, handler: nil)

        XCTAssertEqual(pool.elementCount, 1)
        XCTAssertEqual(pool.elements.count, 1)
    }

    func testDeinitAutomaticRelease() throws {

        let pool = Pool(maxElementCount: 2) { String() }
        _ = try pool.draw()
        _ = try pool.draw()

        XCTAssertEqual(pool.elementCount, 2)
        XCTAssertTrue(pool.elements.isEmpty)
    }
}
