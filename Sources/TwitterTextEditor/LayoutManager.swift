//
//  LayoutManager.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

final class LayoutManager: NSLayoutManager {
    private var glyphsCache: [CacheableGlyphs] = []

    override init() {
        super.init()
        super.delegate = self
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - NSLayoutManager

    /*
     UIKit behavior note

     - Confirmed on iOS 13.6 and prior.

     There are UIKit implementations that are replacing `delegate` to do its tasks
     which eventually set it back to original value, such as `sizeThatFits:`.

     Because of these behaviors, we should not refuse to modify `delegate` even if
     the setter is marked as unavailable and it can break a consistency of this
     layout manager implementation.

     - SeeAlso:
       - `-[UITextView _performLayoutCalculation:inSize:]`
     */
    override var delegate: NSLayoutManagerDelegate? {
        get {
            super.delegate
        }
        @available(*, unavailable)
        set {
            if !(newValue is LayoutManager) {
                log(type: .error, "LayoutManager delegate should not be modified to delegate: %@", String(describing: newValue))
            }
            super.delegate = newValue
        }
    }

    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        log(type: .debug, "range: %@, at: %@", NSStringFromRange(glyphsToShow), NSCoder.string(for: origin))

        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)

        // See the inline comment for `delegate`.
        guard delegate is LayoutManager else {
            return
        }
        guard let textStorage = textStorage else {
            return
        }

        guard glyphsToShow.length > 0 else {
            return
        }

        let count = glyphsToShow.length
        var properties = [GlyphProperty](repeating: [], count: count)
        var characterIndexes = [Int](repeating: 0, count: count)
        properties.withUnsafeMutableBufferPointer { props -> Void in
            characterIndexes.withUnsafeMutableBufferPointer { charIndexes -> Void  in
                getGlyphs(in: glyphsToShow,
                          glyphs: nil,
                          properties: props.baseAddress,
                          characterIndexes: charIndexes.baseAddress,
                          bidiLevels: nil)
            }
        }

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()

        if Configuration.shared.isDebugLayoutManagerDrawGlyphsEnabled {
            context.setStrokeColor(UIColor.blue.withAlphaComponent(0.5).cgColor)
            context.setLineDash(phase: 0, lengths: [2, 2])
        }

        // TODO: Measure performance and consider different approach.
        // This scans entire glyph range once.

        let signpostScanGlyphsToShow = signpost(name: "Scan glyphs to show", "length: %d", glyphsToShow.length)
        signpostScanGlyphsToShow.begin()
        for index in 0..<glyphsToShow.length where properties[index].contains(.controlCharacter) {
            let attributes = textStorage.attributes(at: characterIndexes[index], effectiveRange: nil)
            if let suffixedAttachment = attributes[.suffixedAttachment] as? TextAttributes.SuffixedAttachment,
               case .image(let image) = suffixedAttachment.attachment
            {
                let glyphIndex = glyphsToShow.location + index
                let lineFragmentOrigin = lineFragmentRect(forGlyphAt: glyphIndex,
                                                          effectiveRange: nil,
                                                          withoutAdditionalLayout: true).origin
                let locationInLineFragment = location(forGlyphAt: glyphIndex)

                let locationInContext = CGPoint(x: origin.x + lineFragmentOrigin.x + locationInLineFragment.x,
                                                y: origin.y + lineFragmentOrigin.y)
                let bounds = CGRect(origin: locationInContext, size: suffixedAttachment.size)

                if Configuration.shared.isDebugLayoutManagerDrawGlyphsEnabled {
                    context.stroke(bounds, width: 2.0)
                }

                image.draw(in: bounds)
            }
        }
        signpostScanGlyphsToShow.end()

        context.restoreGState()
    }
}

// MARK: - NSLayoutManagerDelegate

extension LayoutManager: NSLayoutManagerDelegate {
    private struct UnsafeBufferGlyphs {
        var count: Int

        var glyphs: UnsafeBufferPointer<CGGlyph>
        var properties: UnsafeBufferPointer<NSLayoutManager.GlyphProperty>
        var characterIndexes: UnsafeBufferPointer<Int>

        init(glyphs: UnsafePointer<CGGlyph>,
             properties: UnsafePointer<NSLayoutManager.GlyphProperty>,
             characterIndexes: UnsafePointer<Int>, count: Int) {
            self.count = count

            self.glyphs = UnsafeBufferPointer(start: glyphs, count: count)
            self.properties = UnsafeBufferPointer(start: properties, count: count)
            self.characterIndexes = UnsafeBufferPointer(start: characterIndexes, count: count)
        }
    }

