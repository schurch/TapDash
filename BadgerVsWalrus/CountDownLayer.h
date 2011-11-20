//
//  CountDownLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 04/11/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CountdownLayer : CCLayer {
    CCSprite *_countDownImage;
    int _countdownValue;
    id _delegate;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) CCSprite *countDownImage;

+(CCScene *) scene;

@end


@protocol CountdownDelegate <NSObject>
- (void)startGame;
@end
