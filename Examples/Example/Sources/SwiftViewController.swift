//
//  SwiftViewController.swift
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import KeyboardGuide
import MobileCoreServices
import TwitterTextEditor
import UIKit

protocol SwiftViewControllerDelegate: AnyObject {
    func swiftViewControllerDidTapDone(_ swiftViewController: SwiftViewController)
}

private final class BlockPasteObserver: TextEditorViewPasteObserver {
    var acceptableTypeIdentifiers: [String]

    private var canPaste: (NSItemProvider) -> Bool

    func canPasteItemProvider(_ itemProvider: NSItemProvider) -> Bool {
        canPaste(itemProvider)
    }

    private var transform: (NSItemProvider, TextEditorViewPasteObserverTransformCompletion) -> Void

    func transformItemProvider(_ itemProvider: NSItemProvider, completion: TextEditorViewPasteObserverTransformCompletion) {
        transform(itemProvider, completion)
    }

    init(acceptableTypeIdentifiers: [String],
         canPaste: @escaping (NSItemProvider) -> Bool,
         transform: @escaping (NSItemProvider, TextEditorViewPasteObserverTransformCompletion) -> Void
    ) {
        self.acceptableTypeIdentifiers = acceptableTypeIdentifiers
        self.canPaste = canPaste
        self.transform = transform
    }
}

final class SwiftViewController: UIViewController {
    weak var delegate: SwiftViewControllerDelegate?

    private var textEditorView: TextEditorView?
    private var dropIndicationView: UIView?

    private var attachmentViews: [UIView] = []

    private var attachmentStillImage: UIImage?
    private var attachmentAnimatedImage: UIImage?

