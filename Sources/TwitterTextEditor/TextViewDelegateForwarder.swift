//
//  TextViewDelegateForwarder.swift
//  TwitterTextEditor
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

final class TextViewDelegateForwarder: NSObject {
    weak var scrollViewDelegate: UIScrollViewDelegate?
    weak var textViewDelegate: UITextViewDelegate?
}

/// :nodoc:
extension TextViewDelegateForwarder: UITextViewDelegate {
    // This is a subset of `UITextViewDelegate` methods implementations except `UIScrollViewDelegate` methods,
    // which is known to be used from `TextEditorView`.

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return textViewDelegate?.textViewShouldBeginEditing?(textView) ?? false
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        textViewDelegate?.textViewDidBeginEditing?(textView)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        textViewDelegate?.textViewDidEndEditing?(textView)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textViewDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        textViewDelegate?.textViewDidChangeSelection?(textView)
    }

    public func textViewDidChange(_ textView: UITextView) {
        textViewDelegate?.textViewDidChange?(textView)
    }
}

/// :nodoc:
extension TextViewDelegateForwarder: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidZoom?(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollViewDelegate?.viewForZooming?(in: scrollView)
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        // If the delegate doesn’t implement this method, `true` is assumed.
        return scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}
