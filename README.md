# Flow

[![Version](http://cocoapod-badges.herokuapp.com/v/Flow/badge.png)](http://cocoadocs.org/docsets/Flow)
[![Platform](http://cocoapod-badges.herokuapp.com/p/Flow/badge.png)](http://cocoadocs.org/docsets/Flow)
[![License Badge](https://go-shields.herokuapp.com/license-MIT-blue.png)](https://go-shields.herokuapp.com/license-MIT-blue.png)

Flow is a Facebook Paper inspired tutorial framework to make users familiar with gesture based user interfaces.

[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/UA2MJa2IGM8/0.jpg)](http://www.youtube.com/watch?v=UA2MJa2IGM8)


## Installation

Flow is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

``` ruby
pod "Flow"
```

## Usage

### Scheduling a new tutorial

```objc
[[FLWTutorialController sharedInstance] scheduleTutorialWithIdentifier:identifier afterDelay:0.5 withPredicate:^BOOL{
  // return NO if you are not ready to start this tutorial yet.
  return YES;
} constructionBlock:^(id<FLWTutorial> tutorial) {
  tutorial.title = ...; // assign tutorials title
  tutorial.gesture = ...; // assigne tutorials gesture
}];
```

### Gestures
Flow ships with the buildin gestures `FLWTapGesture`, `FLWSwipeGesture` and `FLWCompoundGesture` and supports all gestures conforming to the `FLWTouchGesture` protocol:

```objc
@protocol FLWTouchGesture <NSObject>

@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, readonly) CGFloat progress;
- (void)setProgress:(CGFloat)progress onView:(UIView *)view;

@end
```

### Changing progress of interactive tutorials

```objc
[[FLWTutorialController sharedInstance] setProgress:progress inTutorialWithIdentifier:identifier];
```

### Completion
Mark a tutorial as completed

```objc
[[FLWTutorialController sharedInstance] completeTutorialWithIdentifier:dummyIdentifier];
```

### Tutorial invalidation
If your app leaves the scope where the tutorial is valid:

```objc
[[FLWTutorialController sharedInstance] invalidateTutorialWithIdentifier:identifier];
```

## Author

Oliver Letterer

- http://github.com/OliverLetterer
- http://twitter.com/oletterer
- oliver.letterer@gmail.com

## License

Flow is available under the MIT license. See the LICENSE file for more info.