    init() {
        super.init(nibName: nil, bundle: nil)

        title = "Swift example"

        let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                   target: self,
                                                   action: #selector(refreshBarButtonItemDidTap(_:)))
        navigationItem.leftBarButtonItems = [refreshBarButtonItem]

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                target: self,
                                                action: #selector(doneBarButtonItemDidTap(_:)))
        navigationItem.rightBarButtonItems = [doneBarButtonItem]

        attachmentStillImage = UIImage(named: "twemoji-cat")
        attachmentAnimatedImage = .animatedImage(named: "twemoji-cat-animated", duration: 1.2)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    var useCustomDropInteraction: Bool = false {
        didSet {
            guard oldValue != useCustomDropInteraction else {
                return
            }
            updateCustomDropInteraction()
        }
    }

    private var customDropInteraction: UIDropInteraction?

    private func updateCustomDropInteraction() {
        guard isViewLoaded, let textEditorView = textEditorView else {
            return
        }

        if useCustomDropInteraction {
            if customDropInteraction == nil {
                let dropInteraction = UIDropInteraction(delegate: self)
                view.addInteraction(dropInteraction)
                self.customDropInteraction = dropInteraction
            }

            // To disable drop interaction on the text editor view, set `isDropInteractionEnabled` to `false`.
            // Users can still drag and drop texts inside text editor view.
            textEditorView.isDropInteractionEnabled = false
        } else {
            if let dropInteraction = customDropInteraction {
                view.removeInteraction(dropInteraction)
                self.customDropInteraction = nil
            }
            textEditorView.isDropInteractionEnabled = true
        }
    }

    // MARK: - Actions

    @objc
    private func refreshBarButtonItemDidTap(_ sender: Any) {
        textEditorView?.isEditing = false
        textEditorView?.text = ""
    }

    @objc
    private func doneBarButtonItemDidTap(_ sender: Any) {
        delegate?.swiftViewControllerDidTapDone(self)
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .defaultBackground

        var constraints = [NSLayoutConstraint]()
        defer {
            NSLayoutConstraint.activate(constraints)
        }

        let textEditorView = TextEditorView()

        textEditorView.layer.borderColor = UIColor.defaultBorder.cgColor
        textEditorView.layer.borderWidth = 1.0

        textEditorView.changeObserver = self
        textEditorView.editingContentDelegate = self
        textEditorView.textAttributesDelegate = self

        textEditorView.font = .systemFont(ofSize: 20.0)
        textEditorView.placeholderText = "This is an example of place holder text that can be truncated."

        textEditorView.pasteObservers = [
            BlockPasteObserver(
                acceptableTypeIdentifiers: [kUTTypeImage as String],
                canPaste: { _ in
                    true
                },
                transform: { [weak self] itemProvider, reply in
                    itemProvider.loadDataRepresentation(forTypeIdentifier: kUTTypeImage as String) { [weak self] data, _ in
                        if let data = data, let image = UIImage(data: data) {
                            // Called on an arbitrary background queue.
                            DispatchQueue.main.async {
                                let imagePreviewViewController = ImagePreviewViewController(image: image) { [weak self] in
                                    self?.dismiss(animated: true, completion: nil)
                                }
                                imagePreviewViewController.title = "Pasted"
                                self?.present(imagePreviewViewController, animated: true)
                            }
                        }
                        reply.transformed()
                    }
                }
            )
        ]

        view.addSubview(textEditorView)

        textEditorView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(textEditorView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20.0))
        constraints.append(textEditorView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor))
        constraints.append(textEditorView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor))
        constraints.append(textEditorView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor))

        self.textEditorView = textEditorView

        let dropIndicationView = UIView()
        dropIndicationView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
        dropIndicationView.isHidden = true

        view.addSubview(dropIndicationView)

        dropIndicationView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(dropIndicationView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(dropIndicationView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(dropIndicationView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(dropIndicationView.trailingAnchor.constraint(equalTo: view.trailingAnchor))

        self.dropIndicationView = dropIndicationView

        let dropIndicationLabel = UILabel()
        dropIndicationLabel.text = "Drop here"
        dropIndicationLabel.textColor = .white
        dropIndicationLabel.font = .systemFont(ofSize: 40.0)

        dropIndicationView.addSubview(dropIndicationLabel)

        dropIndicationLabel.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(dropIndicationLabel.centerXAnchor.constraint(equalTo: dropIndicationView.centerXAnchor))
        constraints.append(dropIndicationLabel.centerYAnchor.constraint(equalTo: dropIndicationView.centerYAnchor))

        updateCustomDropInteraction()

        // This view is used to call `layoutSubviews()` when keyboard safe area is changed
        // to manually change scroll view content insets.
        // See `viewDidLayoutSubviews()`.
        let keyboardSafeAreaRelativeLayoutView = UIView()
        view.addSubview(keyboardSafeAreaRelativeLayoutView)
        keyboardSafeAreaRelativeLayoutView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(keyboardSafeAreaRelativeLayoutView.bottomAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.bottomAnchor))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let textEditorView = textEditorView else {
            return
        }

        let bottomInset = view.keyboardSafeArea.insets.bottom - view.layoutMargins.bottom
        textEditorView.scrollView.contentInset.bottom = bottomInset
        if #available(iOS 11.1, *) {
            textEditorView.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        } else {
            textEditorView.scrollView.scrollIndicatorInsets.bottom = bottomInset
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // This is an example call for supporting accessibility contrast change to recall
        // `textEditorView(_:updateAttributedString:completion:)`.
        textEditorView?.setNeedsUpdateTextAttributes()
    }

    // MARK: - Suggests

    private var suggestViewController: SuggestViewController?

    private func presentSuggests(_ suggests: [String]) {
        guard suggestViewController == nil else {
            return
        }

        let suggestViewController = SuggestViewController()
        suggestViewController.delegate = self
        suggestViewController.suggests = suggests

        addChild(suggestViewController)

        var constraints = [NSLayoutConstraint]()

        suggestViewController.view.layer.borderColor = UIColor.defaultBorder.cgColor
        suggestViewController.view.layer.borderWidth = 1.0

        view.addSubview(suggestViewController.view)

        suggestViewController.view.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(suggestViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(suggestViewController.view.bottomAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.bottomAnchor))
        constraints.append(suggestViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(suggestViewController.view.heightAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.heightAnchor, multiplier: 0.5))

        NSLayoutConstraint.activate(constraints)

        suggestViewController.didMove(toParent: self)

        self.suggestViewController = suggestViewController
    }

    private func dismissSuggests() {
        guard let suggestViewController = suggestViewController else {
            return
        }

        suggestViewController.willMove(toParent: nil)
        suggestViewController.view.removeFromSuperview()
        suggestViewController.removeFromParent()

        self.suggestViewController = nil
    }
}

