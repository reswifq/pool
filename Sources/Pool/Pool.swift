//
//  Pool.swift
//  Reswifq
//
//  Created by Valerio Mazzeo on 26/02/2017.
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

import Foundation
import Dispatch

public enum PoolError: Error {
    case drawTimeOut
}

open class Pool<T> {

    // MARK: Initialization

    /**
     - parameter maxElementCount: Specifies the maximum number of element that the pool can manage.
     - parameter factory: Closure used to create new items for the pool.
     */
    public init(maxElementCount: Int, factory: @escaping () -> T) {
        self.factory = factory
        self.maxElementCount = maxElementCount
        self.semaphore = DispatchSemaphore(value: maxElementCount)
    }

    // MARK: Setting and Getting Attributes

    /// The maximum number of element that the pool can manage.
    public let maxElementCount: Int

    /// Closure used to create new items for the pool.
    public let factory: () -> T

    // MARK: Storage

    var elements = [T]()

    var elementCount = 0

    // MARK: Concurrency Management

    private let queue = DispatchQueue(label: "com.reswifq.Pool")

    private let semaphore: DispatchSemaphore

    // MARK: Accessing Elements

    /**
     It draws an element from the pool.
     This method creates a new element using the instance `factory` until it reaches `maxElementCount`,
     in that case it returns an existing element from the pool or wait until one is available.

     - returns: The first available element from the pool.
     */
    public func draw() throws -> T {

        // when count reaches zero, calls to the semaphore will block
        guard self.semaphore.wait(timeout: .distantFuture) == .success else {
            throw PoolError.drawTimeOut
        }

        var element: T!

        self.queue.sync {

            guard self.elements.isEmpty, self.elementCount < self.maxElementCount else {

                // Use an existing element
                element = self.elements.removeFirst()

                return
            }

            // Create a new element
            element = self.factory()
            self.elementCount += 1
        }

        return element
    }

    /**
     It returns a previously drawn element to the pool.

     - parameter element: The element to put back in the pool.
     */
    public func release(_ element: T, completion: (() -> Void)? = nil) {

        self.queue.async {
            self.elements.append(element)
            self.semaphore.signal()
            completion?()
        }
    }

    deinit {
        for _ in 0..<self.elementCount {
            self.semaphore.signal()
        }
    }
}
