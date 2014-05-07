//
//  FLWTutorialController.h
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

#import "FLWTouchGesture.h"

typedef BOOL(^FLWBlockPredicate)(void);

/**
 Sent right before FLWTutorialController will start a new tutorial.
 */
extern NSString * const FLWTutorialControllerWillStartTutorialNotification;

/**
 Sent after the the user completed a tutorial.
 */
extern NSString * const FLWTutorialControllerDidCompleteTutorialNotification;

/**
 Sent after a tutorial got cancelled.
 */
extern NSString * const FLWTutorialControllerDidCancelTutorialNotification;

/**
 userInfo key where an instance of id<FLWTutorial> is available.
 */
extern NSString * const FLWTutorialControllerTutorialKey;



/**
 Will plan one of many random success messages when assigned to FLWTutorial.successMessage.
 */
extern NSString * const FLWTutorialRandomSuccessMessage;

@protocol FLWTutorial <NSObject>

@property (nonatomic, assign) BOOL respectsSilentSwitch; // defaults to no

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *successMessage;
@property (nonatomic, strong) id<FLWTouchGesture> gesture;

@property (nonatomic, copy) NSString *repeatMessage;
@property (nonatomic, assign) NSTimeInterval repeatInterval; // defaults to 20.0

@property (nonatomic, assign) BOOL speechSynthesisesDisabled;

@property (nonatomic, copy) NSArray *dependentTutorialIdentifiers;
@property (nonatomic, copy) void(^completionHandler)(void);

@end



/**
 @abstract  <#abstract comment#>
 */
@interface FLWTutorialController : NSObject

/**
 Schedules a new tutorial if that tutorial is not already completed.

 @param delay Is only counted down when predicate evaluates to true
 */
- (void)scheduleTutorialWithIdentifier:(NSString *)identifier afterDelay:(NSTimeInterval)delay withPredicate:(FLWBlockPredicate)predicate constructionBlock:(void(^)(id<FLWTutorial> tutorial))constructionBlock;

/**
 Invalides a scheduled tutorial without changing its completion state.
 */
- (void)invalidateTutorialWithIdentifier:(NSString *)identifier;

/**
 Changes progress in a scheduled tutorial.
 */
- (void)setProgress:(CGFloat)progress inTutorialWithIdentifier:(NSString *)identifier;

/**
 Marks a tutorial as completed and finishes a running tutorial.
 */
- (void)completeTutorialWithIdentifier:(NSString *)identifier;

/**
 Resets a tutorial.
 */
- (void)resetTutorialWithIdentifier:(NSString *)identifier;

/**
 Informs the user that he has made an error while executing the tutorial.
 */
- (void)speakErrorMessage:(NSString *)errorMessage inTutorialWithIdentifier:(NSString *)identifier;

/**
 Returns YES if the tutorial with `identifier` is currently running.
 */
- (BOOL)isRunningTutorialWithIdentifier:(NSString *)identifier;

@end



/**
 @abstract  Singleton category
 */
@interface FLWTutorialController (Singleton)

+ (FLWTutorialController *)sharedInstance;

@end
