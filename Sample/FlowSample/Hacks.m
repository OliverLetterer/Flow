//
//  FLWTutorialController+iCuisineDebug.m
//  cashier
//
//  Created by Oliver Letterer on 24.04.14.
//  Copyright (c) 2014 Sparrowlabs. All rights reserved.
//

#import "Flow.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

static void class_swizzleSelector(Class class, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    if(class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}



@implementation AVSpeechSynthesizer (Hacks)

+ (void)load
{
    class_swizzleSelector([AVSpeechSynthesizer class], @selector(speakUtterance:), @selector(__hacksSpeakUtterance:));
}

- (void)__hacksSpeakUtterance:(AVSpeechUtterance *)utterance
{
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    [self __hacksSpeakUtterance:utterance];
}

@end