// MARK: - UIDropInteractionDelegate

extension SwiftViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        if let textEditorView = textEditorView, let localDragSession = session.localDragSession {
            return !textEditorView.isDraggingText(of: localDragSession)
        }
        return session.items.contains { item in
            item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String)
        }
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        .init(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        dropIndicationView?.isHidden = false
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        dropIndicationView?.isHidden = true
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        dropIndicationView?.isHidden = true
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let item = session.items.first else {
            return
        }

        let itemProvider = item.itemProvider
        itemProvider.loadDataRepresentation(forTypeIdentifier: kUTTypeImage as String) { [weak self] data, _ in
            if let data = data, let image = UIImage(data: data) {
                // Called on an arbitrary background queue.
                DispatchQueue.main.async {
                    let imagePreviewViewController = ImagePreviewViewController(image: image) { [weak self] in
                        self?.dismiss(animated: true, completion: nil)
                    }
                    imagePreviewViewController.title = "Dropped"
                    self?.present(imagePreviewViewController, animated: true)
                }
            }
        }
    }
}

// MARK: - TextEditorViewChangeObserver

extension SwiftViewController: TextEditorViewChangeObserver {
    func textEditorView(_ textEditorView: TextEditorView,
                        didChangeWithChangeResult changeResult: TextEditorViewChangeResult)
    {
        let selectedRange = textEditorView.selectedRange
        if selectedRange.length != 0 {
            dismissSuggests()
            return
        }

        let precedingText = textEditorView.text.substring(with: NSRange(location: 0, length: selectedRange.upperBound))
        if precedingText.firstMatch(pattern: "#[^\\s]*\\z") != nil {
            if changeResult.isTextChanged {
                presentSuggests([
                    "meow",
                    "cat",
                    "wowcat",
                    "かわいい🐱"
                ])
            }
        } else {
            dismissSuggests()
        }
    }
}

// MARK: - TextEditorViewEditingContentDelegate

private struct EditingContent: TextEditorViewEditingContent {
    var text: String
    var selectedRange: NSRange
}

private extension TextEditorViewEditingContent {
    func filter(_ isIncluded: (Unicode.Scalar) -> Bool) -> TextEditorViewEditingContent {
        var filteredUnicodeScalars = String.UnicodeScalarView()

        var index = 0
        var updatedSelectedRange = selectedRange

        for unicodeScalar in text.unicodeScalars {
            if isIncluded(unicodeScalar) {
                filteredUnicodeScalars.append(unicodeScalar)
                index += unicodeScalar.utf16.count
            } else {
                let replacingRange = NSRange(location: index, length: unicodeScalar.utf16.count)
                updatedSelectedRange = updatedSelectedRange.movedByReplacing(range: replacingRange, length: 0)
            }
        }

        return EditingContent(text: String(filteredUnicodeScalars), selectedRange: updatedSelectedRange)
    }
}

extension SwiftViewController: TextEditorViewEditingContentDelegate {
    func textEditorView(_ textEditorView: TextEditorView,
                        updateEditingContent editingContent: TextEditorViewEditingContent) -> TextEditorViewEditingContent?
    {
        editingContent.filter { unicodeScalar in
            // Filtering any BiDi control characters out.
            !unicodeScalar.properties.isBidiControl
        }
    }
}

// MARK: - TextEditorViewTextAttributesDelegate

