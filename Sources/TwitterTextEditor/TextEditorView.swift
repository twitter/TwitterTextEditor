//
//  TextEditorView.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

/**
 A protocol to delegate beginning and ending editing of the text editor view.

 - SeeAlso:
   - `TextEditorView.editingDelegate`
 */
public protocol TextEditorViewEditingDelegate: AnyObject {
    /**
     A delegate method that text editor view asks if it should begin editing or not.

     - Parameters:
       - textEditorView: A delegating `TextEditorView`.

     - Returns: `true` to begin editing, `false` to not.
     */
    func textEditorViewShouldBeginEditing(_ textEditorView: TextEditorView) -> Bool
    /**
     A callback when the text editor view did begin editing.

     - Parameters:
       - textEditorView: A delegating `TextEditorView`.
     */
    func textEditorViewDidBeginEditing(_ textEditorView: TextEditorView)
    /**
     A callback when the text editor view did end editing.

     - Parameters:
       - textEditorView: A delegating `TextEditorView`.
     */
    func textEditorViewDidEndEditing(_ textEditorView: TextEditorView)
}

/**
 A protocol to observe current text input for text editor view.

 The text input is an interface that is representing such as a software or connected hardware keyboard.

 - SeeAlso:
   - `TextEditorView.textInputObserver`
   - `UITextInput`
 */
public protocol TextEditorViewTextInputObserver: AnyObject {
    /**
     A callback when the text input for the text editor view did change primary language.

     - Parameters:
       - textEditorView: A observed `TextEditorView`.
       - inputPrimaryLanguage: The current primary language, such as `en-US`, `ja-JP`, or `dictation`. `nil` if the current input has not primary language.

     - SeeAlso:
       - `UITextInputMode.primaryLanguage`
       - `textEditorView(:didChangeBaseWritingDirection:)`
     */
    func textEditorView(_ textEditorView: TextEditorView,
                        didChangeInputPrimaryLanguage inputPrimaryLanguage: String?)
    /**
     A callback when the text input for the text editor view did change the base writing direction.

     It is called when the primary language that has a different direction but _MAY BE_ called
     by the various user interactions.

     - Parameters:
       - textEditorView: A observed `TextEditorView`.
       - writingDirection: The current base writing direction.

     - SeeAlso:
       - `textEditorView(:didChangeInputPrimaryLanguage:)`
     */
    func textEditorView(_ textEditorView: TextEditorView,
                        didChangeBaseWritingDirection writingDirection: NSWritingDirection)
}

/**
 A protocol that represents an editing content of the text editor view.

 - SeeAlso:
   - `TextEditorViewEditingContentDelegate.textEditorView(_:updateEditingContent:)`
 */
public protocol TextEditorViewEditingContent {
    /**
     A current text editing in `String`.
     */
    var text: String { get }
    /**
     A current selected range in the `text`.

     This range is in UTF-16 scalars of the `text`.
     Therefore, any positions within the surrogate pair scalars are invalid.
     This is intentional because of the underlying UIKit which is using `NSString` as base container.

     - SeeAlso:
       - `NSString`
       - `String.utf16`
     */
    var selectedRange: NSRange { get }
}

/**
 A protocol to delegate updating editing content of text editor view.

 - SeeAlso:
   - `TextEditorView.editingContentDelegate`
 */
public protocol TextEditorViewEditingContentDelegate: AnyObject {
    /**
     A delegate method that text editor view asks to update current editing content.

     Useful to filter specific type of Unicode scalar in `text` or replace specific string pattern to the other.
     Use `NSRange.movedByReplacing(range:length:)` to update `selectedRange`, if needed.

     - Parameters:
       - textEditorView: A delegating `TextEditorView`.
       - editingContent: A current `TextEditorViewEditingContent`.

     - Returns: An updated `TextEditorViewEditingContent` or `nil` if no update is needed.

     - SeeAlso:
       - `NSRange.movedByReplacing(range:length:)`
       - `TextEditorViewEditingContent`
       - `TextEditorViewTextAttributesDelegate.textEditorView(_:updateAttributedString:completion:)`
     */
    func textEditorView(_ textEditorView: TextEditorView,
                        updateEditingContent editingContent: TextEditorViewEditingContent) -> TextEditorViewEditingContent?
}

/**
 A protocol to delegate updating text attributes of text editor view.

 - SeeAlso:
   - `TextEditorView.textAttributesDelegate`
 */
public protocol TextEditorViewTextAttributesDelegate: AnyObject {
    /**
     A delegate method that text editor view asks to update current text attributes.

     Useful to add attributes to the specific string pattern such as syntax highlighting.

     The text editor view only calls this delegate methods only when it is needed.
     If it needs to update text attributes, use `TextEditorView.setNeedsUpdateTextAttributes()`.

     This delegate method can asynchronously update text attributes.
     The delegate method _MUST_ call `completion` eventually.
     This delegate method _MAY BE_ called before previous call is completed by calling `completion`.
     The text editor view always use the latest result and ignore any previous results.

     - Parameters:
       - textEditorView: A delegating `TextEditorView`.
       - attributedString: A current text attributes represented in `NSAttributedString`.
       - completion: A completion handler to return updated text attributes in `NSAttributedString` or `nil` if no update is needed.
         The delegate _SHOULD NOT_ modify `string`, or the update will fail.
         The delegate _MUST_ call this eventually.

     - SeeAlso:
       - `TextEditorView.setNeedsUpdateTextAttributes()`
       - `TextEditorViewTextAttributesDelegate.textEditorView(_:updateEditingContent:)`
     */
    func textEditorView(_ textEditorView: TextEditorView,
                        updateAttributedString attributedString: NSAttributedString,
                        completion: @escaping (NSAttributedString?) -> Void)
}

/**
 A protocol that represents a text editor view change.

 - SeeAlso:
   - `TextEditorViewChangeObserver.textEditorView(_:didChangeWithChangeResult:)`
 */
public protocol TextEditorViewChangeResult {
    /**
     The `text` is changed.

     - SeeAlso:
       - `TextEditorView.text`
     */
    var isTextChanged: Bool { get }
    /**
     The `selectedRange` is changed.

     - SeeAlso:
       - `TextEditorView.selectedRange`
     */
    var isSelectedRangeChanged: Bool { get }
}

/**
 A protocol to observe text editor view changes.

 - SeeAlso:
   - `TextEditorView.changeObserver`
 */
public protocol TextEditorViewChangeObserver: AnyObject {
    /**
     A callback when the text editor view is changed by the user interactions
     such as typing characters by the keyboard, pasting text or drag the cursor position.

     This callback _SHOULD NOT BE_ called when text editor view editing content is changed explicitly by the API call,
     such as `TextEditorView.text`, or `TextEditorView.updateByReplacing(range:with:selectedRange:)`.

     - Parameters:
       - textEditorView: A observed `TextEditorView`.
       - changeResult: A change in `TextEditorViewChangeResult`.

     - SeeAlso:
       - `TextEditorView.text`
       - `TextEditorView.selectedRange`
       - `TextEditorView.updateByReplacing(range:with:selectedRange:)`
     */
    func textEditorView(_ textEditorView: TextEditorView,
                        didChangeWithChangeResult changeResult: TextEditorViewChangeResult)
}

/**
 A protocol for paste observer to complete transforming the pasting or dropping item.
 Similar to `UITextPasteItem` methods to set results.

 - SeeAlso:
   - `UITextPasteItem`
   - `TextEditorViewPasteObserver.transformItemProvider(_:completion:)`
 */
