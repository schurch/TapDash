//
//  TapInterpreter.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 17/11/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import "TapInterpreter.h"

typedef enum {
    kShortTap,
    kLongTap
} TapLength;

@implementation TapInterpreter

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (TapBonus)registerTapWithLength:(float)tapLengthTime {
    TapLength tapLength = tapLength > 0.2 ? kLongTap : kShortTap;
    
}

@end
