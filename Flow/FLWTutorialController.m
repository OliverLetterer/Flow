//
//  FLWTutorialController.m
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

#import "FLWTutorialController.h"
#import "_FLWTutorial.h"
#import "_FLWTutorialOverlayView.h"
#import "_FLWTutorialWindow.h"
#import "_FLWTutorialTouchIndicatorView.h"

static CGFloat preferredTutorialHeight = 44.0 + 20.0;
static CGFloat slideInAndOutDuration = 0.5;

static NSString *globalIdentifierForIdentifier(NSString *identifier)
{
    NSCParameterAssert(identifier);
    return [NSString stringWithFormat:@"FLWTutorialController.%@", identifier];
}



@interface FLWTutorialController () <_FLWTutorialOverlayViewDelegate>

@property (nonatomic, strong) _FLWTutorialWindow *window;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval lastDisplayLinkCallback;

@property (nonatomic, strong) NSMutableArray *scheduledTutorials;

@property (nonatomic, strong) _FLWTutorial *activeTutorial;
@property (nonatomic, strong) _FLWTutorialOverlayView *overlayView;
@property (nonatomic, strong) UIView *gestureView;

@end





@implementation FLWTutorialController

#pragma mark - Instance methods

- (void)setProgress:(CGFloat)progress inTutorialWithIdentifier:(NSString *)identifier
{
    _FLWTutorial *tutorial = [self _tutorialWithIdentifier:identifier];
    tutorial.progress = progress;

    if (tutorial == self.activeTutorial) {
        self.overlayView.progress = progress;
    }
}

- (void)scheduleTutorialWithIdentifier:(NSString *)identifier afterDelay:(NSTimeInterval)delay withPredicate:(FLWBlockPredicate)predicate constructionBlock:(void(^)(id<FLWTutorial> tutorial))constructionBlock
{
    NSParameterAssert([NSThread currentThread].isMainThread);
    NSParameterAssert(constructionBlock);

    if ([self _hasCompletedTutorialWithIdentifier:identifier]) {
        return;
    }

    if ([self _tutorialWithIdentifier:identifier]) {
        return;
    }

    _FLWTutorial *tutorial = [[_FLWTutorial alloc] initWithIdentifier:identifier];
    tutorial.predicate = predicate;
    tutorial.remainingDuration = delay;
    tutorial.state = FLWTutorialStateScheduled;
    tutorial.constructionBlock = constructionBlock;

    [self.scheduledTutorials addObject:tutorial];
    [self _numberOfTutorialsChanged];
}

- (void)invalidateTutorialWithIdentifier:(NSString *)identifier
{
    NSParameterAssert([NSThread currentThread].isMainThread);

    _FLWTutorial *tutorial = [self _tutorialWithIdentifier:identifier];

    if (tutorial.state == FLWTutorialStateRunning) {
        if (tutorial.isTransitioningToFinish) {
            return;
        } else {
            NSParameterAssert(tutorial == self.activeTutorial);
            [self _finishActiveTutorialWithSuccess:NO];
        }
    } else {
        [self.scheduledTutorials removeObject:tutorial];
        [self _numberOfTutorialsChanged];
    }
}

- (void)completeTutorialWithIdentifier:(NSString *)identifier
{
    NSParameterAssert([NSThread currentThread].isMainThread);

    [self _setCompleted:YES forTutorialWithIdentifier:identifier];
    _FLWTutorial *tutorial = [self _tutorialWithIdentifier:identifier];

    if (tutorial.state == FLWTutorialStateRunning) {
        if (tutorial.isTransitioningToFinish) {
            return;
        } else {
            NSParameterAssert(tutorial == self.activeTutorial);
            [self _finishActiveTutorialWithSuccess:YES];
        }
    } else {
        [self.scheduledTutorials removeObject:tutorial];
        [self _numberOfTutorialsChanged];
    }
}

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init]) {
        _scheduledTutorials = [NSMutableArray array];

        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_displayLinkCallback:)];
        _displayLink.paused = YES;
        _displayLink.frameInterval = 10;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

#pragma mark - _FLWTutorialOverlayViewDelegate

- (void)tutorialOverlayViewDidCancel:(_FLWTutorialOverlayView *)overlayView
{
    _FLWTutorial *activeTutorial = self.activeTutorial;
    BOOL shouldUpdateCancellationCount = !activeTutorial.isTransitioningToFinish;

    [self invalidateTutorialWithIdentifier:activeTutorial.identifier];
    if (shouldUpdateCancellationCount) {
        [self _updateCancellationCountOfTutorial:activeTutorial];
    }
}

