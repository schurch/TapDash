//
//  CountDownLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 04/11/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

const static int INITIAL_COUNTDOWN_VALUE = 3;

@interface CountdownLayer : CCLayer {
    CCLabelTTF *_countDownLabel;
    int _countdownValue;
    id _delegate;
}

@property (assign, nonatomic) id delegate;

+(CCScene *) scene;

@end


@protocol CountdownDelegate <NSObject>
- (void)startGame;
@end
