//
//  FLWCompoundGesture.m
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

#import "FLWCompoundGesture.h"



@interface FLWCompoundGesture ()

@property (nonatomic, strong) NSArray *touchIndicatorViews;

@end



@implementation FLWCompoundGesture
@synthesize progress = _progress, containerView = _containerView, tintColor = _tintColor;

#pragma mark - setters and getters

- (CGFloat)duration
{
    return [[self.gestures valueForKeyPath:@"@sum.duration"] doubleValue];
}

- (void)setDuration:(CGFloat)duration
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)setContainerView:(UIView *)containerView
{
    if (containerView != _containerView) {
        _containerView = containerView;

        for (id<FLWTouchGesture> gesture in self.gestures) {
            gesture.containerView = _containerView;
        }
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;

    id<FLWTouchGesture> interpolatingGesture = self.gestures.lastObject;

    CGFloat totalDuration = self.duration;
    NSTimeInterval currentTimeOffset = 0.0;
    for (id<FLWTouchGesture> thisGesture in self.gestures) {
        CGFloat thisGesturesMaxmimumProgress = (currentTimeOffset + thisGesture.duration) / totalDuration;

        if (progress <= thisGesturesMaxmimumProgress) {
            interpolatingGesture = thisGesture;
            break;
        } else {
            currentTimeOffset = currentTimeOffset + thisGesture.duration;
        }
    }

    CGFloat gestureStartProgress = currentTimeOffset / totalDuration;
    CGFloat gestureEndProgress = (currentTimeOffset + interpolatingGesture.duration) / totalDuration;

    CGFloat gestureProgress = (progress - gestureStartProgress) / (gestureEndProgress - gestureStartProgress);
    interpolatingGesture.progress = gestureProgress;

    self.touchIndicatorViews = interpolatingGesture.touchIndicatorViews;
}

#pragma mark - Initialization

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithGestures:(NSArray *)gestures
{
    if (self = [super init]) {
        _gestures = gestures;

        for (id<FLWTouchGesture> gesture in _gestures) {
            gesture.progress = 0.0;
        }
    }
    return self;
}

@end