    private struct MutableGlyphs {
        struct Insertion {
            var index: Int

            var glyph: CGGlyph
            var property: NSLayoutManager.GlyphProperty
            var characterIndex: Int
        }

        private(set) var glyphs: [CGGlyph]
        private(set) var properties: [NSLayoutManager.GlyphProperty]
        private(set) var characterIndexes: [Int]

        init(unsafeBufferGlyphs: UnsafeBufferGlyphs) {
            glyphs = Array(unsafeBufferGlyphs.glyphs)
            properties = Array(unsafeBufferGlyphs.properties)
            characterIndexes = Array(unsafeBufferGlyphs.characterIndexes)
        }

        mutating func insert(_ insertion: Insertion, offset: Int = 0) {
            let index = insertion.index + offset
            glyphs.insert(insertion.glyph, at: index)
            properties.insert(insertion.property, at: index)
            characterIndexes.insert(insertion.characterIndex, at: index)
        }
    }

    private class CacheableGlyphs {
        let glyphs: UnsafeMutableBufferPointer<CGGlyph>
        let properties: UnsafeMutableBufferPointer<NSLayoutManager.GlyphProperty>
        let characterIndexes: UnsafeMutableBufferPointer<Int>

        init(mutableGlyphs: MutableGlyphs) {
            let glyphs = UnsafeMutableBufferPointer<CGGlyph>.allocate(capacity: mutableGlyphs.glyphs.count)
            _ = glyphs.initialize(from: mutableGlyphs.glyphs)
            self.glyphs = glyphs

            let properties = UnsafeMutableBufferPointer<NSLayoutManager.GlyphProperty>.allocate(capacity: mutableGlyphs.properties.count)
            _ = properties.initialize(from: mutableGlyphs.properties)
            self.properties = properties

            let characterIndexes = UnsafeMutableBufferPointer<Int>.allocate(capacity: mutableGlyphs.characterIndexes.count)
            _ = characterIndexes.initialize(from: mutableGlyphs.characterIndexes)
            self.characterIndexes = characterIndexes
        }

        deinit {
            self.glyphs.deallocate()
            self.properties.deallocate()
            self.characterIndexes.deallocate()
        }
    }

    func layoutManager(_ layoutManager: NSLayoutManager,
                       shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>,
                       properties props: UnsafePointer<NSLayoutManager.GlyphProperty>,
                       characterIndexes charIndexes: UnsafePointer<Int>,
                       font aFont: UIFont,
                       forGlyphRange glyphRange: NSRange) -> Int
    {
        guard let textStorage = layoutManager.textStorage else {
            return 0
        }

        let unsafeBufferGlyphs = UnsafeBufferGlyphs(glyphs: glyphs,
                                                    properties: props,
                                                    characterIndexes: charIndexes,
                                                    count: glyphRange.length)

        var sortedInsertions = [MutableGlyphs.Insertion]()
        for index in 0..<unsafeBufferGlyphs.count {
            let characterIndex = unsafeBufferGlyphs.characterIndexes[index]
            let attributes = textStorage.attributes(at: characterIndex, effectiveRange: nil)

            // We can't derive two glyphs from a character that has `NSTextAttachment`.
            // For safely, check if there is no `.attachment` attribute.
            if attributes[.suffixedAttachment] is TextAttributes.SuffixedAttachment,
               attributes[.attachment] == nil
            {
                let insertion = MutableGlyphs.Insertion(index: index + 1,
                                                        glyph: CGGlyph(0),
                                                        property: .controlCharacter,
                                                        characterIndex: characterIndex)
                sortedInsertions.append(insertion)
            }
        }

        if sortedInsertions.isEmpty {
            return 0
        }

        var mutableGlyphs = MutableGlyphs(unsafeBufferGlyphs: unsafeBufferGlyphs)
        var offset = 0
        for insertion in sortedInsertions {
            mutableGlyphs.insert(insertion, offset: offset)
            offset += 1
        }

        let cacheableGlyphs = CacheableGlyphs(mutableGlyphs: mutableGlyphs)

        let mutatedLength = cacheableGlyphs.glyphs.count
        let mutatedGlyphRange = NSRange(location: glyphRange.location, length: mutatedLength)
        assert(glyphRange.length + offset == mutatedGlyphRange.length)

        glyphsCache.append(cacheableGlyphs)
        layoutManager.setGlyphs(cacheableGlyphs.glyphs.baseAddress!,
                                properties: cacheableGlyphs.properties.baseAddress!,
                                characterIndexes: cacheableGlyphs.characterIndexes.baseAddress!,
                                font: aFont,
                                forGlyphRange: mutatedGlyphRange)

        return mutatedGlyphRange.length
    }