public protocol TextEditorViewPasteObserverTransformCompletion {
    /**
     The paste observer has completed transforming the pasting or dropping item and no other transforms are needed.

     Same as `UITextPasteItem.setNoResult()`.

     - SeeAlso:
       - `UITextPasteItem.setNoResult()`
     */
    func transformed()
    /**
     The paste observer has completed transforming the pasting or dropping item to the string
     to be pasted or dropped in the text editor view.

     Same as `UITextPasteItem.setResult(string:)`

     - SeeAlso:
       - `UITextPasteItem.setResult(string:)`
     */
    func transformed(to string: String)
    /**
     The paste observer has not transformed and the other transforms are needed.

     Same as `UITextPasteItem.setDefaultResult()`

     - SeeAlso:
       - `UITextPasteItem.setDefaultResult()`
     */
    func noTransform()
}

/**
 A protocol to observe the text editor view for pasting or dropping items of specific type identifiers.

 - SeeAlso:
   - `TextEditorView.pasteObservers`
 */
public protocol TextEditorViewPasteObserver: AnyObject {
    /**
     Returns type identifiers of pasting and dropping item that this observer wants to accept and transform.
     Use `NSItemProviderReading.readableTypeIdentifiersForItemProvider` for the type identifiers for each type of object.

     - SeeAlso:
       - `NSItemProviderReading.readableTypeIdentifiersForItemProvider`
     */
    var acceptableTypeIdentifiers: [String] { get }
    /**
     The text editor view asks the observer if it can paste or drop the item.

     This is called frequently during the user interaction, such as showing a menu or dragging the item.
     Therefore, the observer _SHOULD_ return the result quickly.
     The text editor view caches the result for a short period for the same item.

     Recommend to not check item content strictly here, and bias to return `true` so that user can try to paste or drop the item.
     The observer later has a chance to verify the item content in `transformItemProvider(_:completion:)`.

     - Parameters:
       - itemProvider: A `NSItemProvider` that provides pasting or dropping item.

     - Returns: `true` if it can paste or drop the item. `no` to not.

     - SeeAlso:
       - `transformItemProvider(_:completion:)`
     */
    func canPasteItemProvider(_ itemProvider: NSItemProvider) -> Bool
    /**
     The text editor view asks the observer to transform accepted pasting and dropping item.

     The observer can asynchronously transform pasting or dropping item.
     The observer _MUST_ call one of `completion` function to complete transforming.

     If the observer calls `transformed()`, the pasting or dropping is completed and no other actions are taken by the text editor view.
     No other observers will be asked to transform the item.

     If the observer calls `transformed(to:)`, the pasting or dropping is completed and the transformed string will be pasted or dropped.
     No other observers will be asked to transform the item.

     If the observer calls `noTransform()`, the text editor view will ask another observers to transform the item or
     transform it to string if possible by default.

     - Parameters:
       - itemProvider: A `NSItemProvider` that provides pasting or dropping item.
       - completion: A `TextEditorViewPasteObserverTransformCompletion` to complete transforming the pasting or dropping item.

     - SeeAlso:
       - `TextEditorViewPasteObserverTransformCompletion`
       - `canPasteItemProvider(_:)`
     */
    func transformItemProvider(_ itemProvider: NSItemProvider, completion: TextEditorViewPasteObserverTransformCompletion)
}

// MARK: -

private extension TextView {
    var editingContent: EditingContent {
        // This force unwrap is intentional.
        // `TextView`, which is `UITextView` shouldn't return invalid selected range.
        try! EditingContent(text: text, selectedRange: selectedRange) // swiftlint:disable:this force_try
    }
}

extension EditingContent: TextEditorViewEditingContent {
}

/**
 Primary text editor view.
 */
public final class TextEditorView: UIView {
    private let textStorage: NSTextStorage

    let textView: TextView

    private var userInteractionDidChangeTextViewScheduler: DebounceScheduler!
    private var updatePlaceholderTextScheduler: DebounceScheduler!
    private var updateTextAttributesScheduler: ContentFilterScheduler<NSAttributedString, NSAttributedString?>!

    /**
     Initialize a text editor view.
     This is the designated initializer.

     - Parameters:
       - frame: The frame rectangle for the text editor view.
     */
    public override init(frame: CGRect) {
        textStorage = NSTextStorage()

        let layoutManager = LayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: .zero)
        layoutManager.addTextContainer(textContainer)

        textView = TextView(frame: .zero, textContainer: textContainer)

        editingContent = textView.editingContent

        isScrollEnabled = textView.panGestureRecognizer.isEnabled
        inputPrimaryLanguage = textView.textInputMode?.primaryLanguage

        super.init(frame: frame)

        var constraints = [NSLayoutConstraint]()
        defer {
            NSLayoutConstraint.activate(constraints)
        }

        textStorage.delegate = self

        textView.textViewDelegate = self
        textView.textViewTextInputDelegate = self

        textView.pasteDelegate = self

        textView.textDragDelegate = self
        textView.textDropDelegate = self

        // UIView
        textView.backgroundColor = .clear

        // UIScrollView
        textView.alwaysBounceVertical = true
        textView.contentInsetAdjustmentBehavior = .never

        // UITextDraggable
        textView.textDragOptions = [.stripTextColorFromPreviews]

        addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(textView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(textView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(textView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(textView.trailingAnchor.constraint(equalTo: trailingAnchor))

        updatePasteConfiguration()

        // `UITextInputMode.currentInputModeDidChangeNotification` is posted globally, not specific `UITextInput` object.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textInputModeDidChange(_:)),
                                               name: UITextInputMode.currentInputModeDidChangeNotification,
                                               object: nil)

        userInteractionDidChangeTextViewScheduler = DebounceScheduler { [weak self] in
            self?.userInteractionDidChangeTextView()
        }

        /*
         UIKit behavior note

         Updating the placeholder text requires to access `UITextView.typingAttributes`.
         Currently `TextEditorView` is using `textStorage(_:didProcessEditing:range:changeInLength)`
         to update the placeholder text, however, in some situation it requires invalidating layout
         and it may accessing invalid range and throws the exception and app may crash.

         To deal with this behavior, use debounce scheduler to defer the task.

         - SeeAlso:
           - `textStorage(_:didProcessEditing:range:changeInLength)`
           - `textView(_:didChangeBaseWritingDirection:forRange:)`
         */
        updatePlaceholderTextScheduler = DebounceScheduler { [weak self] in
            self?.updatePlaceholderText()
        }

        /*
         UIKit behavior note

         Currently `TextEditorView` is using `textStorage(_:didProcessEditing:range:changeInLength)`
         to update text attributes for characters change events, however, in some situation such as
         when unmarking marked text, changing text storage attributes within
         `textStorage(_:didProcessEditing:range:changeInLength)` call may drop changed characters
         from the text storage.

         This `ContentFilterScheduler` first debounces the schedule with `RunLoop.main.perform(_:)`
         then use a cache. This order is important because using the cache may immediately return
         with the cached output.

         - SeeAlso:
           - `ContentFilterScheduler`
           - `textStorage(_:didProcessEditing:range:changeInLength)`
         */
        updateTextAttributesScheduler = ContentFilterScheduler { [weak self] input, completion in
            guard let self = self, let textAttributesDelegate = self.textAttributesDelegate else {
                completion(.success(nil))
                return
            }

            textAttributesDelegate.textEditorView(self, updateAttributedString: input) { output in
                completion(.success(output))
            }
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Properties (Delegate and Observer)

    /**
     The delegate to control beginning and ending editing.

     - SeeAlso:
       - `TextEditorViewEditingDelegate`
     */
    public weak var editingDelegate: TextEditorViewEditingDelegate?
    /**
     The observer to observe current text input for text editor view.

     - SeeAlso:
       - `TextEditorViewTextInputObserver`
     */
    public weak var textInputObserver: TextEditorViewTextInputObserver?
    /**
     The delegate to update editing content.

     - SeeAlso:
       - `TextEditorViewEditingContentDelegate`
     */
    public weak var editingContentDelegate: TextEditorViewEditingContentDelegate?
    /**
     The delegate to update text attributes.

     - SeeAlso:
       - `TextEditorViewTextAttributesDelegate`
     */
    public weak var textAttributesDelegate: TextEditorViewTextAttributesDelegate?
    /**
     The observer to observer the changes.

     - SeeAlso:
       - `TextEditorViewChangeObserver`
     */
    public weak var changeObserver: TextEditorViewChangeObserver?

    // MARK: - Properties (Paste)

    /**
     The list of `TextEditorViewPasteObserver` to observe pasting and dropping item.

     The order is a matter, the prior observer takes a precedent over the later ones.
     Unlike the other delegates or observers, the text editor view retains these observers.

     - SeeAlso:
       - `TextEditorViewPasteObserver`.
       - `isDropInteractionEnabled`.
     */
    public var pasteObservers: [TextEditorViewPasteObserver] = [] {
        didSet {
            updatePasteConfiguration()
        }
    }

    private final class DefaultTextPasteObserver: TextEditorViewPasteObserver {
        /*
         UIKit behavior note

         - Confirmed on iOS 13.6.

         `UITextView` has implicit paste configuration by default, which is accepting
         `NSURL` and `NSString` if `allowsEditingTextAttributes` is `false` and additionally,
         `NSAttributedString` and `UIImage` if `allowsEditingTextAttributes` is `true`.

         However, due based on actual behavior, accepting `NSAttributedString` is a key to allow
         users to paste text from specific apps such as `Messages.app` or pasting text will fail.

         Therefore, accepting `NSAttributedString` and `NSString` covers all expected text pasting.

         - SeeAlso:
           - `-[UITextView _implicitPasteConfigurationClasses]`
           - `TextViewTextPasteDelegate`
         */
        private static let acceptableTypeIdentifiers =
            NSAttributedString.readableTypeIdentifiersForItemProvider +
            NSString.readableTypeIdentifiersForItemProvider

        var acceptableTypeIdentifiers: [String] {
            Self.acceptableTypeIdentifiers
        }

        func canPasteItemProvider(_ itemProvider: NSItemProvider) -> Bool {
            true
        }

        // This observer is the default and always added at the last of observers list.
        // Therefore it ends always `transformed`, no `noTransform` case.
        func transformItemProvider(_ itemProvider: NSItemProvider,
                                   completion: TextEditorViewPasteObserverTransformCompletion)
        {
            if itemProvider.canLoadObject(ofClass: NSAttributedString.self) {
                itemProvider.loadObject(ofClass: NSAttributedString.self) { text, _ in
                    // Called on an arbitrary background queue.
                    if let text = text as? NSAttributedString {
                        completion.transformed(to: text.string)
                    } else {
                        completion.transformed()
                    }
                }
                return
            }

            if itemProvider.canLoadObject(ofClass: NSString.self) {
                itemProvider.loadObject(ofClass: NSString.self) { string, _ in
                    // Called on an arbitrary background queue.
                    if let string = string as? String {
                        completion.transformed(to: string)
                    } else {
                        completion.transformed()
                    }
                }
                return
            }

            completion.transformed()
        }
    }

    private let defaultTextPasteObserver = DefaultTextPasteObserver()

    private var pasteObserversWithDefaults: [TextEditorViewPasteObserver] {
        pasteObservers + [defaultTextPasteObserver]
    }

    private func updatePasteConfiguration() {
        let pasteConfiguration = UIPasteConfiguration()
        for observer in pasteObserversWithDefaults {
            pasteConfiguration.addAcceptableTypeIdentifiers(observer.acceptableTypeIdentifiers)
        }
        textView.pasteConfiguration = pasteConfiguration
    }

    // MARK: - Properties (Editing content)

    private var editingContent: EditingContent {
        didSet {
            log(type: .debug, "old value: %@, new value: %@", String(describing: oldValue), String(describing: editingContent))
        }
    }

    private var isUserInteractionBeingProcessed: Bool = false {
        didSet {
            log(type: .debug, "old value: %@, new value: %@", String(describing: oldValue), String(describing: isUserInteractionBeingProcessed))
        }
    }

    /**
     The current editing content text.

     Setting a new value to this property is equal to calling `updateByReplacing(range:with:selectedRange:)` to replace the entire range.
     It _MAY BE_ failing in a few reasons such as the user interaction is being processed.

     - SeeAlso:
       - `selectedRange`
       - `updateByReplacing(range:with:selectedRange:)`
     */
    public var text: String {
        get {
            editingContent.text
        }
        set {
            do {
                try update(with: .text(newValue))
            } catch {
            }
        }
    }

    /**
     The current editing content selected range.

     The range is in UTF-16 scalars of `text`.

     Setting a new value to this property is equal to calling `updateByReplacing(range:with:selectedRange:)` without replacing the range.
     It _MAY BE_ failing in a few reasons such as the user interaction is being processed.

     - SeeAlso:
       - `text`
       - `updateByReplacing(range:with:selectedRange:)`
     */
    public var selectedRange: NSRange {
        get {
            editingContent.selectedRange
        }
        set {
            do {
                try update(with: .selectedRange(newValue))
            } catch {
            }
        }
    }

    /**
     Ask text editor view to update the current editing content.

     It _SHOULD_ fail and throws an error if given parameters are invalid such as the out of range.
     It _MAY BE_ failing and throws an error in a few reasons such as the user interaction is being processed.

     - Parameters:
       - range: A `NSRange` to be replaced.
         It _MUST BE_ within UTF-16 scalars of current `text`.
       - text: A `String` that replaces `range` of `text`.
       - selectedRange: A `NSRange` where `selectedRange` should be after updating the editing content.
         It _MUST BE_ within UTF-16 scalars of replaced `text`.

     - SeeAlso:
       - `text`
       - `selectedRange`
     */
    public func updateByReplacing(range: NSRange, with text: String, selectedRange: NSRange? = nil) throws {
        try update(with: .subtext(range: range, text: text, selectedRange: selectedRange))
    }

    enum UpdateError: Error {
        case userInteractionIsBeingProcessed
        case inconsistentEditingContent
    }

    // Entry point to update editing content.
    private func update(with request: EditingContent.UpdateRequest) throws {
        log(type: .debug, "request: %@", String(describing: request))

        assert(Thread.isMainThread)

        guard !isUserInteractionBeingProcessed else {
            log(type: .error, "User interaction is being processed.")
            throw UpdateError.userInteractionIsBeingProcessed
        }

        if textView.editingContent != editingContent {
            log(type: .error,
                "Current text view editing content: %@ is not equal to editing content: %@",
                String(describing: textView.editingContent),
                String(describing: editingContent))
            throw UpdateError.inconsistentEditingContent
        }

        if textView.hasMarkedText || textView.isDictationRecording {
            // Only warning, for now.
            log(type: .error, """
                Text view has marked text or dictation is recording. \
                Update editing content may cause unexpected user experiences. \
                You should test your logic with all eastern Asian languages keyboards and also dictation.
            """)
        }

        let current = editingContent
        let interim = try current.update(with: request)
        let updated = self.editingContentDelegate?.textEditorView(self, updateEditingContent: interim) ?? interim

        log(type: .debug,
            "current: %@, interim: %@, updated: %@",
            String(describing: current),
            String(describing: interim),
            String(describing: updated))

        if updated.text != current.text {
            log(type: .debug, "Update text: %@ with text: %@", current.text, updated.text)

            // This triggers entire update process, calling delegate callbacks, posting notifications.
            // This may also change `selectedRange`.
            textView.text = updated.text

            /*
             UIKit behavior workaround

             - Confirmed on iOS 13.6.

             `UITextView` manages undo and redo by coalescing typing, which means it is not creating
             each undo action for each type.
             This behavior is done by creating a single undo action when start typing or specific case such as
             after typing enter with an internal object `_UITextUndoOperationTyping` that is tracking
             following typings and its text storage changes to coalescing them.

             Because of this behavior, `UITextView` is by default removing all undo actions to prevent
             mismatches between undo actions and text storage state when text storage did end process editing.

             However, it is only happening when `groupingLevel` is `0` and `removeAllActions` is not called
             if it's not `0`.
             Since `UITextView`'s undo manager is using `groupsByEvent`, all `setText:` call in a runloop
             that accepting typing will not call `removeAllActions`, therefore it can cause mismatches
             between undo actions and text storage state.

             To work around this behavior, manually call `removeAllActions` when we call `setText:`.

             - SeeAlso:
               - `_UITextUndoOperationTyping`
               - `-[UITextInputController coalesceInTextView:affectedRange:replacementRange:replacementText:]`
               - `-[UITextInputController _textStorageDidProcessEditing:]`
             */
            textView.undoManager?.removeAllActions()
        }

        if updated.selectedRange != current.selectedRange {
            log(type: .debug,
                "Update selected range: %@ with selected range: %@",
                String(describing: current.selectedRange),
                String(describing: updated.selectedRange))

            // This triggers entire update process, calling delegate callbacks, posting notifications.
            textView.selectedRange = updated.selectedRange
        }

        editingContent = textView.editingContent
    }

    private func updateEditingContent() {
        log(type: .debug)

        guard !textView.hasMarkedText, !textView.isDictationRecording else {
            return
        }

        // Update with `.null` is only applying editing content delegate
        // to update current editing content.
        do {
            try update(with: .null)
        } catch {
        }
    }

    /**
     Ask text editor view to update text attributes.

     - SeeAlso:
       - `textAttributesDelegate`
     */
    public func setNeedsUpdateTextAttributes() {
        log(type: .debug)

        scheduleUpdateTextAttributes()
    }

    // Entry point to update attributes.
    private func scheduleUpdateTextAttributes() {
        guard let attributedString = textStorage.copy() as? NSAttributedString else {
            return
        }
        log(type: .debug, "attributes: %@", attributedString.loggingDescription)

        updateTextAttributesScheduler.schedule(attributedString) { [weak self] result in
            guard let self = self else {
                return
            }

            guard case let .success(output) = result, let updatedAttributedString = output else {
                log(type: .debug, "Cancel update text attributes: %@, result: %@", attributedString.loggingDescription, String(describing: result))
                return
            }

            do {
                log(type: .debug, "Set text attributes: %@", updatedAttributedString.loggingDescription)
                try self.textStorage.setAttributes(from: updatedAttributedString)
                /*
                 UIKit behavior workaround

                 Confirmed on iOS 14.1

                 When we update text attributes, even just the text color, the `_UITextContainerView` inside
                 the `UITextView` would resize to a smaller height temporarily.
                 The next call to `layoutSubviews` would correct this height, but since that could be
                 in an animation block, it will get an animation from the smaller height to the correct
                 normal height.

                 To workaround this behavior, instead of calling `layoutIfNeeded`, which may have
                 many side effects, calling `usedRect(for:)` on the layout manager with the text container
                 associated to the text view.
                 That recalculates to height with the correct result and actually applies the height
                 to the `_UITextContainerView`.
                 */
                _ = self.textView.layoutManager.usedRect(for: self.textView.textContainer)
            } catch {
                log(type: .error, "Failed to set text attributes error: %@", String(describing: error))
            }
        }
    }

    /**
     Return or ask if the text editor view is editing or not.

     - SeeAlso:
       - `editingDelegate`
       - `isEditable`
     */
    public var isEditing: Bool {
        get {
            textView.isFirstResponder
        }
        set {
            log(type: .debug, "is editing: %@", String(describing: newValue))

            if newValue {
                textView.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
        }
    }

    /**
     Enable to return text input to end editing.

     Useful for similar feature using `UITextField` for single line text editing with
     `TextEditorViewEditingContentDelegate` to replace or filter new line characters.

     - SeeAlso:
       - `isEditing`
       - `returnKeyType`
       - `TextEditorViewEditingContentDelegate`
     */
    public var returnToEndEditingEnabled: Bool = false

    // MARK: - Properties (Text Input)

    /**
     The current text input primary language.

     - SeeAlso:
       - `textInputObserver`
     */
    public private(set) var inputPrimaryLanguage: String? {
        didSet {
            if inputPrimaryLanguage != oldValue {
                textInputObserver?.textEditorView(self, didChangeInputPrimaryLanguage: inputPrimaryLanguage)
            }
        }
    }

    /**
     Ask the text editor view to try to use specific text input primary language.

     Use `emoji` to let users to use Emoji keyboard.

     It _MAY BE_ failing if the user doesn't have such keyboard.
     */
    public func usePreferredTextInputPrimaryLanguage(_ inputPrimaryLanguage: String?) {
        textView.usePreferredTextInputModePrimaryLanguage(inputPrimaryLanguage)
    }

    // MARK: - Properties (Content View)

    /**
     The internal view that presents the text content.

     Use this view to add any accessory views to the text editor view alongside text content.

     - SeeAlso:
       - `textContentInsets`
       - `textContentPadding`
     */
    public var textContentView: UIView {
        textView.textInputView
    }

    /**
     The inset of the `textContentView`.

     Use this to lay outing the accessory views added to `textContentView`.

     - SeeAlso:
       - `textContentView`
     */
    public var textContentInsets: UIEdgeInsets {
        get {
            textView.textContainerInset
        }
        set {
            textView.textContainerInset = newValue

            updatePlaceholderText()
        }
    }

    /**
     The current default line break mode if none is specified in the text attributes.
     */
    public var defaultLineBreakMode: NSLineBreakMode {
        get {
            textView.textContainer.lineBreakMode
        }
        set {
            textView.textContainer.lineBreakMode = newValue

            updatePlaceholderTextView()
        }
    }

    /**
     The padding in `textContentView` for the text content.

     Default to a small value given by the UIKit.

     - SeeAlso:
       - `textContentView`
     */
    public var textContentPadding: CGFloat {
        get {
            textView.textContainer.lineFragmentPadding
        }
        set {
            textView.textContainer.lineFragmentPadding = newValue

            updatePlaceholderText()
        }
    }

    // MARK: - Properties (Scroll View)

    // TODO: Consider to not expose scroll view as scroll view.

    /**
     The internal scroll view.

     - SeeAlso:
       - `isScrollEnabled`
     */
    public var scrollView: UIScrollView {
        textView
    }

    /**
     Return or ask if `scrollView` can scroll or not.

     - SeeAlso:
       - `scrollView`
     */
    public var isScrollEnabled: Bool {
        didSet {
            guard oldValue != isScrollEnabled else {
                return
            }
            updateTextViewPanGestureRecognizer()
        }
    }

    // MARK: - Properties (Drag and Drop)

    // Currently local context is used only for identifying a drag session is started from this view or not.
    // See `UITextDragDelegate` conformance.

    private final class LocalTextDragContext: NSObject {
    }

    private var currentTextDragSessionLocalContext: LocalTextDragContext?

    /**
     Ask if the text editor view is dragging text with the given drag session.

     Useful to know if the current drag session is started within the text editor view text.
     The application _SHOULD NOT_ cancel such drag session.

     - SeeAlso:
       - `isDropInteractionEnabled`
     */
    public func isDraggingText(of dragSession: UIDragSession) -> Bool {
        if let localContext = dragSession.localContext as? LocalTextDragContext,
           let currentTextDragSessionLocalContext = currentTextDragSessionLocalContext
        {
            return localContext == currentTextDragSessionLocalContext
        }

        return false
    }

    /**
     Enable to disable dropping items on the text editor view.

     - SeeAlso:
       - `pasteObservers`
     */
    public var isDropInteractionEnabled: Bool = true

    // MARK: - Properties (Menu and Caret)

    /**
     Ask the text editor view to show menu that is presented usually when user is long-press in text editor view.
     */
    public func showMenu() {
        let menuController = UIMenuController.shared
        guard !menuController.isMenuVisible else {
            return
        }

        guard let menuRect = textView.menuRectAtSelectedRange else {
            return
        }

        if #available(iOS 13.0, *) {
            menuController.showMenu(from: textView, rect: menuRect)
        } else {
            menuController.setTargetRect(menuRect, in: textView)
            menuController.setMenuVisible(true, animated: true)
        }
    }

    /**
     The frame rectangle of cursor caret at the beginning of the current selected range.

     It is in the text editor view bounds.
     It can be `nil` if there are no selection.

     - SeeAlso:
       - `selectedRange`
     */
    public var caretRectAtBeginningOfSelectedRange: CGRect? {
        textView.caretRectAtBeginningOfSelectedRange
    }

    /**
     The frame rectangle of cursor caret at the end of the current selected range.

     It is in the text editor view bounds.
     It can be `nil` if there are no selection.

     - SeeAlso:
       - `selectedRange`
     */
    public var caretRectAtEndOfSelectedRange: CGRect? {
        textView.caretRectAtEndOfSelectedRange
    }

    // MARK: - Properties (Placeholder)

    private func updatePlaceholderText() {
        log(type: .debug)

        preparePlaceholderTextView()
        updatePlaceholderTextView()
        updateTextViewAccessibilityLabel()
    }

    private var placeholderTextView: UITextView?

    private func preparePlaceholderTextView() {
        if placeholderText != nil {
            guard placeholderTextView == nil else {
                return
            }

            let placeholderTextView = UITextView()

            // UIView
            placeholderTextView.backgroundColor = .clear
            placeholderTextView.isUserInteractionEnabled = false

            // UIScrollView
            placeholderTextView.contentInsetAdjustmentBehavior = .never
            placeholderTextView.isScrollEnabled = false

            // UITextView
            placeholderTextView.isEditable = false
            placeholderTextView.isSelectable = false

            // UIAccessibility
            placeholderTextView.isAccessibilityElement = false
            /*
             UIKit behavior note

             - Confirmed on iOS 13.6.

             `UITextView`'s `isAccessibilityElement` is default to `true` when Voice Over is enabled and `UIKit.axbundle` is loaded.
             However, if `UITextView` is not editable, `isAccessibilityElement` is default to `false`, and it behaves instead
             as accessibility container.
             In this case, `accessibilityElements` will returns multiple elements for each paragraph of text.

             To disable Voice Over to read out placeholder text, it need to set `accessibilityElementsHidden` as well.
             */
            placeholderTextView.accessibilityElementsHidden = true

            textView.insertSubview(placeholderTextView, at: 0)

            placeholderTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                placeholderTextView.topAnchor.constraint(equalTo: textView.textInputView.topAnchor),
                placeholderTextView.leadingAnchor.constraint(equalTo: textView.textInputView.leadingAnchor),
                placeholderTextView.trailingAnchor.constraint(equalTo: textView.textInputView.trailingAnchor)
            ])

            self.placeholderTextView = placeholderTextView
        } else {
            guard let placeholderTextView = placeholderTextView else {
                return
            }

            placeholderTextView.removeFromSuperview()
            self.placeholderTextView = nil
        }
    }

    private func updatePlaceholderTextView() {
        guard let placeholderText = placeholderText,
              let placeholderTextView = placeholderTextView else
        {
            return
        }

        // Use `textStorage.string` here because placeholder update method is called from
        // the text storage delegate.
        // See `textStorage(_:didProcessEditing:range:changeInLength:)`.
        guard textStorage.string.isEmpty else {
            placeholderTextView.isHidden = true
            return
        }

        placeholderTextView.isHidden = false

        placeholderTextView.textContainerInset = textView.textContainerInset

        placeholderTextView.textContainer.size = textView.textContainer.size
        placeholderTextView.textContainer.exclusionPaths = textView.textContainer.exclusionPaths
        placeholderTextView.textContainer.lineFragmentPadding = textView.textContainer.lineFragmentPadding

        placeholderTextView.textContainer.lineBreakMode = placeholderTextLineBreakMode
        placeholderTextView.textContainer.maximumNumberOfLines = maximumNumberOfLinesForPlaceholderText

        /*
         UIKit behavior note

         - Confirmed on iOS 13.6 and prior.

         `typingAttributes` is a derived property based on the current text view context
         such as text storage, selected range and so on.
         Therefore, it's not possible to know the all timings when the value can be changed.

         However, the public APIs of `UITextView` that can change this value without changing text
         are `setFont:` and `setTextAlignment:` and it's sufficient to check these setters.

         - SeeAlso:
           - `-[UITextInputController typingAttributes]`
           - `-[UITextView setFont:]`
           - `-[UITextView setTextAlignment:]`
         */
        let attributedText = NSAttributedString(string: placeholderText, attributes: textView.typingAttributes)
        placeholderTextView.attributedText = attributedText

        // UIKit is by default using `systemGray` for each placeholder.
        placeholderTextView.textColor = placeholderTextColor ?? UIColor.systemGray
    }

    private func updateTextViewAccessibilityLabel() {
        /*
         UIKit behavior note

         - Confirmed on iOS 13.6 and prior.

         There is a private `accessibilityPlaceholderValue` in UIKit, which is public in `NSAccessibility` for macOS,
         used for the internal private placeholder implementation in `UITextView`.

         Due to a risk of usage of private API usage, use `accessibilityLabel` for `placeholderText` instead.

         - SeeAlso:
           - `-[UITextViewAccessibility accessibilityPlaceholderValue]`
           - `TextView.accessibilityLabel`
         */

        if let placeholderText = placeholderText,
           let placeholderTextView = placeholderTextView,
           !placeholderTextView.isHidden
        {
            // This implementation emulates how `accessibilityPlaceholderValue` works with Voice Over.
            // Not exactly same but similar and worth to have it.
            textView.accessibilityLabel = "\(placeholderText) \(accessibilityLabel ?? "")"
        } else {
            textView.accessibilityLabel = nil
        }
    }

    /**
     The placeholder text presented when there is not user input text.

     - SeeAlso:
       - `placeholderTextColor`
       - `maximumNumberOfLinesForPlaceholderText`
     */
    public var placeholderText: String? {
        didSet {
            guard oldValue != placeholderText else {
                return
            }
            updatePlaceholderText()
        }
    }

    /**
     The placeholder text color.

     If it is `nil`, the text editor view will use the system default color.

     - SeeAlso:
       - `placeholderText`
     */
    public var placeholderTextColor: UIColor? {
        didSet {
            guard oldValue != placeholderTextColor else {
                return
            }
            updatePlaceholderText()
        }
    }

    /**
     The placeholder text line break mode.
     If the placeholder text doesn't fit to the maximum number of lines, the last line will be broken.

     Default to `.byTruncatingTail`.

     - SeeAlso:
       - `placeholderText`
       - `maximumNumberOfLinesForPlaceholderText`
     */
    public var placeholderTextLineBreakMode: NSLineBreakMode = .byTruncatingTail {
        didSet {
            guard oldValue != placeholderTextLineBreakMode else {
                return
            }
            updatePlaceholderText()
        }
    }

    /**
     The maximum number of lines for the placeholder text.
     If the placeholder text is longer than this, the last line will be broken by the placeholder text
     line break mode.

     Default to `1`, `0` to unlimited.

     - SeeAlso:
       - `placeholderText`
       - `placeholderTextLineBreakMode`
     */
    public var maximumNumberOfLinesForPlaceholderText: Int = 1 {
        didSet {
            guard oldValue != maximumNumberOfLinesForPlaceholderText else {
                return
            }
            updatePlaceholderText()
        }
    }

    // MARK: - Properties (UITextView)

    // TODO: Use property wrapper instead.
    // When a property wrapper supports `self` access, replace all following property delegates
    // by using a property wrapper with a key path.

    /**
     Return or ask if the text editor view is editable.

     - SeeAlso:
       - `isEditing`
       - `isSelectable`
     */
    public var isEditable: Bool {
        get {
            textView.isEditable
        }
        set {
            textView.isEditable = newValue
        }
    }

    /**
     Return or ask if the text editor view is selectable.

     - SeeAlso:
       - `isEditable`
     */
    public var isSelectable: Bool {
        get {
            textView.isSelectable
        }
        set {
            textView.isSelectable = newValue
        }
    }

    /**
     The current font of `text`.

     - SeeAlso:
       - `textAttributesDelegate`
     */
    public var font: UIFont? {
        get {
            textView.font
        }
        set {
            textView.font = newValue

            updatePlaceholderText()
            setNeedsUpdateTextAttributes()
        }
    }

    /**
     The current color of `text`.

     - SeeAlso:
       - `textAttributesDelegate`
     */
    public var textColor: UIColor? {
        get {
            textView.textColor
        }
        set {
            textView.textColor = newValue

            setNeedsUpdateTextAttributes()
        }
    }

    /**
     The current alignment of `text`.

     - SeeAlso:
       - `textAttributesDelegate`
     */
    public var textAlignment: NSTextAlignment {
        get {
            textView.textAlignment
        }
        set {
            textView.textAlignment = newValue

            updatePlaceholderTextView()
            setNeedsUpdateTextAttributes()
        }
    }

    /**
     The current tint color of text editor view.

     It is used for such as the caret or selected range color.
     */
    public override var tintColor: UIColor! {
        get {
            textView.tintColor
        }
        set {
            textView.tintColor = newValue
        }
    }

    // MARK: - Notifications

    @objc
    func textInputModeDidChange(_ notification: Notification) {
        inputPrimaryLanguage = textView.textInputMode?.primaryLanguage
    }

    // MARK: - UIView

    /// :nodoc:
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        textView.sizeThatFits(size)
    }

