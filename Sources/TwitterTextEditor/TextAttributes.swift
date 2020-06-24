//
//  TextAttributes.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

/**
 Namespace for additional text attributes supported by `TextEditorView`.
 */
public enum TextAttributes {
    /**
     A text attributes value for the attachment that can add a suffix image or view to the text range.
     */
    public final class SuffixedAttachment: NSObject {
        /**
         A text attributes key for this value.

         - SeeAlso:
           - `NSAttributedString.Key.suffixedAttachment`
         */
        public static let attributeName = NSAttributedString.Key(rawValue: "TTESuffixedAttachment")

        /**
         An attachment representation.
         */
        public enum Attachment {
            /**
             A still image attachment represented as `UIImage`.
             */
            case image(UIImage)
            /**
             An arbitrary view that represented as `UIView`.

             - Parameters:
               - view: A `UIView` that is added to the text editor view.
               - layoutInTextContainer: A block that is lay outing given `view` in given `frame`.
                 It needs to take an account of text editor view's metrics such as `textContentInsets`.

             - SeeAlso:
               - `TextEditorView.textContentView`
               - `TextEditorView.textContentInsets`
               - `TextEditorView.textContentPadding`
             */
            case view(view: UIView, layoutInTextContainer: (UIView, CGRect) -> Void)
        }

        /**
         Size of the attachment.
         */
        public let size: CGSize
        /**
         The attachment representation.
         */
        public let attachment: Attachment

        /**
         Initialize with an attachment representation.

         - Parameters:
           - size: Size of the attachment.
           - attachment: An attachment representation.
         */
        public init(size: CGSize, attachment: Attachment) {
            self.size = size
            self.attachment = attachment

            super.init()
        }

        /// :nodoc:
        public override var description: String {
            "<\(type(of: self)): " +
            "size = \(size), " +
            "attachment = \(attachment)}" +
            ">"
        }
    }
}

extension NSAttributedString.Key {
    /**
     A text attributes key for `TextAttributes.SuffixedAttachment`.
     */
    public static let suffixedAttachment = TextAttributes.SuffixedAttachment.attributeName
}
