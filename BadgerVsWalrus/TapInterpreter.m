//
//  TapInterpreter.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 17/11/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import "TapInterpreter.h"

BOOL didTapOccur = NO;

@implementation TapInterpreter

@synthesize delegate = _delegate;

- (id)init {
    if (self = [super init]) {
        _inTapThreshold = NO;
        _consecutiveTaps = 0;
    }
    
    return self;
}

- (void)startTapThresholdForTap {
//    NSLog(@"Start threshold for tap.");
    _inTapThreshold = YES;
}

- (void)stopTapThreshold {
//    NSLog(@"End threshold.");
    _inTapThreshold = NO;
}

- (void)registerTapWithLength:(float)tapLengthTime {
    
    BOOL tapSuccess;
    if (_inTapThreshold) {
        tapSuccess = YES;
        _consecutiveTaps = _consecutiveTaps + 1;
    } else {
        tapSuccess = NO;
        _consecutiveTaps = 0;
    }
    
    TapBonus bonus = kTapBonusNone;
    switch (_consecutiveTaps) {
        case 2:
            bonus = kTapBonusDouble;
            break;
        case 3:
            bonus = kTapBounsMulti;
            break;
        case 4:
            bonus = kTapBonusMega;
            break;
        case 5:
            bonus = kTapBonusUltra;
            break;
        case 6:
            bonus = kTapBonusMonster;
            break;
        default:
//            NSLog(@"No tap bonus.");
            break;
    }
    
    [self.delegate tapWasSuccess:tapSuccess withBonus:bonus];
}

@end