    func layoutManager(_ layoutManager: NSLayoutManager,
                       didCompleteLayoutFor textContainer: NSTextContainer?,
                       atEnd layoutFinishedFlag: Bool)
    {
        log(type: .debug, "text container: %@, at end: %@", String(describing: textContainer), String(describing: layoutFinishedFlag))

        // TODO: Verify if it's right timing to release cache.
        glyphsCache = []

        // This is a timing to lay out views in attachments.
        guard let textStorage = layoutManager.textStorage,
              let textContainer = textContainer
        else {
            return
        }

        let glyphsToShow = layoutManager.glyphRange(for: textContainer)

        // Following logic is same as the one in LayoutManager for `drawGlyphs(forGlyphRange:at)`.

        let count = glyphsToShow.length
        var properties = [NSLayoutManager.GlyphProperty](repeating: [], count: count)
        var characterIndexes = [Int](repeating: 0, count: count)
        properties.withUnsafeMutableBufferPointer { props -> Void in
            characterIndexes.withUnsafeMutableBufferPointer { charIndexes -> Void  in
                layoutManager.getGlyphs(in: glyphsToShow,
                                        glyphs: nil,
                                        properties: props.baseAddress,
                                        characterIndexes: charIndexes.baseAddress,
                                        bidiLevels: nil)
            }
        }

        // TODO: Measure performance and consider different approach.
        // This scans entire glyph range once.

        let signpostScanGlyphsToShow = signpost(name: "Scan glyphs to show", "length: %d", glyphsToShow.length)
        signpostScanGlyphsToShow.begin()
        for index in 0..<glyphsToShow.length where properties[index].contains(.controlCharacter) {
            let attributes = textStorage.attributes(at: characterIndexes[index], effectiveRange: nil)
            if let suffixedAttachment = attributes[.suffixedAttachment] as? TextAttributes.SuffixedAttachment,
               case .view(let view, let layoutInTextContainer) = suffixedAttachment.attachment
            {
                let glyphIndex = glyphsToShow.location + index
                let lineFragmentOrigin = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex,
                                                                        effectiveRange: nil,
                                                                        withoutAdditionalLayout: true).origin
                let locationInLineFragment = layoutManager.location(forGlyphAt: glyphIndex)

                let locationInContext = CGPoint(
                    x: lineFragmentOrigin.x + locationInLineFragment.x,
                    y: lineFragmentOrigin.y
                )
                let frame = CGRect(origin: locationInContext, size: suffixedAttachment.size)
                layoutInTextContainer(view, frame)
            }
        }
        signpostScanGlyphsToShow.end()
    }

    func layoutManager(_ layoutManager: NSLayoutManager,
                       shouldUse action: NSLayoutManager.ControlCharacterAction,
                       forControlCharacterAt charIndex: Int) -> NSLayoutManager.ControlCharacterAction
    {
        guard let textStorage = layoutManager.textStorage else {
            return action
        }

        let attributes = textStorage.attributes(at: charIndex, effectiveRange: nil)
        guard attributes[.suffixedAttachment] is TextAttributes.SuffixedAttachment else {
            return action
        }

        // `.whitespace` may not be set always by `NSTypesetter`.
        // This is only for control glyphs inserted by `layoutManager(_:shouldGenerateGlyphs:properties:characterIndexes:font:forGlyphRange:)`.
        return .whitespace
    }

    func layoutManager(_ layoutManager: NSLayoutManager,
                       boundingBoxForControlGlyphAt glyphIndex: Int,
                       for textContainer: NSTextContainer,
                       proposedLineFragment proposedRect: CGRect,
                       glyphPosition: CGPoint,
                       characterIndex charIndex: Int) -> CGRect
    {
        guard let textStorage = layoutManager.textStorage else {
            return .zero
        }

        let attributes = textStorage.attributes(at: charIndex, effectiveRange: nil)
        guard let suffixedAttachment = attributes[.suffixedAttachment] as? TextAttributes.SuffixedAttachment else {
            // Should't reach here.
            // See `layoutManager(_:shouldUse:forControlCharacterAt:)`.
            assertionFailure("Glyphs that have .suffixedAttachment shouldn't be a control glyphs")
            return .zero
        }

        return CGRect(origin: glyphPosition, size: suffixedAttachment.size)
    }
}
