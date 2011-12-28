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

@protocol TapInterpreterDelegte <NSObject>
- (void)tapWasSuccess:(BOOL)wasSuccess withBonus:(TapBonus)bonus;
@end

@interface TapInterpreter : NSObject {
    id _delegate;
    BOOL _inTapThreshold;
    int _consecutiveTaps;
}

@property (nonatomic, assign) id<TapInterpreterDelegte> delegate;

- (void)startTapThresholdForTap;
- (void)stopTapThreshold;
- (void)registerTapWithLength:(float)tapLengthTime;

@end
