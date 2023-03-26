# Contributing

We would love to get contributions from you.


## Issues

When creating an issue please try to use the following format.
Good issue reports are extremely helpful, thank you.

```
One line summary of the issue

Details of the issue.

**Steps to reproduce the behavior**

- List all relevant steps to reproduce the observed behavior.

**Expected behavior**

As concisely as possible, describe the expected behavior.

**Actual behavior**

As concisely as possible, describe the observed behavior.

**Environment**

- Operating system name, version, and build number, such as “iOS 14.0.1 (18A393)”.
- Hardware name and revision, such as “iPhone 11 Pro”.
- Xcode version and build number, such as “12.0 (12A7209)”.
- Any other dependencies, such as third-party keyboard and its version, if it’s applicable.
```

## Pull requests

If you would like to test and/or contribute please follow these instructions.

### Workflow

We follow the [GitHub Flow Workflow](https://guides.github.com/introduction/flow/)

1. Fork the repository.
1. Check out the default branch.
1. Create a feature branch.
1. Write code and tests if possible for your change.
1. From your branch, make a pull request against the default branch.
1. Work with repository maintainers to get your change reviewed.
1. Wait for your change to be pulled into the default branch.
1. Delete your feature branch.

### Development

It is useful to use [`Example.xcodeproj`](Examples/) for actual Twitter Text Editor development.

### Testing

Use regular `XCTest` and Swift Package structure.

It is highly recommended to write unit tests for applicable modules, such as the module that provides specific logics.
However often it is not easy for writing unit tests for the part of user interactions on user interface components.

Therefore, unlike many other cases, writing unit test is still highly recommended yet not absolutely required.
Instead, write a detailed comments about problems, solution, and testing in the pull request by following the guidelines below.

Use following command to run all tests.

```
$ make test
```

### Linting

It is using [SwiftLint](https://github.com/realm/SwiftLint) to lint Swift code.
Install it by using such as [Homebrew](https://brew.sh/).

Use following command to execute linting.

```
$ make lint
```

Use following command to fix linting problems.

```
$ make fix
```

### Documentation

It is using [Jazzy](https://github.com/realm/jazzy) to generate documents from the inline documentation comments.

Use following command to install Jazzy locally and update the documents.
The documents generated are placed at `.build/documentation`.

```
$ make doc
```

Use following command to run a local web server for browsing the documents.
It keeps updating the documents when any source files are changed.

You can browse it at <http://localhost:3000/>.

```
$ make doc-server
```

### Submit pull requests

Files should be exempt of trailing spaces, linted and passed all unit tests.

Pull request comments should be formatted to a width no greater than 72 characters.

We adhere to a specific format for commit messages.
Please write your commit messages along these guidelines.

```
One line description of your change (less than 72 characters)

**Problems**

Explain the context and why you’re making that change. What is the
problem you’re trying to solve?
In some cases there is not a problem and this can be thought of
being the motivation for your change.

**Solution**

Describe the modifications you’ve done.

**Testing**

Describe the way to test your change.
```

Some important notes regarding the summary line.

* Describe what was done; not the result.
* Use the active voice.
* Use the present tense.
* Capitalize properly.
* Do not end in a period. This is a title or subject.


### Code review

This repository on GitHub is kept in sync with an internal repository at Twitter.
For the most part this process should be transparent to the repository users, but it does have some implications for how pull requests are merged into the codebase.

When you submit a pull request on GitHub, it will be reviewed by the community (both inside and outside of Twitter), and once the changes are approved, your commits will be brought into Twitter’s internal system for additional testing.
Once the changes are merged internally, they will be pushed back to GitHub with the next sync.

This process means that the pull request will not be merged in the usual way.
Instead a member of the repository owner will post a message in the pull request thread when your changes have made their way back to GitHub, and the pull request will be closed.
The changes in the pull request will be collapsed into a single commit, but the authorship metadata will be preserved.


## License

By contributing your code, you agree to license your contribution under the terms of [the Apache License, Version 2.0](LICENSE).