    /// :nodoc:
    public override func didMoveToWindow() {
        super.didMoveToWindow()

        updateTextViewPanGestureRecognizer()
    }

    private func updateTextViewPanGestureRecognizer() {
        /*
         UIKit behavior note

         - Confirmed on iOS 13.6 and prior.

         Don't use `scrollEnabled`

         This is intentionally not using `scrollEnabled` property on `UITextView`.
         Changing `scrollEnabled` to `NO` makes `UITextView` to behaves as like `UILabel`, which sets
         its intrinsic content size also limits text container's size to its bounds.
         This behavior is unexpected for this class use case.

         Defer until it's added to the view hierarchy.

         `UIScrollView`'s `panGestureRecognizer` will be enabled when it is moved to the window.
         This need to set after it did move to window.
         */
        guard window != nil else {
            return
        }

        textView.panGestureRecognizer.isEnabled = isScrollEnabled
    }

    // MARK: - UIResponder

    /// :nodoc:
    public override var canBecomeFirstResponder: Bool {
        textView.canBecomeFirstResponder
    }

    /// :nodoc:
    public override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }

    /// :nodoc:
    public override var canResignFirstResponder: Bool {
        textView.canResignFirstResponder
    }

    /// :nodoc:
    public override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
    }

    /// :nodoc:
    public override var isFirstResponder: Bool {
        textView.isFirstResponder
    }

    // MARK: - UIResponder (UIResponderInputViewAdditions)

    private var _inputAccessoryView: UIView?

    /// :nodoc:
    public override var inputAccessoryView: UIView? {
        get {
            guard let inputAccessoryView = _inputAccessoryView else {
                return super.inputAccessoryView
            }
            return inputAccessoryView
        }
        set {
            _inputAccessoryView = newValue
        }
    }

    private var _inputAccessoryViewController: UIInputViewController?

    /// :nodoc:
    public override var inputAccessoryViewController: UIInputViewController? {
        get {
            guard let inputAccessoryViewController = _inputAccessoryViewController else {
                return super.inputAccessoryViewController
            }
            return inputAccessoryViewController
        }
        set {
            _inputAccessoryViewController = newValue
        }
    }

    /// :nodoc:
    public override var inputView: UIView? {
        // `UITextView` overrides `inputView` default behavior and it does *NOT* go up the responder chain,
        // unlike `inputViewController` or `inputAccessoryView`, or `inputAccessoryViewController`.
        get {
            textView.inputView
        }
        set {
            textView.inputView = newValue
        }
    }

    private var _inputViewController: UIInputViewController?

    /// :nodoc:
    public override var inputViewController: UIInputViewController? {
        get {
            guard let inputViewController = _inputViewController else {
                return super.inputViewController
            }
            return inputViewController
        }
        set {
            _inputViewController = newValue
        }
    }

    /// :nodoc:
    public override func reloadInputViews() {
        textView.reloadInputViews()
    }
}

