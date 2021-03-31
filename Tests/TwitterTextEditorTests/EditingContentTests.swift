//
//  EditingContentTests.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import TwitterTextEditor
import XCTest

final class EditingContentTests: XCTestCase {
    func testInitializeWithInvalidRange() {
        XCTAssertThrowsError(try EditingContent(text: "meow", selectedRange: .null))
    }

    func testInitializeWithOutOfSelectedRange() {
        XCTAssertThrowsError(try EditingContent(text: "meow", selectedRange: NSRange(location: 0, length: 5)))
    }

    // MARK: -

    func testUpdateWithNullRequest() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.null

        let updatedContent = try content.update(with: request)
        XCTAssertEqual(content, updatedContent)
    }

    func testUpdateWithText() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.text("purr")

        let updatedContent = try content.update(with: request)
        XCTAssertEqual(updatedContent.text, "purr")
        XCTAssertEqual(updatedContent.selectedRange, .zero)
    }

    func testUpdateWithTextAndOutOfSelectedRange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.text("purr", selectedRange: NSRange(location: 5, length: 0))

        XCTAssertThrowsError(try content.update(with: request))
    }

    func testUpdateWithSubtextAndOutOfReplacingRange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.subtext(range: NSRange(location: 5, length: 0), text: "purr")

        XCTAssertThrowsError(try content.update(with: request))
    }

    func testUpdateWithSubtext() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.subtext(range: .zero, text: "purr")

        let updatedContent = try content.update(with: request)
        XCTAssertEqual(updatedContent.text, "purrmeow")
        XCTAssertEqual(updatedContent.selectedRange, NSRange(location: 4, length: 0))
    }

    func testUpdateWithSubtextAndOutOfSelectedRange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.subtext(range: .zero, text: "purr", selectedRange: NSRange(location: 9, length: 0))

        XCTAssertThrowsError(try content.update(with: request))
    }

    func testUpdateWithSubtextAndSelectedRange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.subtext(range: .zero, text: "purr", selectedRange: NSRange(location: 8, length: 0))

        let updatedContent = try content.update(with: request)
        XCTAssertEqual(updatedContent.text, "purrmeow")
        XCTAssertEqual(updatedContent.selectedRange, NSRange(location: 8, length: 0))
    }

    func testUpdateWithTextAndSelectedRange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.text("purr", selectedRange: NSRange(location: 4, length: 0))

        let updatedContent = try content.update(with: request)
        XCTAssertEqual(updatedContent.text, "purr")
        XCTAssertEqual(updatedContent.selectedRange, NSRange(location: 4, length: 0))
    }

    func testUpdateWithOutOfSelectedRange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.selectedRange(NSRange(location: 5, length: 0))

        XCTAssertThrowsError(try content.update(with: request))
    }

    func testUpdateWithSelectedRange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let request = EditingContent.UpdateRequest.selectedRange(NSRange(location: 4, length: 0))

        let updatedContent = try content.update(with: request)
        XCTAssertEqual(updatedContent.text, "meow")
        XCTAssertEqual(updatedContent.selectedRange, NSRange(location: 4, length: 0))
    }

    // MARK: -

    func testChangeResultWithoutChange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let changedContent = content

        XCTAssertNil(content.changeResult(from: changedContent))
    }

    func testChangeResultWithTextChange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let changedContent = try EditingContent(text: "purr", selectedRange: .zero)

        let changeResult = try XCTUnwrap(content.changeResult(from: changedContent))
        XCTAssertTrue(changeResult.isTextChanged)
        XCTAssertFalse(changeResult.isSelectedRangeChanged)
    }

    func testChangeResultWithSelectedRangeChange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let changedContent = try EditingContent(text: "meow", selectedRange: NSRange(location: 1, length: 0))

        let changeResult = try XCTUnwrap(content.changeResult(from: changedContent))
        XCTAssertFalse(changeResult.isTextChanged)
        XCTAssertTrue(changeResult.isSelectedRangeChanged)
    }

    func testChangeResultWithTextAndSelectedRangeChange() throws {
        let content = try EditingContent(text: "meow", selectedRange: .zero)
        let changedContent = try EditingContent(text: "purr", selectedRange: NSRange(location: 1, length: 0))

        let changeResult = try XCTUnwrap(content.changeResult(from: changedContent))
        XCTAssertTrue(changeResult.isTextChanged)
        XCTAssertTrue(changeResult.isSelectedRangeChanged)
    }
}
