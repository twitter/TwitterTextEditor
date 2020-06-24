//
//  ObjcViewController.m
//  Example
//
//  Copyright 2021 Twitter, Inc.
//  SPDX-License-Identifier: Apache-2.0
//


#import "Example-Swift.h"
#import "ObjcViewController.h"

@import KeyboardGuide;

NS_ASSUME_NONNULL_BEGIN

@interface ObjcViewController () <TextEditorBridgeViewDelegate>

@property (nonatomic, nullable) TextEditorBridgeView *textEditorView;

@end

@implementation ObjcViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    [self doesNotRecognizeSelector:_cmd];
    abort();
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    [self doesNotRecognizeSelector:_cmd];
    abort();
}

- (instancetype)init
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.title = @"Objective-C example";

        UIBarButtonItem * const refreshBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                          target:self
                                                          action:@selector(refreshBarButtonItemDidTap:)];
        self.navigationItem.leftBarButtonItems = @[refreshBarButtonItem];
        UIBarButtonItem * const doneBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                          target:self
                                                          action:@selector(doneBarButtonItemDidTap:)];
        self.navigationItem.rightBarButtonItems = @[doneBarButtonItem];
    }
    return self;
}

// MARK: - Actions

- (void)refreshBarButtonItemDidTap:(id)sender
{
    self.textEditorView.isEditing = NO;
    self.textEditorView.text = @"";
}

- (void)doneBarButtonItemDidTap:(id)sender
{
    id<ObjcViewControllerDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(objcViewControllerDidTapDone:)]) {
        [delegate objcViewControllerDidTapDone:self];
    }
}

// MARK: - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.defaultBackgroundColor;

    NSMutableArray<NSLayoutConstraint *> * const constraints = [[NSMutableArray alloc] init];

    TextEditorBridgeView * const textEditorView = [[TextEditorBridgeView alloc] init];
    textEditorView.delegate = self;

    textEditorView.layer.borderColor = UIColor.defaultBorderColor.CGColor;
    textEditorView.layer.borderWidth = 1.0;

    textEditorView.font = [UIFont systemFontOfSize:20.0];

    [self.view addSubview:textEditorView];

    textEditorView.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObject:[textEditorView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant: 20.0]];
    [constraints addObject:[textEditorView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor]];
    [constraints addObject:[textEditorView.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor]];
    [constraints addObject:[textEditorView.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor]];

    self.textEditorView = textEditorView;

    // This view is used to call `layoutSubviews` when keyboard safe area is changed
    // to manually change scroll view content insets.
    // See `viewDidLayoutSubviews`.
    UIView * const keyboardSafeAreaRelativeLayoutView = [[UIView alloc] init];
    [self.view addSubview:keyboardSafeAreaRelativeLayoutView];
    keyboardSafeAreaRelativeLayoutView.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObject:[keyboardSafeAreaRelativeLayoutView.bottomAnchor constraintEqualToAnchor:self.view.kbg_keyboardSafeArea.layoutGuide.bottomAnchor]];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    const CGFloat bottomInset = self.view.kbg_keyboardSafeArea.insets.bottom - self.view.layoutMargins.bottom;

    UIEdgeInsets contentInset = self.textEditorView.scrollView.contentInset;
    contentInset.bottom = bottomInset;
    self.textEditorView.scrollView.contentInset = contentInset;

    if (@available(iOS 11.1, *)) {
        UIEdgeInsets verticalScrollIndicatorInsets = self.textEditorView.scrollView.verticalScrollIndicatorInsets;
        verticalScrollIndicatorInsets.bottom = bottomInset;
        self.textEditorView.scrollView.verticalScrollIndicatorInsets = verticalScrollIndicatorInsets;
    } else {
        UIEdgeInsets scrollIndicatorInsets = self.textEditorView.scrollView.scrollIndicatorInsets;
        scrollIndicatorInsets.bottom = bottomInset;
        self.textEditorView.scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
    }
}

// MARK: - TextEditorBridgeViewDelegate

- (void)textEditorBridgeView:(TextEditorBridgeView *)textEditorBridgeView
      updateAttributedString:(NSAttributedString *)attributedString
                  completion:(void (^)(NSAttributedString * _Nullable))completion
{
    NSMutableAttributedString * const text = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    const NSRange range = NSMakeRange(0, text.string.length);

    [text addAttribute:NSForegroundColorAttributeName value:UIColor.defaultTextColor range:range];

    NSRegularExpression * const regexp = [[NSRegularExpression alloc] initWithPattern:@"#[^\\s]+" options:0 error:nil];
    [regexp enumerateMatchesInString:text.string
                             options:0
                               range:range
                          usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (!result) {
            return;
        }
        const NSRange matchedRange = result.range;
        [text addAttribute:NSForegroundColorAttributeName value:UIColor.systemBlueColor range:matchedRange];
    }];

    completion(text);
}

@end

NS_ASSUME_NONNULL_END
