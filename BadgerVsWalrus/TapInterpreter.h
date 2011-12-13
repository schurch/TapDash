//
//  TapInterpreter.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 17/11/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kTapBonusNone,
    kTapBonusDouble,
    kTapBounsMulti,
    kTapBonusMega,
    kTapBonusUltra,
    kTapBonusLudacris,
    kTapBonusMonster
} TapBonus;

typedef enum {
    kShortTap,
    kLongTap
} TapType;

@protocol TapInterpreterDelegte <NSObject>
- (void)tapWasSuccess:(BOOL)wasSuccess withBonus:(TapBonus)bonus;
@end

@interface TapInterpreter : NSObject {
    id _delegate;
    BOOL _inTapThreshold;
    TapType _tapType;
    int _consecutiveTaps;
}

@property (nonatomic, assign) id<TapInterpreterDelegte> delegate;

- (void)startTapThresholdForTapType:(TapType)tapType;
- (void)stopTapThreshold;
- (void)registerTapWithLength:(float)tapLengthTime;

@end
