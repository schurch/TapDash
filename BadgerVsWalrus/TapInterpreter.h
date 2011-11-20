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
    kTapBonusUltimate
} TapBonus;

@interface TapInterpreter : NSObject

- (TapBonus)registerTapWithLength:(float)tapLengthTime;

@end
