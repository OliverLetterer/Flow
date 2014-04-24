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

#warning nice fade out transition for userinteraction or dismissal
#warning adjust framerate to 10 when waiting for tutorial to kick in and 1 when tutorial finished

typedef BOOL(^SPLBlockPredicate)(void);



@protocol FLWTutorial <NSObject>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) id<FLWTouchGesture> gesture;

@property (nonatomic, copy) NSArray *dependentTutorialIdentifiers;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface FLWTutorialController : NSObject 

/**
 Schedules a new tutorial if that tutorial is not already completed.
 */
- (void)scheduleTutorialWithIdentifier:(NSString *)identifier afterDelay:(NSTimeInterval)delay withPredicate:(SPLBlockPredicate)predicate constructionBlock:(void(^)(id<FLWTutorial> tutorial))constructionBlock;

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

@end



/**
 @abstract  Singleton category
 */
@interface FLWTutorialController (Singleton)

+ (FLWTutorialController *)sharedInstance;

@end
