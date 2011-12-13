//
//  TapInterpreter.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 17/11/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import "TapInterpreter.h"

@implementation TapInterpreter

@synthesize delegate = _delegate;

- (id)init {
    if (self = [super init]) {
        _inTapThreshold = NO;
        _consecutiveTaps = 0;
    }
    
    return self;
}

- (void)startTapThresholdForTapType:(TapType)tapType {
    NSLog(@"Start threshold for tap type %@.", tapType == kShortTap ? @"ShortTap" : @"LongTap");
    _tapType = tapType;
    _inTapThreshold = YES;
}

- (void)stopTapThreshold {
    NSLog(@"End threshold.");
    _inTapThreshold = NO;
}

- (void)registerTapWithLength:(float)tapLengthTime {
    TapType tapLength = tapLength > 0.2 ? kLongTap : kShortTap;
    
    BOOL tapSuccess;
    if (tapLength == kLongTap && _inTapThreshold && _tapType == kLongTap) {
        tapSuccess = YES;
        NSLog(@"Long tap success.");
    } else if (tapLength == kShortTap && _inTapThreshold && _tapType == kShortTap) {
        tapSuccess = YES;
        NSLog(@"Short tap success.");
    } else {
        tapSuccess = NO;
        NSLog(@"Tap fail.");
    }
    
    _consecutiveTaps = tapSuccess ? _consecutiveTaps++ : 0;
    
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
            bonus = kTapBonusLudacris;
            break;
        case 7:
            bonus = kTapBonusMonster;
            break;
        default:
            NSLog(@"Unrecognized tap bonus.");
            break;
    }
    
    [self.delegate tapWasSuccess:tapSuccess withBonus:bonus];
}

@end