// MARK: - NSTextStorageDelegate

private extension NSMutableAttributedString {
    enum SetAttributesError: Error {
        case charactersEdited
    }

    func setAttributes(from attributedString: NSAttributedString) throws {
        guard self.string == attributedString.string else {
            throw SetAttributesError.charactersEdited
        }

        if self == attributedString {
            return
        }

        beginEditing()
        let range = NSRange(location: 0, length: length)
        setAttributes([:], range: range)
        attributedString.enumerateAttributes(in: range, options: []) { (attributes, range, _) in
            addAttributes(attributes, range: range)
        }
        endEditing()
    }
}

/// :nodoc:
extension TextEditorView: NSTextStorageDelegate {
    /*
     UIKit behavior note

     - Confirmed on iOS 13.6.

     Text storage process can be called at anytime even after `textViewDidChange:`
     inside `insertText:`, it calls `_insertText:fromKeyboard:` first, which is calling `textViewDidChange:` then,
     call `removeAlternativesForCurrentWord`, which changes attribute.
     */

    public func textStorage(_ textStorage: NSTextStorage,
                            willProcessEditing editedMask: NSTextStorage.EditActions,
                            range editedRange: NSRange,
                            changeInLength delta: Int)
    {
        log(type: .debug,
            "text storage: %@, edited characters: %@, edited attributes: %@, range: %@, change in length: %d",
            textStorage.loggingDescription,
            String(describing: editedMask.contains(.editedCharacters)),
            String(describing: editedMask.contains(.editedAttributes)),
            String(describing: editedRange),
            delta)
    }

