//
//  _FLWTutorialOverlayView.m
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

#import "_FLWTutorialOverlayView.h"

@interface _FLWTutorialOverlayViewProgressControl : UIControl

@property (nonatomic, assign) CGFloat progress;

@end

@implementation _FLWTutorialOverlayViewProgressControl

- (void)setProgress:(CGFloat)progress
{
    if (progress != _progress) {
        _progress = progress;

        [self setNeedsDisplay];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.needsDisplayOnBoundsChange = YES;
        self.tintColor = [UIColor whiteColor];
    }
    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return self.progress > 0.0 ? NO : [super beginTrackingWithTouch:touch withEvent:event];
}

- (void)drawRect:(CGRect)rect
{
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));

    [[UIColor whiteColor] setFill];

    if (self.progress <= 0.0) {
        UIImage *image = [[UIImage imageNamed:@"FLWProgressViewClose"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [image drawInRect:CGRectMake(centerPoint.x - image.size.width / 2.0,
                                     centerPoint.y - image.size.height / 2.0,
                                     image.size.width, image.size.height)];
    } else if (self.progress >= 1.0) {
        UIImage *image = [[UIImage imageNamed:@"FLWProgressCheckmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [image drawInRect:CGRectMake(centerPoint.x - image.size.width / 2.0,
                                     centerPoint.y - image.size.height / 2.0,
                                     image.size.width, image.size.height)];
    }

    CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2.0 - 7.0;
    CGFloat passedAngle = self.progress * 2.0 * M_PI;
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                                radius:radius
                                                            startAngle:- M_PI_2
                                                              endAngle:- M_PI_2 + passedAngle
                                                             clockwise:YES];

    [[UIColor whiteColor] setStroke];
    [progressPath stroke];
}

@end



@interface _FLWTutorialOverlayView ()

@property (nonatomic, strong) _FLWTutorialOverlayViewProgressControl *progressView;

@end



@implementation _FLWTutorialOverlayView

#pragma mark - setters and getters

- (void)setProgress:(CGFloat)progress
{
    progress = MAX(MIN(progress, 1.0), 0.0);

    if (progress != _progress) {
        _progress = progress;

        self.progressView.progress = _progress;
    }
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:53.0 / 255.0 green:142.0 / 255.0 blue:244.0 / 255.0 alpha:1.0];

        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:17.0];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.numberOfLines = 0;
        [self addSubview:_textLabel];

        _progressView = [[_FLWTutorialOverlayViewProgressControl alloc] initWithFrame:CGRectZero];
        [self addSubview:_progressView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect contentRect, dummyRect, leftRect, rightRect;
    CGRectDivide(self.bounds, &contentRect, &dummyRect, 44.0 + 20.0, CGRectMaxYEdge);
    CGRectDivide(contentRect, &rightRect, &leftRect, 44.0 + 14.0, CGRectMaxXEdge);

    self.textLabel.frame = UIEdgeInsetsInsetRect(leftRect, UIEdgeInsetsMake(10.0, 14.0, 10.0, 7.0));
    self.progressView.frame = UIEdgeInsetsInsetRect(rightRect, UIEdgeInsetsMake(10.0, 0.0, 10.0, 14.0));
}

@end
