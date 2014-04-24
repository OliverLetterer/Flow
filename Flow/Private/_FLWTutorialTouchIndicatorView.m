//
//  _FLWTutorialTouchIndicatorView.m
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

#import "_FLWTutorialTouchIndicatorView.h"



@interface _FLWTutorialTouchIndicatorView () {
    
}

@end



@implementation _FLWTutorialTouchIndicatorView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(88.0, 88.0);
}

- (void)drawRect:(CGRect)rect 
{
    static CGFloat shadowSize = 14.0;
    
    UIColor *fillColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    UIColor *strokeColor = [UIColor whiteColor];
    UIColor *shadowColor = [UIColor colorWithRed:53.0 / 255.0 green:142.0 / 255.0 blue:244.0 / 255.0 alpha:1.0];

    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(shadowSize, shadowSize, shadowSize, shadowSize))];

    [fillColor setFill];
    [circlePath fill];

    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextAddPath(UIGraphicsGetCurrentContext(), circlePath.CGPath);
    CGContextAddPath(UIGraphicsGetCurrentContext(), [UIBezierPath bezierPathWithRect:rect].CGPath);
    CGContextEOClip(UIGraphicsGetCurrentContext());
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeZero, shadowSize, shadowColor.CGColor);

    [circlePath fill];

    CGContextRestoreGState(UIGraphicsGetCurrentContext());

    [strokeColor setStroke];
    [circlePath stroke];
}

@end
