//
//  FLWSwipeGesture.m
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

#import "FLWSwipeGesture.h"
#import "_FLWTutorialTouchIndicatorView.h"

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

@interface FLWSwipeGesture ()

@property (nonatomic, strong) _FLWTutorialTouchIndicatorView *touchIndicatorView;

@end



@implementation FLWSwipeGesture
@synthesize duration = _duration, progress = _progress, containerView = _containerView;

#pragma mark - setters and getters

- (NSArray *)touchIndicatorViews
{
    return @[ self.touchIndicatorView ];
}

- (void)setSpeed:(CGFloat)speed
{
    if (speed != _speed) {
        _speed = speed;

        CGFloat distance = sqrt(pow(self.endPoint.x - self.startPoint.x, 2.0) + pow(self.endPoint.y - self.startPoint.y, 2.0));
        self.duration = distance / _speed * 2.0;
    }
}

- (_FLWTutorialTouchIndicatorView *)touchIndicatorView
{
    if (!_touchIndicatorView) {
        _touchIndicatorView = [[_FLWTutorialTouchIndicatorView alloc] initWithFrame:CGRectZero];
        [_touchIndicatorView sizeToFit];
    }

    return _touchIndicatorView;
}

- (void)setContainerView:(UIView *)containerView
{
    if (containerView != _containerView) {
        _containerView = containerView;

        [self.touchIndicatorView removeFromSuperview];
        [_containerView addSubview:self.touchIndicatorView];
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;

    _SPLInterval fadeInInterval  = { 0.0, 0.1 };
    _SPLInterval swipeInterval   = { fadeInInterval.startFrame + fadeInInterval.duration, 0.5 };
    _SPLInterval hiddenInterval  = { swipeInterval.startFrame + swipeInterval.duration, 1.0 - (swipeInterval.startFrame + swipeInterval.duration) };

    if (_SPLIntervalContainsFrame(hiddenInterval, _progress)) {
        self.touchIndicatorView.alpha = 0.0;
        self.touchIndicatorView.center = [self.view convertPoint:self.endPoint toView:self.touchIndicatorView.superview];
    } else if (_SPLIntervalContainsFrame(fadeInInterval, _progress)) {
        self.touchIndicatorView.alpha = 1.0 * (progress - fadeInInterval.startFrame) / fadeInInterval.duration;
        self.touchIndicatorView.center = [self.view convertPoint:self.startPoint toView:self.touchIndicatorView.superview];
    } else if (_SPLIntervalContainsFrame(swipeInterval, _progress)) {
        CGFloat thisIntervalsProgress = (progress - swipeInterval.startFrame) / swipeInterval.duration;
        CGPoint currentPoint = interpolatedPointBetweenPoints(self.startPoint, self.endPoint, thisIntervalsProgress);

        self.touchIndicatorView.alpha = 1.0 - 1.0 * thisIntervalsProgress;
        self.touchIndicatorView.center = [self.view convertPoint:currentPoint toView:self.touchIndicatorView.superview];
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

- (void)dealloc
{
    [self.touchIndicatorView removeFromSuperview];
}

@end
