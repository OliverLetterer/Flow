//
//  _FLWTutorialWindow.m
//  Flow
//
//  The MIT License (MIT)
//  Copyright (c) 2014 Oliver Letterer, Sparrow-Labs
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "_FLWTutorialWindow.h"
#import "_FLWTutorialOverlayView.h"
#import <objc/runtime.h>

static NSInteger numberOfWindowInstances = 0;

static void class_swizzleSelector(Class class, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    if(class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}



@interface _FLWWindowRootViewController : UIViewController

@end

@implementation _FLWWindowRootViewController

- (UIViewController *)rootViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (rootViewController.presentedViewController) {
        UIViewController *nextViewController = rootViewController.presentedViewController;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            BOOL viewControllerDefinesStatusBarStyle = nextViewController.modalPresentationStyle == UIModalPresentationFullScreen || nextViewController.modalPresentationStyle == UIModalPresentationCustom;
            if (!viewControllerDefinesStatusBarStyle) {
                break;
            }
        }

        rootViewController = nextViewController;
    }

    return rootViewController;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }

    return rootViewController.supportedInterfaceOrientations;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[self rootViewController] preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [[self rootViewController] prefersStatusBarHidden];
}

@end



@implementation _FLWTutorialWindow

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;

        self.rootViewController = [[_FLWWindowRootViewController alloc] init];
        self.rootViewController.view.backgroundColor = [UIColor clearColor];

        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [self makeKeyAndVisible]; [keyWindow makeKeyAndVisible];

        numberOfWindowInstances++;
    }
    return self;
}

- (void)dealloc
{
    numberOfWindowInstances--;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitTestView = [super hitTest:point withEvent:event];
    return [hitTestView isKindOfClass:[UIControl class]] || [hitTestView isKindOfClass:[_FLWTutorialOverlayView class]] ? hitTestView : nil;
}

@end



@implementation UIViewController (Flow)

+ (void)load
{
    class_swizzleSelector(self, @selector(setNeedsStatusBarAppearanceUpdate), @selector(__FlowSetNeedsStatusBarAppearanceUpdate));
}

- (void)__FlowSetNeedsStatusBarAppearanceUpdate
{
    [self __FlowSetNeedsStatusBarAppearanceUpdate];

    if (numberOfWindowInstances > 0 && self.isViewLoaded && self.view.window == [UIApplication sharedApplication].delegate.window) {
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if ([window isKindOfClass:[_FLWTutorialWindow class]]) {
                [window.rootViewController setNeedsStatusBarAppearanceUpdate];
            }
        }
    }
}

@end
