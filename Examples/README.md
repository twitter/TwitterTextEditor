# Twitter Text Editor Example

This is an example project to show how to use Twitter Text Editor in a real application.
The example application demonstrates the following features.

- How to implement syntax highlighting.
- How to implement text filtering.
- How to implement simple autocompletion.
- Supporting custom pasting and dropping items.


## Usage

Select `Example` scheme with preferred iOS simulator and simply run it.

### Running example application on the device

You need to manually select your own “Provisioning Profile” that matches to this example project
in “Signing and Capabilities” tab for Example target.


## Structure

### `Example/Sources`

This group contains both Swift and Objective-C example source code.

- `Objective-C Examples`

    This group contains example Objective-C also Swift source code to show how to use Twitter Text Editor API from Objective-C project.
    It contains API bridge examples as well.

- `Swift Examples`

    This group contains example Swift source code to show how to use Twitter Text Editor in your view controller.

### `Packages/TwitterTextEditor`

This is referencing local Twitter Text Editor package itself.
It is useful for actual Twitter Text Editor development.

It is following standard Swift Package Manager structure.
