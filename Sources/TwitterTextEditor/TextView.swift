//
//  TextView.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import CoreFoundation
import Foundation
import MobileCoreServices
import UIKit

/**
 A delegate for handling text input behaviors.
 */
protocol TextViewTextInputDelegate: AnyObject {
    /**
     Delegate callback to ask if text view should accept return text input or not.

     - Parameters:
       - textView: A `TextView` that changed the base writing direction.

     - Returns: `true` if the text view can accept return text input.
     */
    func textViewShouldReturn(_ textView: TextView) -> Bool

    /**
     Delegate callback when the text view changed base writing direction.

     - Parameters:
       - textView: A `TextView` that changed the base writing direction.
       - writingDirection: The current base writing direction.
       - range: A range of text where the base writing direction changed.
     */
    func textView(_ textView: TextView,
                  didChangeBaseWritingDirection writingDirection: NSWritingDirection,
                  forRange range: UITextRange)
}

/**
 A delegate for handling pasting and dropping that extends `UITextPasteDelegate` for `TextView`.
 */
@objc
protocol TextViewTextPasteDelegate: UITextPasteDelegate {
    /**
     Delegate callback to ask if text view can accept the current paste or drop items or not.

     This delegate callback _SHOULD NOT_ be called for paste or drop items which type identifiers
     is not in `pasteConfiguration` acceptable type identifiers.
     if this delegate returns `true`, `textPasteConfigurationSupporting(_:transform:)` _SHOULD_
     be called for each paste or drop item.

     - Parameters:
       - textPasteConfigurationSupporting: The object that received the paste or drop request.
       - itemProviders: A list of `NSItemProvider` for each paste or drop item.

     - Returns: `true` if the text view can accept the current paste or drop items.

     - SeeAlso:
       - `UITextPasteDelegate.textPasteConfigurationSupporting(_:transform:)`
     */
    @objc
    optional func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting,
                                                   canPaste itemProviders: [NSItemProvider]) -> Bool
}

/**
 A base text view.
 */
final class TextView: UITextView {
    private var preferredTextInputModePrimaryLanguage: String?

    /**
     Use given primary language for the preferred text input mode when next time text view becomes
     first responder.

     - Parameters:
        - primaryLanguage: `String` represents a primary language for the preferred text input mode.
        Use `"emoji"` to use Emoji keyboard. Set `nil` to default keyboard.
     */
    func usePreferredTextInputModePrimaryLanguage(_ primaryLanguage: String?) {
        preferredTextInputModePrimaryLanguage = primaryLanguage
    }

    /*
     UIKit bug workaround

     - Confirmed on iOS 13.0 to iOS 13.3.
     - Fixed on iOS 13.4.

     `textInputMode` override is completely ignored on these version of iOS 13 due to bug in
     `-[UIKeyboardImpl recomputeActiveInputModesWithExtensions:allowNonLinguisticInputModes:]`,
     which has a flipped condition check, which doesn't always call `-[UIKeyboardImpl setInputMode:userInitiated:]`.
     To workaround this behavior, return non `nil` identifier from `textInputContextIdentifier`
     to call `-[UIKeyboardImpl setInputMode:userInitiated:]` from `-[UIKeyboardInputModeController _trackInputModeIfNecessary:]`
     and bypass `-[UIKeyboardImpl recomputeActiveInputModesWithExtensions:allowNonLinguisticInputModes:]` call.
     Also need to clean up text input context identifier once it’s used for the bug workaround.

     - SeeAlso:
       - `becomeFirstResponder()`
       - `textInputContextIdentifier`
       - `textInputMode`
     */

