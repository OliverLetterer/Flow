//
//  FLWTapGesture.m
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

#import "FLWTapGesture.h"
#import "_FLWTutorialTouchIndicatorView.h"

typedef struct {
    CGFloat startFrame;
    CGFloat duration;
} _SPLInterval;

static inline BOOL _SPLIntervalContainsFrame(_SPLInterval interval, CGFloat frame)
{
    return interval.startFrame <= frame && frame <= (interval.startFrame + interval.duration);
}

@interface FLWTapGesture ()

@property (nonatomic, strong) _FLWTutorialTouchIndicatorView *touchIndicatorView;

@end



@implementation FLWTapGesture
@synthesize duration = _duration, progress = _progress, containerView = _containerView, tintColor = _tintColor;

#pragma mark - setters and getters

- (NSArray *)touchIndicatorViews
{
    return @[ self.touchIndicatorView ];
}

- (_FLWTutorialTouchIndicatorView *)touchIndicatorView
{
    if (!_touchIndicatorView) {
        _touchIndicatorView = [[_FLWTutorialTouchIndicatorView alloc] initWithFrame:CGRectZero];
        _touchIndicatorView.tintColor = self.tintColor;
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

    self.touchIndicatorView.center = [self.view convertPoint:self.touchPoint toView:self.touchIndicatorView.superview];

    _SPLInterval fadeInInterval  = { 0.0, 0.1 };
    _SPLInterval showInterval    = { fadeInInterval.startFrame + fadeInInterval.duration, 0.3 };
    _SPLInterval fadeOutInterval = { showInterval.startFrame + showInterval.duration, 0.1 };
    _SPLInterval hiddenInterval  = { fadeOutInterval.startFrame + fadeOutInterval.duration, 1.0 - (fadeOutInterval.startFrame + fadeOutInterval.duration) };

    if (_SPLIntervalContainsFrame(hiddenInterval, _progress)) {
        self.touchIndicatorView.alpha = 0.0;
    } else if (_SPLIntervalContainsFrame(fadeInInterval, _progress)) {
        self.touchIndicatorView.alpha = 1.0 * (progress - fadeInInterval.startFrame) / fadeInInterval.duration;
    } else if (_SPLIntervalContainsFrame(showInterval, _progress)) {
        self.touchIndicatorView.alpha = 1.0;
    } else if (_SPLIntervalContainsFrame(fadeOutInterval, _progress)) {
        self.touchIndicatorView.alpha = 1.0 - 1.0 * (progress - fadeOutInterval.startFrame) / fadeInInterval.duration;
    }

    if (_progress == 0.0) {
        self.touchIndicatorView.alpha = 0.0;
    }
}

#pragma mark - Initialization

- (instancetype)initWithTouchPoint:(CGPoint)touchPoint inView:(UIView *)view
{
    if (self = [super init]) {
        _touchPoint = touchPoint;
        _view = view;

        _duration = 2.0;
    }
    return self;
}

- (void)dealloc
{
    [self.touchIndicatorView removeFromSuperview];
}

@end
