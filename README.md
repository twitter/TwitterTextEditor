# Twitter Text Editor

A standalone, flexible API that provides a full featured rich text editor for iOS applications.

![Twitter Text Editor](Resources/TwitterTextEditor.png)

This provides a robust text attribute update logic, extended text editing events, and safe text input event handling in easy delegate based APIs.
TwitterTextEditor supports recent versions of iOS.

## Requirements

Twitter Text Editor requires macOS Catalina 10.15 or later and Xcode 11.0 and later for the development.
At this moment, Twitter Text Editor supports iOS 11.0 and later also macCatalyst 13.0 and later.


## Usage

Using Twitter Text Editor is straightforward if you're familiar with iOS development. See
also [Examples](Examples/) for actual usage, that contains Swift and Objective-C source code
to show how to use Twitter Text Editor. See [`Examples/README.md`](Examples/README.md) as well.

### Add Twitter Text Editor framework to your project

Add the following lines to your `Package.swift` or use Xcode “Add Package Dependency…” menu.

```swift
// In your `Package.swift`

dependencies: [
    .package(name: "TwitterTextEditor", url: "https://github.com/twitter/TwitterTextEditor", ...),
    ...
],
targets: [
    .target(
        name: ...,
        dependencies: [
            .product(name: "TwitterTextEditor", package: "TwitterTextEditor"),
            ...
        ]
    ),
    ...
]
```

### Use with other dependency management tools

In case your project is not using Swift Package Manager,
you can use Twitter Text Editor with other dependency management tools.

#### CocoaPods

To use Twitter Text Editor with [CocoaPods](https://cocoapods.org/), add next `TwitterTextEditor.podspec` in your project.

```ruby
Pod::Spec.new do |spec|
  spec.name = "TwitterTextEditor"
  spec.version = "1.0.0" # Find the the version from the Git tags
  spec.authors = ""
  spec.summary = "TwitterTextEditor"
  spec.homepage = "https://github.com/twitter/TwitterTextEditor"
  spec.platform = :ios, "11.0"
  spec.source = {
    :git => "https://github.com/twitter/TwitterTextEditor.git", :tag => "#{spec.version}"
  }
  spec.source_files  = "Sources/TwitterTextEditor/*.swift"
end
```

Then, update `Podfile` in your project.

```ruby
pod 'TwitterTextEditor', :podspec => 'path/to/TwitterTextEditor.podspec'
```

#### Carthage

To use Twitter Text Editor with [Carthage](https://github.com/Carthage/Carthage), update `Cartfile` in your project.

```
github "twitter/TwitterTextEditor"
```

Then, run following commands. This will create `Carthage/Build/iOS/TwitterTextEditor.framework`.

```
$ carthage update
$ (cd Carthage/Checkouts/TwitterTextEditor && swift package generate-xcodeproj)
$ carthage build --platform iOS
```

Follow [the instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)
to add the framework and Run Script phase to your project.

### Documentation

See [documentation](https://twitter.github.io/TwitterTextEditor/doc/).


## Use Twitter Text Editor in your project

Twitter Text Editor provides a single view, `TextEditorView`, that has a similar API
to `UITextView` and provides the most of features as a property or a delegate callback.

Add it to your project as like the other views, and setup using each property or implement delegate callbacks.

```swift
// In your view controller

import TwitterTextEditor

final class MyViewController: UIViewController {
    // ...

    override func viewDidLoad() {
        super.viewDidLoad()
        // ...
        let textEditorView = TextEditorView()
        textEditorView.text = "Meow"
        textEditorView.textAttributesDelegate = self
        // ...
    }

    // ...
}

extension MyViewController: TextEditorViewTextAttributesDelegate {
    func textEditorView(_ textEditorView: TextEditorView,
                        updateAttributedString attributedString: NSAttributedString,
                        completion: @escaping (NSAttributedString?) -> Void)
    {
        // ...
    }
}
```


## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the details.


## Security issues

Please report sensitive security issues via [Twitter’s bug-bounty program](https://hackerone.com/twitter) rather than GitHub.
