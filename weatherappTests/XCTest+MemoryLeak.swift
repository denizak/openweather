//
//  XCTest+MemoryLeak.swift
//  weatherappTests
//
//  Created by deni zakya on 30/08/23.
//

import Foundation
import XCTest

extension XCTestCase {
    func testMemoryLeak(_ object: AnyObject) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object)
        }
    }
}