#pragma mark - Private category implementation ()

- (BOOL)_hasCompletedTutorialWithIdentifier:(NSString *)identifier
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:globalIdentifierForIdentifier(identifier)];
}

- (void)_setCompleted:(BOOL)completed forTutorialWithIdentifier:(NSString *)identifier
{
    [[NSUserDefaults standardUserDefaults] setBool:completed forKey:globalIdentifierForIdentifier(identifier)];
}

- (void)_numberOfTutorialsChanged
{
    self.displayLink.paused = self.scheduledTutorials.count == 0;

    if (self.displayLink.isPaused) {
        self.lastDisplayLinkCallback = 0.0;
        self.window = nil;
    } else {
        if (!self.window) {
            self.window = [[_FLWTutorialWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
    }
}

- (void)_displayLinkCallback:(CADisplayLink *)displayLink
{
    if (self.lastDisplayLinkCallback == 0.0) {
        self.lastDisplayLinkCallback = displayLink.timestamp;
    }

    NSTimeInterval passedDuration = displayLink.timestamp - self.lastDisplayLinkCallback;
    self.lastDisplayLinkCallback = displayLink.timestamp;

    BOOL alertOrActionSheetIsVisible = [UIApplication sharedApplication].keyWindow != [UIApplication sharedApplication].delegate.window;
    if (alertOrActionSheetIsVisible) {
        return;
    }

    if (self.activeTutorial) {
        [self _updateActiveTutorialWithPassedDuration:passedDuration];
        return;
    }

    [self _countRemainingTutorialTimeDownWithPassedDuration:passedDuration];
    [self _checkForNextTutorial];
}

- (_FLWTutorial *)_tutorialWithIdentifier:(NSString *)identifier
{
    for (_FLWTutorial *tutorial in self.scheduledTutorials) {
        if ([tutorial.identifier isEqualToString:identifier]) {
            return tutorial;
        }
    }

    return nil;
}

- (void)_countRemainingTutorialTimeDownWithPassedDuration:(NSTimeInterval)passedDuration
{
    for (_FLWTutorial *tutorial in self.scheduledTutorials) {
        if (tutorial.predicate && !tutorial.predicate()) {
            continue;
        }
        
        tutorial.remainingDuration -= passedDuration;
    }
}

- (void)_checkForNextTutorial
{
    for (_FLWTutorial *tutorial in self.scheduledTutorials) {
        if (tutorial.canStartTutorial && [self _startTutorial:tutorial]) {
            break;
        }
    }
}

- (void)_updateActiveTutorialWithPassedDuration:(NSTimeInterval)passedDuration
{
    if (self.activeTutorial.isTransitioningToRunning) {
        return;
    }

    CGFloat progress = self.activeTutorial.gesture.progress + passedDuration / self.activeTutorial.gesture.duration;

    if (self.activeTutorial.isTransitioningToFinish && progress >= 1.0) {
        progress = 1.0;
    }

    [self.activeTutorial.gesture setProgress:fmod(progress, 1.0) onView:self.gestureView];

    if (self.activeTutorial.isTransitioningToFinish) {
        CGFloat fadeOutProgress = self.activeTutorial.fadeOutProgress + passedDuration / slideInAndOutDuration;
        self.activeTutorial.fadeOutProgress = fadeOutProgress;

        self.gestureView.alpha *= 1.0 - fadeOutProgress;
    }
}

- (BOOL)_tutorialSatisfiesDependentTutorialIdentifiers:(_FLWTutorial *)tutorial
{
    for (NSString *identifier in tutorial.dependentTutorialIdentifiers) {
        if (![self _hasCompletedTutorialWithIdentifier:identifier]) {
            NSLog(@"tutorial %@ cannot start because of %@", tutorial, identifier);
            return NO;
        }
    }

    return YES;
}

- (void)_updateCancellationCountOfTutorial:(_FLWTutorial *)tutorial
{
    NSString *tutorialIdentifier = globalIdentifierForIdentifier(tutorial.identifier);
    NSString *failCountIdentifier = [tutorialIdentifier stringByAppendingString:@".cancellationCount"];
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:failCountIdentifier];
    count++;

    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:failCountIdentifier];

    BOOL shouldMarkTutorialAsCompleted = count >= 3;
    if (shouldMarkTutorialAsCompleted) {
        [self _setCompleted:YES forTutorialWithIdentifier:tutorialIdentifier];
    }
}

#pragma mark - tutorial methods

- (BOOL)_startTutorial:(_FLWTutorial *)tutorial
{
    self.displayLink.frameInterval = 1;

    tutorial.constructionBlock(tutorial);
    if (![self _tutorialSatisfiesDependentTutorialIdentifiers:tutorial]) {
        return NO;
    }

    NSParameterAssert(self.activeTutorial == nil);
    self.activeTutorial = tutorial;
    self.activeTutorial.state = FLWTutorialStateRunning;
    self.activeTutorial.isTransitioningToFinish = NO;
    self.activeTutorial.isTransitioningToRunning = YES;

    [self.activeTutorial speakText:self.activeTutorial.title];

    UIView *containerView = self.window.rootViewController.view;
    static CGFloat additionalHeight = 50.0;

    self.overlayView = [[_FLWTutorialOverlayView alloc] initWithFrame:CGRectMake(0.0, -additionalHeight, CGRectGetWidth(containerView.bounds), preferredTutorialHeight + additionalHeight)];
    self.overlayView.delegate = self;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.overlayView.textLabel.text = self.activeTutorial.title;
    self.overlayView.transform = CGAffineTransformMakeTranslation(0.0, - preferredTutorialHeight);
    self.overlayView.progress = tutorial.progress;
    [containerView addSubview:self.overlayView];

    if (self.activeTutorial.gesture) {
        self.gestureView = [self.activeTutorial.gesture respondsToSelector:@selector(gestureViewClass)] ? [[self.activeTutorial.gesture.gestureViewClass alloc] initWithFrame:CGRectZero] : [[_FLWTutorialTouchIndicatorView alloc] initWithFrame:CGRectZero];
    }
    [self.gestureView sizeToFit];
    [containerView addSubview:self.gestureView];

    [self.activeTutorial.gesture setProgress:0.0 onView:self.gestureView];

    [UIView animateWithDuration:slideInAndOutDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        self.overlayView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        tutorial.isTransitioningToRunning = NO;
    }];

    return YES;
}

