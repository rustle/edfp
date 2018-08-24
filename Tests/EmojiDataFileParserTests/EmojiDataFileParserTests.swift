//
//  EmojiDataFileParserTests.swift
//  EmojiDataFileParserTests
//
//  Created by Doug Russell on 8/17/18.
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import XCTest
@testable import EmojiDataFileParser

class EmojiDataFileParserTests: XCTestCase {
    func testParse() {
        guard let url = Bundle(for: EmojiDataFileParserTests.self).url(forResource: "emoji-data",
                                                                       withExtension: "txt") else {
            XCTFail("Unable to load test data from \(Bundle(for: EmojiDataFileParserTests.self)).")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let bitmap = try EmojiDataFileParser.parse(data: data)
            let set = CharacterSet(bitmapRepresentation: bitmap)
            func assert(_ string: String) {
                for scalar in string.unicodeScalars {
                    XCTAssertTrue(set.contains(scalar))
                }
            }
            assert("🎙️")
            assert("🖐️")
            assert("👎🏻")
            assert("🥐")
            assert("🥞")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
