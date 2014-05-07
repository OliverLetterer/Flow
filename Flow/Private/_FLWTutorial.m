//
//  _FLWTutorial.m
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

#import "_FLWTutorial.h"
#import <AVFoundation/AVFoundation.h>



@interface _FLWTutorial () <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) dispatch_block_t speechCompletionBlock;

@property (nonatomic, assign) BOOL isSpeeking;

@end



@implementation _FLWTutorial
@synthesize title = _title, gesture = _gesture, dependentTutorialIdentifiers = _dependentTutorialIdentifiers, speechSynthesisesDisabled = _speechSynthesisesDisabled, successMessage = _successMessage, completionHandler = _completionHandler, repeatMessage = _repeatMessage, repeatInterval = _repeatInterval, respectsSilentSwitch = _respectsSilentSwitch, identifier = _identifier;

#pragma mark - setters and getters

- (void)setRepeatInterval:(NSTimeInterval)repeatInterval
{
    NSParameterAssert(repeatInterval >= 0.0);

    if (repeatInterval != _repeatInterval) {
        _repeatInterval = repeatInterval;
        self.remainingTimeToRepeatMessage = _repeatInterval;
    }
}

- (void)setRepeatMessage:(NSString *)repeatMessage
{
    if (repeatMessage != _repeatMessage) {
        _repeatMessage = [repeatMessage copy];

        if (self.repeatInterval == 0.0) {
            self.repeatInterval = 20.0;
        }
    }
}

- (void)setDependentTutorialIdentifiers:(NSArray *)dependentTutorialIdentifiers
{
    NSAssert(![dependentTutorialIdentifiers containsObject:self.identifier], @"dependentTutorialIdentifiers (%@) are unsatisfiable because the contain the tutorials identifier (%@)", dependentTutorialIdentifiers, self.identifier);

    if (dependentTutorialIdentifiers != _dependentTutorialIdentifiers) {
        _dependentTutorialIdentifiers = [dependentTutorialIdentifiers copy];
    }
}

- (BOOL)canStartTutorial
{
    if (self.state != FLWTutorialStateScheduled) {
        return NO;
    }

    if (self.predicate && !self.predicate()) {
        return NO;
    }

    return self.remainingDuration <= 0.0;
}

#pragma mark - Initialization

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
        _identifier = [identifier copy];
    }
    return self;
}

#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    self.isSpeeking = NO;
    self.speechSynthesizer = nil;

    if (self.speechCompletionBlock) {
        self.speechCompletionBlock();
        self.speechCompletionBlock = nil;
    }
}

#pragma mark - Instance methods

- (void)cancelSpeeking
{
    self.speechSynthesizer.delegate = nil;
    [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    self.speechSynthesizer = nil;

    if (self.speechCompletionBlock) {
        self.speechCompletionBlock();
        self.speechCompletionBlock = nil;
    }

    self.isSpeeking = NO;
}

- (void)speakText:(NSString *)text
{
    if (self.speechSynthesisesDisabled || text.length == 0) {
        return;
    }
    
    if (self.speechSynthesizer) {
        [self cancelSpeeking];
    }

    AVSpeechUtterance *speechUtterance = [AVSpeechUtterance speechUtteranceWithString:text];
    speechUtterance.rate = (AVSpeechUtteranceDefaultSpeechRate + AVSpeechUtteranceMinimumSpeechRate) / 2.0;

    self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    self.speechSynthesizer.delegate = self;
    [self.speechSynthesizer speakUtterance:speechUtterance];

    self.isSpeeking = YES;
}

- (void)executeBlockAfterCurrentSpeechFinished:(dispatch_block_t)block
{
    self.speechCompletionBlock = block;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", super.description, self.identifier];
}

@end
