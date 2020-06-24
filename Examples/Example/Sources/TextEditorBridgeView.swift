//
//  TextEditorBridgeView.swift
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import TwitterTextEditor

@objc
protocol TextEditorBridgeViewDelegate: NSObjectProtocol {
    @objc
    optional func textEditorBridgeView(_ textEditorBridgeView: TextEditorBridgeView,
                                       updateAttributedString attributedString: NSAttributedString,
                                       completion: @escaping (NSAttributedString?) -> Void)
}

@objc
final class TextEditorBridgeView: UIView {
    @objc
    weak var delegate: TextEditorBridgeViewDelegate?

    private let textEditorView: TextEditorView

    override init(frame: CGRect) {
        textEditorView = TextEditorView()

        super.init(frame: frame)

        var constraints = [NSLayoutConstraint]()
        defer {
            NSLayoutConstraint.activate(constraints)
        }

        textEditorView.textAttributesDelegate = self
        addSubview(textEditorView)

        textEditorView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(textEditorView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(textEditorView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(textEditorView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(textEditorView.trailingAnchor.constraint(equalTo: trailingAnchor))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Properties

    @objc
    var isEditing: Bool {
        get {
            textEditorView.isEditing
        }
        set {
            textEditorView.isEditing = newValue
        }
    }

    @objc
    var font: UIFont? {
        get {
            textEditorView.font
        }
        set {
            textEditorView.font = newValue
        }
    }

    @objc
    var text: String {
        get {
            textEditorView.text
        }
        set {
            textEditorView.text = newValue
        }
    }

    @objc
    var scrollView: UIScrollView {
        textEditorView.scrollView
    }
}

// MARK: - TextEditorViewTextAttributesDelegate

extension TextEditorBridgeView: TextEditorViewTextAttributesDelegate {
    func textEditorView(_ textEditorView: TextEditorView,
                        updateAttributedString attributedString: NSAttributedString,
                        completion: @escaping (NSAttributedString?) -> Void)
    {
        if delegate?.textEditorBridgeView?(self, updateAttributedString: attributedString, completion: completion) == nil {
            completion(nil)
        }
    }
}
