//
//  FLWMainViewController.m
//  FlowSample
//
//  Created by Oliver Letterer on 25.04.14.
//  Copyright 2014 Sparrow-Labs. All rights reserved.
//

#import "FLWMainViewController.h"
#import "Flow.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>



static NSString * const FLWMainViewControllerFirstTutorial = @"FLWMainViewController.firstTutorial";
static NSString * const FLWMainViewControllerSecondTutorial = @"FLWMainViewController.secondTutorial";
static NSString * const FLWMainViewControllerThirdTutorial = @"FLWMainViewController.thirdTutorial";

@interface FLWMainViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *firstBackgroundView;
@property (nonatomic, strong) UIView *secondBackgroundView;

@end



@implementation FLWMainViewController

#pragma mark - setters and getters

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        
        if ([self respondsToSelector:@selector(setRestorationIdentifier:)]) {
            self.restorationIdentifier = NSStringFromClass(self.class);
            self.restorationClass = self.class;
        }
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];

    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];

    _firstBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _firstBackgroundView.backgroundColor = [UIColor lightGrayColor];
    [_scrollView addSubview:_firstBackgroundView];

    _secondBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _secondBackgroundView.backgroundColor = [UIColor darkGrayColor];
    [_scrollView addSubview:_secondBackgroundView];

    UIButton *firstTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [firstTutorialButton setTitle:@"Tap here to complete first tutorial" forState:UIControlStateNormal];
    firstTutorialButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [firstTutorialButton addTarget:self action:@selector(_firstTutorialButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [firstTutorialButton sizeToFit];
    firstTutorialButton.center = CGPointMake(CGRectGetMidX(_firstBackgroundView.bounds), CGRectGetMidY(_firstBackgroundView.bounds));
    [_firstBackgroundView addSubview:firstTutorialButton];

    UIButton *secondTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [secondTutorialButton setTitle:@"Tap here to complete third tutorial" forState:UIControlStateNormal];
    secondTutorialButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [secondTutorialButton addTarget:self action:@selector(_secondTutorialButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [secondTutorialButton sizeToFit];
    secondTutorialButton.center = CGPointMake(CGRectGetMidX(_secondBackgroundView.bounds), CGRectGetMidY(_secondBackgroundView.bounds));
    [_secondBackgroundView addSubview:secondTutorialButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    __weak typeof(self) weakSelf = self;
    [[FLWTutorialController sharedInstance] scheduleTutorialWithIdentifier:FLWMainViewControllerFirstTutorial afterDelay:2.0 withPredicate:^BOOL{
        __strong typeof(self) strongSelf = weakSelf;
        return strongSelf.scrollView.contentOffset.x <= 0.0;
    } constructionBlock:^(id<FLWTutorial> tutorial) {
        __strong typeof(self) strongSelf = weakSelf;

        UIView *buttonView = strongSelf.firstBackgroundView.subviews.firstObject;

        tutorial.title = @"To begin, you need to tap the first button";
        tutorial.successMessage = @"Great";
        tutorial.gesture = [[FLWTapGesture alloc] initWithTouchPoint:CGPointMake(CGRectGetMidX(buttonView.bounds), CGRectGetMidY(buttonView.bounds)) inView:buttonView];
    }];

    [[FLWTutorialController sharedInstance] scheduleTutorialWithIdentifier:FLWMainViewControllerSecondTutorial afterDelay:2.0 withPredicate:NULL constructionBlock:^(id<FLWTutorial> tutorial) {
        __strong typeof(self) strongSelf = weakSelf;

        tutorial.title = @"You can now swipe to the second page";
        tutorial.successMessage = @"Excellent";

        tutorial.gesture = [[FLWSwipeGesture alloc] initWithSwipeFromPoint:CGPointMake(CGRectGetWidth(strongSelf.view.bounds) * 0.8, CGRectGetMidY(strongSelf.view.bounds))
                                                                   toPoint:CGPointMake(CGRectGetWidth(strongSelf.view.bounds) * 0.2, CGRectGetMidY(strongSelf.view.bounds))
                                                                    inView:strongSelf.view];
    }];

    [[FLWTutorialController sharedInstance] scheduleTutorialWithIdentifier:FLWMainViewControllerThirdTutorial afterDelay:0.0 withPredicate:^BOOL{
        __strong typeof(self) strongSelf = weakSelf;
        return strongSelf.scrollView.contentOffset.x >= CGRectGetWidth(strongSelf.view.bounds);
    } constructionBlock:^(id<FLWTutorial> tutorial) {
        __strong typeof(self) strongSelf = weakSelf;

        UIView *buttonView = strongSelf.secondBackgroundView.subviews.firstObject;

        tutorial.title = @"To complete this tutorial, tap the second button";
        tutorial.successMessage = @"Perfect, have fun using the app";
        tutorial.gesture = [[FLWTapGesture alloc] initWithTouchPoint:CGPointMake(CGRectGetMidX(buttonView.bounds), CGRectGetMidY(buttonView.bounds)) inView:buttonView];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[FLWTutorialController sharedInstance] invalidateTutorialWithIdentifier:FLWMainViewControllerFirstTutorial];
    [[FLWTutorialController sharedInstance] invalidateTutorialWithIdentifier:FLWMainViewControllerSecondTutorial];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect bounds = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(bounds) * 2.0, CGRectGetHeight(bounds));

    self.firstBackgroundView.frame = bounds;
    self.secondBackgroundView.frame = CGRectMake(CGRectGetWidth(bounds), 0.0, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat progress = scrollView.contentOffset.x / CGRectGetWidth(self.view.bounds);
    [[FLWTutorialController sharedInstance] setProgress:progress inTutorialWithIdentifier:FLWMainViewControllerSecondTutorial];

    if (progress >= 1.0) {
        [[FLWTutorialController sharedInstance] completeTutorialWithIdentifier:FLWMainViewControllerSecondTutorial];
    }
}

#pragma mark - Private category implementation ()

- (void)_firstTutorialButtonTapped:(UIButton *)sender
{
    [[FLWTutorialController sharedInstance] completeTutorialWithIdentifier:FLWMainViewControllerFirstTutorial];
}

- (void)_secondTutorialButtonTapped:(UIButton *)sender
{
    [[FLWTutorialController sharedInstance] completeTutorialWithIdentifier:FLWMainViewControllerThirdTutorial];
}

@end
