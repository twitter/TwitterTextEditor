# Changelog

## 1.1.2

- FIX: `TextViewDelegateForwarder` only forwards limited `UIScrollViewDelegate` methods (#19)

## 1.1.1

- FIX: `ContentFilterScheduler` is using wrong key for cache.
- Disable a workaround for the bug fixed on iOS 14.5.

## 1.1.0

- Change `Root.plist` in `Settings.bundle` to have default value `NO` (#3)
- FIX: Setting `TextEditorView.scrollView.delegate` may break behavior (#6)
- Conform to `UITextInputTraits`.
- Add `returnToEndEditingEnabled`. This allows users to implement single line text editor behavior.
- Expose `inputView` and `reloadInputViews` methods (#15)
- Update `UIResponder` methods.

## 1.0.0

- Initial release.