- (void)_finishActiveTutorialWithSuccess:(BOOL)success
{
    self.activeTutorial.isTransitioningToFinish = YES;
    self.overlayView.progress = success ? 1.0 : 0.0;

    if (success && self.activeTutorial.successMessage) {
        self.overlayView.textLabel.text = self.activeTutorial.successMessage;
        [self.activeTutorial speakText:self.activeTutorial.successMessage];
    }

    void(^nowPerformSlideOutAnimation)(void) = ^{
        [UIView animateWithDuration:slideInAndOutDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:kNilOptions animations:^{
            self.overlayView.transform = CGAffineTransformMakeTranslation(0.0, - preferredTutorialHeight);
        } completion:^(BOOL finished) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;

            self.activeTutorial.state = FLWTutorialStateFinished;
            [self.scheduledTutorials removeObject:self.activeTutorial];
            self.activeTutorial = nil;

            [self.gestureView removeFromSuperview];
            self.gestureView = nil;

            self.displayLink.frameInterval = 10;
            [self _numberOfTutorialsChanged];
        }];
    };

    if (success) {
        [self.overlayView bounceProgressView];
    }

    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn;
    [UIView animateWithDuration:0.3 delay:0.0 options:options animations:^{
        if (success) {
            self.overlayView.backgroundColor = [UIColor colorWithRed:59.0 / 255.0 green:208.0 / 255.0 blue:82.0 / 255.0 alpha:1.0];
        }
    } completion:^(BOOL finished) {
        if (!success && self.activeTutorial.isSpeeking) {
            [self.activeTutorial cancelSpeeking];
        }
        
        if (self.activeTutorial.isSpeeking) {
            [self.activeTutorial executeBlockAfterCurrentSpeechFinished:nowPerformSlideOutAnimation];
        } else {
            nowPerformSlideOutAnimation();
        }
    }];
}

@end



#pragma mark - Singleton implementation

@implementation FLWTutorialController (Singleton)

+ (FLWTutorialController *)sharedInstance 
{
    static FLWTutorialController *_instance = nil;
    
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone 
{	
	return [self sharedInstance];	
}

- (id)copyWithZone:(NSZone *)zone 
{
    return self;	
}

@end