    public func textStorage(_ textStorage: NSTextStorage,
                            didProcessEditing editedMask: NSTextStorage.EditActions,
                            range editedRange: NSRange,
                            changeInLength delta: Int)
    {
        log(type: .debug,
            "text storage: %@, edited characters: %@, edited attributes: %@, range: %@, change in length: %d",
            textStorage.loggingDescription,
            String(describing: editedMask.contains(.editedCharacters)),
            String(describing: editedMask.contains(.editedAttributes)),
            String(describing: editedRange),
            delta)

        // This is only for text attributes and string changes and not for selected range change
        // yet it's sufficient for updating the placeholder.
        // Note that `didSet` for `editingContent` is not called for any attributes changes.
        updatePlaceholderTextScheduler.schedule()

        // Following `scheduleUpdateTextAttributes()` is for characters change only.
        // Any non internal text view changes that may change text attributes should explicitly call
        // `setNeedsUpdateTextAttributes()` or changed text attributes may not be handled by
        // text attribute update delegate and may be lost because `scheduleUpdateTextAttributes()`
        // captures old values and the delegate is using it.
        // See `font` setter and `textColor` setter.
        guard editedMask.contains(.editedCharacters) else {
            return
        }

        scheduleUpdateTextAttributes()
    }
}

// MARK: - UITextViewDelegate

