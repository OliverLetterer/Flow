//
//  FLWTutorialTouchGesture.h
//  cashier
//
//  Created by Oliver Letterer on 24.04.14.
//  Copyright 2014 Sparrowlabs. All rights reserved.
//

@protocol FLWTutorialTouchGesture <NSObject>

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, readonly) CGFloat progress;
- (void)setProgress:(CGFloat)progress onView:(UIView *)view;

@optional
- (Class)gestureViewClass;

@end
