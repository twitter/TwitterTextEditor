//
//  TextViewDelegateForwarder.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

private let scrollViewDelegateSelectors: Set<Selector> = [
    #selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:)),
    #selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:)),
    #selector(UIScrollViewDelegate.scrollViewDidScroll(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidZoom(_:)),
    #selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:)),
    #selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:)),
    #selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)),
    #selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:)),
    #selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)),
    #selector(UIScrollViewDelegate.viewForZooming(in:))
]

/*
 Swift compiler bug workaround

 - Confirmed on Swift 5.2

 It seems to no way for discrime overloaded method in selectors, mean cannot discriminate several method such as
 `textView(_:shouldInteractWith:in:)` from UITextViewDelegate.
 If we have class that implement one of  it from overloaded methods, we can get the selector from the class.
 */
private class OverloadedSelectorURL: NSObject, UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        false
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        false
    }
}

private class OverloadedSelectorTextAttachment: NSObject, UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        false
    }

    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        false
    }
}

private let textViewDelegateSelectors: Set<Selector> = [
    #selector(UITextViewDelegate.textView(_:shouldChangeTextIn:replacementText:)),
    #selector(OverloadedSelectorURL.textView(_:shouldInteractWith:in:)),
    #selector(OverloadedSelectorURL.textView(_:shouldInteractWith:in:interaction:)),
    #selector(OverloadedSelectorTextAttachment.textView(_:shouldInteractWith:in:)),
    #selector(OverloadedSelectorTextAttachment.textView(_:shouldInteractWith:in:interaction:)),
    #selector(UITextViewDelegate.textViewDidBeginEditing(_:)),
    #selector(UITextViewDelegate.textViewDidChange(_:)),
    #selector(UITextViewDelegate.textViewDidChangeSelection(_:)),
    #selector(UITextViewDelegate.textViewDidEndEditing(_:)),
    #selector(UITextViewDelegate.textViewShouldBeginEditing(_:)),
    #selector(UITextViewDelegate.textViewShouldEndEditing(_:))
]

class TextViewDelegateForwarder: NSObject, UITextViewDelegate {
    weak var scrollViewDelegate: UIScrollViewDelegate?
    weak var textViewDelegate: UITextViewDelegate?

    override func responds(to aSelector: Selector!) -> Bool {
        if scrollViewDelegateSelectors.contains(aSelector) {
            return scrollViewDelegate?.responds(to: aSelector) ?? false
        }
        if textViewDelegateSelectors.contains(aSelector) {
            return textViewDelegate?.responds(to: aSelector) ?? false
        }
        return super.responds(to: aSelector)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if scrollViewDelegateSelectors.contains(aSelector) {
            return scrollViewDelegate
        }
        if textViewDelegateSelectors.contains(aSelector) {
            return textViewDelegate
        }
        return super.forwardingTarget(for: aSelector)
    }
}
