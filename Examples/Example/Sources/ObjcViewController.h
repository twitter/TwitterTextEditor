//
//  ObjcViewController.h
//  Example
//
//  Created on 3/26/20.
//  Copyright © 2020 Twitter, Inc. All rights reserved.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class ObjcViewController;

@protocol ObjcViewControllerDelegate <NSObject>

@optional
- (void)objcViewControllerDidTapDone:(ObjcViewController *)objcViewController;

@end

@interface ObjcViewController : UIViewController

@property (nonatomic, weak, nullable) id<ObjcViewControllerDelegate> delegate;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
