//
//  FLWSwipeGesture.m
//  Guia
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

#import "FLWSwipeGesture.h"

typedef struct {
    CGFloat startFrame;
    CGFloat duration;
} _SPLInterval;

static inline BOOL _SPLIntervalContainsFrame(_SPLInterval interval, CGFloat frame)
{
    return interval.startFrame <= frame && frame <= (interval.startFrame + interval.duration);
}

static CGPoint interpolatedPointBetweenPoints(CGPoint startPoint, CGPoint endPoint, CGFloat progress)
{
    CGPoint direction = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    return CGPointMake(startPoint.x + progress * direction.x, startPoint.y + progress * direction.y);
}



@implementation FLWSwipeGesture
@synthesize duration = _duration, progress = _progress;

#pragma mark - setters and getters

- (void)setSpeed:(CGFloat)speed
{
    if (speed != _speed) {
        _speed = speed;

        CGFloat distance = sqrt(pow(self.endPoint.x - self.startPoint.x, 2.0) + pow(self.endPoint.y - self.startPoint.y, 2.0));
        self.duration = distance / _speed * 2.0;
    }
}

#pragma mark - Initialization

- (instancetype)initWithSwipeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint inView:(UIView *)view
{
    if (self = [super init]) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _view = view;

        self.speed = 200.0;
    }
    return self;
}

#pragma mark - FLWTouchGesture

- (void)setProgress:(CGFloat)progress onView:(UIView *)view
{
    _progress = progress;

    _SPLInterval fadeInInterval  = { 0.0, 0.1 };
    _SPLInterval swipeInterval   = { fadeInInterval.startFrame + fadeInInterval.duration, 0.5 };
    _SPLInterval hiddenInterval  = { swipeInterval.startFrame + swipeInterval.duration, 1.0 - (swipeInterval.startFrame + swipeInterval.duration) };

    if (_SPLIntervalContainsFrame(hiddenInterval, _progress)) {
        view.alpha = 0.0;
        view.center = [self.view convertPoint:self.endPoint toView:view.superview];
    } else if (_SPLIntervalContainsFrame(fadeInInterval, _progress)) {
        view.alpha = 1.0 * (progress - fadeInInterval.startFrame) / fadeInInterval.duration;
        view.center = [self.view convertPoint:self.startPoint toView:view.superview];
    } else if (_SPLIntervalContainsFrame(swipeInterval, _progress)) {
        CGFloat thisIntervalsProgress = (progress - swipeInterval.startFrame) / swipeInterval.duration;
        CGPoint currentPoint = interpolatedPointBetweenPoints(self.startPoint, self.endPoint, thisIntervalsProgress);

        view.alpha = 1.0 - 1.0 * thisIntervalsProgress;
        view.center = [self.view convertPoint:currentPoint toView:view.superview];
    }
}

@end