    private let shouldWorkaroundTextInputModeBug: Bool = {
        // iOS 13.0 to iOS 13.3
        if #available(iOS 13.0, *) {
            if #available(iOS 13.4, *) {
                return false
            } else {
                return true
            }
        }
        return false
    }()

    /**
     Enable changing text writing direction from user actions.
     Default to `false`.

     - SeeAlso:
       - `canPerformAction(_:withSender:)`
     */
    var changeTextWritingDirectionActionsEnabled: Bool = false

    /**
     A thin cache for observing the paste board.

     This logic is a same logic as how `UITextView` caches if the paste board has
     text that can be pasted.

     - SeeAlso:
       - `-[UITextInputController _pasteboardHasStrings]`.
     */
    private class TextInputPasteboardObserverCache<T> {
        private var cache: (value: T, time: CFAbsoluteTime)?

        private var pasteboardChangedNotificationObserverToken: NotificationObserverToken?
        private var applicationWillEnterForegroundNotificationObserverToken: NotificationObserverToken?

        func invalidate() {
            cache = nil
        }

        func cached(_ block: () -> T) -> T {
            if pasteboardChangedNotificationObserverToken == nil {
                pasteboardChangedNotificationObserverToken =
                    NotificationCenter.default.addObserver(forName: UIPasteboard.changedNotification,
                                                           object: nil,
                                                           queue: nil) { [weak self] _ in
                        self?.cache = nil
                    }
            }
            if applicationWillEnterForegroundNotificationObserverToken == nil {
                applicationWillEnterForegroundNotificationObserverToken =
                    NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                           object: nil,
                                                           queue: nil) { [weak self] _ in
                        self?.cache = nil
                    }
            }

            let now = CFAbsoluteTimeGetCurrent()
            if let cache = cache, now - cache.time < 1.0 {
                return cache.value
            }

            let value = block()
            cache = (value, now)

            return value
        }
    }

    private let pasteboardObserverCache = TextInputPasteboardObserverCache<Bool>()

    override var pasteConfiguration: UIPasteConfiguration? {
        get {
            super.pasteConfiguration
        }
        set {
            super.pasteConfiguration = newValue
            pasteboardObserverCache.invalidate()
        }
    }

    // MARK: - UIResponder

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !changeTextWritingDirectionActionsEnabled,
           action == #selector(makeTextWritingDirectionLeftToRight(_:)) ||
           action == #selector(makeTextWritingDirectionRightToLeft(_:))
        {
            return false
        }

        if super.canPerformAction(action, withSender: sender) {
            return true
        }

        /*
         UIKit behavior workaround

         - Confirmed on iOS 13.6.

         `UITextView`'s default `canPerformAction(_:withSender:)` doesn't use `UIPasteConfigurationSupporting`'s
         `canPaste(_:)` but only for the drop interaction, even if actual `paste(_:)` will use its delegate.

         Basically, it is returns `false` if `-[UIPasteboard hasStrings]` is `false`.
         To accept pasting any acceptable type identifier that allowed in `pasteConfiguration`
         to have a consistent behavior with drag and drop.

         - SeeAlso:
           - `canPaste(_:)`
           - `-[UIResponder canPasteItemProviders:]`
           - `+[UITextInputController _pasteboardHasStrings]`
           - `-[UITextInputController _shouldHandleResponderAction:]`
         */
        if action == #selector(paste(_:)),
           let acceptableTypeIdentifiers = self.pasteConfiguration?.acceptableTypeIdentifiers
        {
            // Using a thin cache to remember the result for same paste board state.
            // This is important because `canPerform(_:withSender:)` is called frequently.
            return pasteboardObserverCache.cached {
                // This is the same logic as default `canPaste(_:)`, which implementation is matching
                // `registeredTypeIdentifiers` and `acceptableTypeIdentifiers` by using `UTTypeConformsTo()`.
                // See `-[UIResponder canPasteItemProviders:]`.
                let isPasteboardConformingAcceptableType =
                    acceptableTypeIdentifiers.contains { acceptableTypeIdentifier in
                        UIPasteboard.general.types.contains { type in
                            UTTypeConformsTo(type as CFString, acceptableTypeIdentifier as CFString)
                        }
                    }
                if isPasteboardConformingAcceptableType {
                    if let delegate = pasteDelegate as? TextViewTextPasteDelegate {
                        let itemProviders = UIPasteboard.general.itemProviders
                        if let result = delegate.textPasteConfigurationSupporting?(self, canPaste: itemProviders) {
                            return result
                        }
                    }
                    return true
                }
                return false
            }
        }

        return false
    }

    private let preferredTextInputModeContextIdentifier = ".TTETwitterTextEditorTextViewPreferredInputModeContextIdentifier"

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            if shouldWorkaroundTextInputModeBug {
                log(type: .debug, "Clear text input context identifier: %@", preferredTextInputModeContextIdentifier)
                UIResponder.clearTextInputContextIdentifier(preferredTextInputModeContextIdentifier)
            }
            preferredTextInputModePrimaryLanguage = nil
        }
        return result
    }

    // MARK: - UIResponder (UIResponderInputViewAdditions)

    override var textInputContextIdentifier: String? {
        if shouldWorkaroundTextInputModeBug, preferredTextInputModePrimaryLanguage != nil {
            log(type: .debug, "Use text input context identifier: %@", preferredTextInputModeContextIdentifier)
            return preferredTextInputModeContextIdentifier
        }

        return super.textInputContextIdentifier
    }

    override var textInputMode: UITextInputMode? {
        if let preferredTextInputModePrimaryLanguage = preferredTextInputModePrimaryLanguage,
           let inputMode = UITextInputMode.activeInputModes.first(where: { inputMode in
               inputMode.primaryLanguage == preferredTextInputModePrimaryLanguage
           })
        {
            log(type: .debug, "Text input mode: %@", inputMode)
            return inputMode
        }

        return super.textInputMode
    }

    // MARK: - UITextInput

    weak var textViewTextInputDelegate: TextViewTextInputDelegate?

    // Only `U+000A` ("\n") is a valid text that return text input insert.
    private let returnTextInputInsertText = "\n"

    override func insertText(_ text: String) {
        if text == returnTextInputInsertText,
           let textViewTextInputDelegate = textViewTextInputDelegate,
           !textViewTextInputDelegate.textViewShouldReturn(self)
        {
            return
        }

        super.insertText(text)
    }

    override func deleteBackward() {
        /*
         UIKit bug workaround

         - Confirmed on iOS 13.7.
         - Confirmed macCatalyst 13.
         - Confirmed on iOS 12.

         On iOS 13 and later, when `isEditable` is `false`, with hardware keyboard delete key
         (not backspace key) `UITextView.deleteBackward()` is called and it actually deletes the content.

         To prevent content is edited while `isEditable` is `false`, override it and do nothing if it's not `true`.
         */
        if #available(iOS 13.0, *) {
            guard isEditable else {
                return
            }
        }

        super.deleteBackward()
    }

    override func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
        super.setBaseWritingDirection(writingDirection, for: range)

        textViewTextInputDelegate?.textView(self, didChangeBaseWritingDirection: writingDirection, forRange: range)
    }

    // MARK: - UIPasteConfigurationSupporting

    override func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
        /*
         UIKit behavior note

         - Confirmed on iOS 13.6.

         This is called only for drop interaction from `dropInteraction:canHandleSession:`
         of the internal `UIDropInteractionDelegate` of `UITextView`, `UITextDragAssistant`.

         `canPaste(_:)` is called first, then other `UITextDropDelegate` delegate callbacks are called
         such as `textDroppableView(_:proposalForDrop:)`.

         - SeeAlso:
           - `-[UITextDragAssistant dropInteraction:canHandleSession:]`
         */

        // This logic is the same logic as for `paste(_:)` action in `canPerformAction(_:withSender:)`.
        // See `-[UIResponder canPasteItemProviders:]`.
        if super.canPaste(itemProviders) {
            if let delegate = pasteDelegate as? TextViewTextPasteDelegate {
                if let result = delegate.textPasteConfigurationSupporting?(self, canPaste: itemProviders) {
                    return result
                }
            }
            return true
        }
        return false
    }

    // MARK: - NSView

#if targetEnvironment(macCatalyst)
    /*
     macCatalyst UIKit behavior workaround

     - Confirmed macCatalyst 13.x and macCatalyst 14 beta
     - see <https://feedbackassistant.apple.com/feedback/FB7351255

     The `tintColor` property from `UITextView` should be sufficient, and is on iOS, but not
     on mac.  This leaves the tintColor white in all cases, and it is thus white-on-white when
     not in dark mode.
     */
    public override var tintColor: UIColor! {
        get {
            super.tintColor
        }
        set {
            super.tintColor = newValue
            if let textInputTraits = value(forKey: "textInputTraits") as? NSObject {
                textInputTraits.setValue(newValue, forKey: "insertionPointColor")
            }
        }
    }
#endif

    // MARK: - UIScrollView

    private let delegateForwarder = TextViewDelegateForwarder()

    var textViewDelegate: UITextViewDelegate? {
        get {
            super.delegate
        }
        set {
            delegateForwarder.textViewDelegate = newValue
            super.delegate = delegateForwarder
        }
    }

    override var delegate: UITextViewDelegate? {
        get {
            super.delegate
        }
        set {
            delegateForwarder.scrollViewDelegate = newValue
            super.delegate = delegateForwarder
        }
    }
}