/// :nodoc:
extension EditingContent.ChangeResult: TextEditorViewChangeResult {
}

/// :nodoc:
extension TextEditorView: UITextViewDelegate {
    // See `TextViewDelegateForwarder` for the protocol conformance.

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        editingDelegate?.textEditorViewShouldBeginEditing(self) ?? true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        log(type: .debug)

        editingDelegate?.textEditorViewDidBeginEditing(self)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        log(type: .debug)

        /*
         UIKit behavior note

         - Confirmed on iOS 13.6 and prior.

         If textViewDidEndEditing(_:) is called, any other delegate callbacks such as `textViewDidChange(_:)`
         are not called at all.

         Therefore, this is very important to immediately call `userInteractionDidChangeTextView()`
         to maintain the text editor view state.
         */
        userInteractionDidChangeTextViewScheduler.perform()

        editingDelegate?.textEditorViewDidEndEditing(self)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        log(type: .debug, "range: %@, replacement text: %@", String(describing: range), text)

        // This delegate callback is the first callback for the update with user interaction.

        isUserInteractionBeingProcessed = true

        /*
         UIKit bug workaround
         UIKit behavior note

         - Confirmed on iOS 12.1.4 and prior.
         - May be not applicable on iOS 13.0 and later.
         - See <https://feedbackassistant.apple.com/feedback/5415167>, <rdar://problem/48427301>

         `UITextView` is not always calling delegate callbacks due to its internal implementation.
         this behavior is problematic especially when the user is selecting one of the auto-correct
         candidates from the keyboard.

         When it is bug behavior is happening, UIKit calls this delegate method with
         zero length range and empty text.
         However this call is not limited for selecting one of the auto-correct candidates, but also
         for a few other corner cases that `UITextView` doesn't call delegate callbacks expectedly.
         */
        if range.length == 0 && text.isEmpty {
            userInteractionDidChangeTextViewScheduler.schedule()
        }

        /*
         UIKit behavior note

         - Confirmed on iOS 13.6 and prior.

         This delegate method is called at arbitrary timings by the UIKit and not all callers are
         working properly with their keyboard implementations.
         If we return `false` from this delegate method, it breaks keyboard behaviors especially
         the one using marked text such as Japanese, but it's not limited to these,
         like the one using diacritical marks such as Czech.

         Therefore, we _MUST_ return `true` from this delegate method always.
         */
        return true
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        log(type: .debug, "selected range: %@", String(describing: textView.selectedRange))

        userInteractionDidChangeTextViewScheduler.schedule()
    }

    public func textViewDidChange(_ textView: UITextView) {
        log(type: .debug, "text: %@", textView.text)

        // This delegate callback is the last callback for the update with user interaction.
        // See also `textViewDidEndEditing(_:)`.

        userInteractionDidChangeTextViewScheduler.schedule()
    }

    private func userInteractionDidChangeTextView() {
        log(type: .debug)

        isUserInteractionBeingProcessed = false

        let previousEditingContent = editingContent
        editingContent = textView.editingContent

        updateEditingContent()

        guard let changeResult = textView.editingContent.changeResult(from: previousEditingContent) else {
            return
        }

        log(type: .debug, "change result: %@", String(describing: changeResult))
        changeObserver?.textEditorView(self, didChangeWithChangeResult: changeResult)
    }
}

// MARK: - TextViewTextInputDelegate

/// :nodoc:
extension TextEditorView: TextViewTextInputDelegate {
    func textViewShouldReturn(_ textView: TextView) -> Bool {
        log(type: .debug)

        guard returnToEndEditingEnabled else {
            return true
        }

        // Return `false` from this delegate will keep `isUserInteractionBeingProcessed` to `true`.
        // However, setting `isEditing` to `false` calls `textViewDidEndEditing(_:)` that is currently calling
        // `userInteractionDidChangeTextViewScheduler.perform()`, which eventually sets `isUserInteractionBeingProcessed` to `false`.
        // See `userInteractionDidChangeTextView()`.
        isEditing = false

        return false
    }

    func textView(_ textView: TextView,
                  didChangeBaseWritingDirection writingDirection: NSWritingDirection,
                  forRange range: UITextRange)
    {
        // `NSWritingDirection` enum name can't be described by `String(describing:)`.
        log(type: .debug, "base writing direction: %d, range: %@", writingDirection.rawValue, range)

        updatePlaceholderTextScheduler.schedule()

        textInputObserver?.textEditorView(self, didChangeBaseWritingDirection: writingDirection)
    }
}

// MARK: - UITextPasteDelegate

private extension TextEditorViewPasteObserver {
    func canAcceptItemProvider(_ itemProvider: NSItemProvider) -> Bool {
        acceptableTypeIdentifiers.contains { typeIdentifier in
            itemProvider.hasItemConformingToTypeIdentifier(typeIdentifier)
        }
    }
}

private extension UITextView {
    func withNoSmartInsertDeleteType(_ body: () -> Void) {
        let currentSmartInsertDeleteType = smartInsertDeleteType
        smartInsertDeleteType = .no
        body()
        smartInsertDeleteType = currentSmartInsertDeleteType
    }
}