extension SwiftViewController: TextEditorViewTextAttributesDelegate {
    func textEditorView(_ textEditorView: TextEditorView,
                        updateAttributedString attributedString: NSAttributedString,
                        completion: @escaping (NSAttributedString?) -> Void)
    {
        DispatchQueue.global().async {
            let string = attributedString.string
            let stringRange = NSRange(location: 0, length: string.length)

            let matches = string.matches(pattern: "(?:@([a-zA-Z0-9_]+)|#([^\\s]+))")

            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let textEditorView = self.textEditorView,
                      let attachmentAnimatedImage = self.attachmentAnimatedImage,
                      let attachmentStillImage = self.attachmentStillImage
                else {
                    completion(nil)
                    return
                }

                // TODO: Implement reusable view like table view cell.
                for view in self.attachmentViews {
                    view.removeFromSuperview()
                }

                let attributedString = NSMutableAttributedString(attributedString: attributedString)
                attributedString.removeAttribute(.suffixedAttachment, range: stringRange)
                attributedString.removeAttribute(.underlineStyle, range: stringRange)
                attributedString.addAttribute(.foregroundColor, value: UIColor.defaultText, range: stringRange)

                for match in matches {
                    if let name = string.substring(with: match, at: 2) {
                       let attachment: TextAttributes.SuffixedAttachment?
                        switch name {
                        case "wowcat":
                            let imageView = UIImageView()
                            imageView.image = attachmentAnimatedImage
                            imageView.startAnimating()

                            textEditorView.textContentView.addSubview(imageView)
                            self.attachmentViews.append(imageView)

                            let layoutInTextContainer = { [weak textEditorView] (view: UIView, frame: CGRect) in
                                // `textEditorView` retains `textStorage`, which retains this block as a part of attributes.
                                guard let textEditorView = textEditorView else {
                                    return
                                }
                                let insets = textEditorView.textContentInsets
                                view.frame = frame.offsetBy(dx: insets.left, dy: insets.top)
                            }
                            attachment = .init(size: CGSize(width: 20.0, height: 20.0),
                                               attachment: .view(view: imageView, layoutInTextContainer: layoutInTextContainer))
                        case "cat":
                            attachment = .init(size: CGSize(width: 20.0, height: 20.0),
                                               attachment: .image(attachmentStillImage))
                        default:
                            attachment = nil
                        }

                        if let attachment = attachment {
                            let index = match.range.upperBound - 1
                            attributedString.addAttribute(.suffixedAttachment,
                                                          value: attachment,
                                                          range: NSRange(location: index, length: 1))
                        }
                    }

                    var attributes = [NSAttributedString.Key: Any]()
                    attributes[.foregroundColor] = UIColor.systemBlue
                    // See `traitCollectionDidChange(_:)`
                    if #available(iOS 13.0, *) {
                        switch self.traitCollection.accessibilityContrast {
                        case .high:
                            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                        default:
                            break
                        }
                    }
                    attributedString.addAttributes(attributes, range: match.range)
                }
                completion(attributedString)
            }
        }
    }
}

// MARK: - SuggestViewControllerDelegate

extension SwiftViewController: SuggestViewControllerDelegate {
    func suggestViewController(_ viewController: SuggestViewController, didSelectSuggestedString suggestString: String) {
        guard let textEditorView = textEditorView else {
            return
        }

        let text = textEditorView.text
        let selectedRange = textEditorView.selectedRange

        let precedingText = text.substring(with: NSRange(location: 0, length: selectedRange.upperBound))

        if let match = precedingText.firstMatch(pattern: "#[^\\s]*\\z") {
            let location = match.range.location
            let range = NSRange(location: location, length: (text.length - location))
            if let match = text.firstMatch(pattern: "#[^\\s]* ?", range: range) {
                let replacingRange = match.range
                do {
                    let replacingText = "#\(suggestString) "
                    let selectedRange = NSRange(location: location + replacingText.length, length: 0)
                    try textEditorView.updateByReplacing(range: replacingRange, with: replacingText, selectedRange: selectedRange)
                } catch {
                }
            }
        }
        dismissSuggests()
    }
}