/// :nodoc:
extension TextEditorView: TextViewTextPasteDelegate {
    public func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting,
                                                 canPaste itemProviders: [NSItemProvider]) -> Bool
    {
        for itemProvider in itemProviders {
            for observer in pasteObserversWithDefaults where observer.canAcceptItemProvider(itemProvider) {
                if observer.canPasteItemProvider(itemProvider) {
                    return true
                }
            }
        }
        return false
    }

    private final class PasteObserverTransformCompletion: TextEditorViewPasteObserverTransformCompletion {
        enum Result {
            case transformed
            case transformedToString(String)
            case noTransform
        }

        typealias Completion = (Result) -> Void

        private let completion: Completion

        init(_ completion: @escaping Completion) {
            self.completion = completion
        }

        func transformed() {
            completion(.transformed)
        }

        func transformed(to string: String) {
            completion(.transformedToString(string))
        }

        func noTransform() {
            completion(.noTransform)
        }
    }

    private final class UITextPasteItemToSetResultOnce {
        private var item: UITextPasteItem?

        init(item: UITextPasteItem) {
            self.item = item
        }

        func setResult(string: String) {
            item?.setResult(string: string)
            item = nil
        }

        func setNoResult() {
            item?.setNoResult()
            item = nil
        }

        func setDefaultResult() {
            item?.setDefaultResult()
            item = nil
        }
    }

    public func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting,
                                                 transform item: UITextPasteItem)
    {
        let itemProvider = item.itemProvider

        let acceptingObservers = pasteObserversWithDefaults.filter { observer in
            observer.canAcceptItemProvider(itemProvider)
        }

        if acceptingObservers.isEmpty {
            item.setDefaultResult()
            return
        }

        /*
         UIKit bug workaround
         UIKit behavior note

         - Confirmed on iOS 14.4 and prior.
         - Fixed on iOS 14.5.
         - See <https://feedbackassistant.apple.com/feedback/8834804>

         `UITextView` inserts an unexpected space when calling `UITextPasteItem.setNoResult` at the cursor
         where is not a space if `smartInsertDeleteType` is enabled by the Smart Punctuation in Settings.app.

         This is because when the application calls `setNoResult`, it ends up with calling
         `_pasteAttributedString:toRange:completion:` with a blank `NSAttributedString`.
         This method uses `_attributedStringForInsertionOfAttributedString:` to adjust that blank string to
         a space if there is no space at cursor and `smartInsertDeleteType` is enabled.

         However, the expectation of `setNoResult` is not pasting anything in the text view,
         therefore this is a UIKit bug.

         To workaround this bug, temporary set `smartInsertDeleteType` to `.no` before calling `setNoResult`
         on the main queue.

         - SeeAlso:
           - `UITextView.withNoSmartInsertDeleteType(_:)`
           - `-[UITextInputController _pasteAttributedString:toRange:completion:]`
           - `-[UITextInputController _attributedStringForInsertionOfAttributedString:]`
         */

        // In case there are only one accepting observer, do not asynchronously iterate observers to transform item.
        if acceptingObservers.count == 1, let observer = acceptingObservers.first {
            observer.transformItemProvider(itemProvider, completion: PasteObserverTransformCompletion { result in
                // Called on an arbitrary background or main queue.
                switch result {
                case .transformed:
                    if #available(iOS 14.5, *) {
                        item.setNoResult()
                    } else {
                        // UIKit bug workaround
                        DispatchQueue.main.async {
                            self.textView.withNoSmartInsertDeleteType {
                                item.setNoResult()
                            }
                        }
                    }
                case .transformedToString(let string):
                    item.setResult(string: string)
                case .noTransform:
                    item.setDefaultResult()
                }
            })
            return
        }

        let itemToSetResult = UITextPasteItemToSetResultOnce(item: item)

        acceptingObservers.forEach(queue: DispatchQueue.main, completion: {
            // Ensure to fall back default result if item has never been set result.
            itemToSetResult.setDefaultResult()
        }, { observer, next in
            observer.transformItemProvider(itemProvider, completion: PasteObserverTransformCompletion { result in
                // Called on an arbitrary background or main queue.
                switch result {
                case .transformed:
                    if #available(iOS 14.5, *) {
                        itemToSetResult.setNoResult()
                    } else {
                        // UIKit bug workaround
                        DispatchQueue.main.async {
                            self.textView.withNoSmartInsertDeleteType {
                                itemToSetResult.setNoResult()
                            }
                            next(.break)
                        }
                    }
                case .transformedToString(let string):
                    itemToSetResult.setResult(string: string)
                    next(.break)
                case .noTransform:
                    next(.continue)
                }
            })
        })
    }

    public func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting,
                                                 shouldAnimatePasteOf attributedString: NSAttributedString,
                                                 to textRange: UITextRange) -> Bool
    {
        /*
         UIKit behavior workaround

         - Confirmed on iOS 12.4 and prior.
         - Not applicable on iOS 13.0 and later.
         - See <https://feedbackassistant.apple.com/feedback/5415167>, <rdar://problem/48427301>

         `UITextView` performs unwanted text animation prior to iOS 13.0.
         */
        if #available(iOS 13.0, *) {
            // Default implementation is `true`.
            return true
        }

        // Disable unwanted text animation.
        return false
    }
}

// MARK: - UITextDragDelegate

/// :nodoc:
extension TextEditorView: UITextDragDelegate {
    public func textDraggableView(_ textDraggableView: UIView & UITextDraggable,
                                  dragSessionWillBegin session: UIDragSession)
    {
        currentTextDragSessionLocalContext = LocalTextDragContext()
        session.localContext = currentTextDragSessionLocalContext
    }

    public func textDraggableView(_ textDraggableView: UIView & UITextDraggable,
                                  dragSessionDidEnd session: UIDragSession,
                                  with operation: UIDropOperation)
    {
        currentTextDragSessionLocalContext = nil
    }
}

/// :nodoc:
extension TextEditorView: UITextDropDelegate {
    public func textDroppableView(_ textDroppableView: UIView & UITextDroppable,
                                  proposalForDrop drop: UITextDropRequest) -> UITextDropProposal
    {
        // Drag and drop interaction within the text view is always allowed.
        if drop.isSameView {
            return UITextDropProposal(operation: .move)
        }

        if isDropInteractionEnabled {
            return UITextDropProposal(operation: .copy)
        }

        /*
         UIKit but workaround

         - Confirmed on iOS 13.6 and prior.
         - FB7819464

         `UITextView` is using `UITextDragAssistant` for handling text drop interaction.

         This `UITextDragAssistant` is `UIDropInteractionDelegate` and its `dropInteraction:canHandleSession:`
         is using `textDroppableView:proposalForDrop:` via `_updateCurrentDropProposalInSession:usingRequest:`
         to decide if it can handle the drop session or not.

         In case this `textDroppableView:proposalForDrop:` returns `UITextDropProposal` with
         `UIDropOperationCancel` or `UIDropOperationForbidden` operation to cancel drop session,
         it returns `NO` from `dropInteraction:canHandleSession:`.

         When this is happening, `dropInteraction:sessionDidEnd:` is _NOT_ called because the drop session
         will not even start.

         However, probably Apple engineer was misunderstanding `UIDropInteractionDelegate` behavior and
         they put `_cleanupDrop` call in `dropInteraction:sessionDidEnd:` that clears the drop session state
         which `UITextDragAssistant` retains, such as the dropping text position.

         Due to this bug, the drop session state remains until next time a drop session is successfully
         handled and `dropInteraction:sessionDidEnd:` is called, this `textDroppableView:proposalForDrop:`
         will not be called properly.

         To workaround this behavior, call `dropInteraction:sessionDidEnd:` when it returns `UITextDropProposal`
         with `UIDropOperationCancel` or `UIDropOperationForbidden` operation, as like they expected.

         - SeeAlso:
           - `-[UITextDragAssistant dropInteraction:canHandleSession:]`
           - `-[UITextDragAssistant _updateCurrentDropProposalInSession:usingRequest:]`
           - `-[UITextDragAssistant dropInteraction:sessionDidEnd:]`
           - `-[UITextDragAssistant _cleanupDrop]`
         */
        RunLoop.main.perform {
            if let dropInteraction = textDroppableView.textDropInteraction,
               let delegate = dropInteraction.delegate
            {
                delegate.dropInteraction?(dropInteraction, sessionDidEnd: drop.dropSession)
            }
        }
        return UITextDropProposal(operation: .cancel)
    }
}
