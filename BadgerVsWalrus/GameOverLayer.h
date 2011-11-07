//
//  BWGameOverLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 23/10/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Game.h"
#import "NetworkLayer.h"

@interface GameOverLayer : NetworkLayer<NetworkManagerGameOverDelegate> {
    CCLabelTTF *_gameOverLabel;
    GameOutcome _gameOutcome;
    float _finalTime;
    NSString *_winningSpriteFile;
    CGSize _winSize;
}

@property (assign, nonatomic) GameOutcome gameOutcome;
@property (assign, nonatomic) float finalTime;
@property (retain, nonatomic) NSString* winningSpriteFile;

+ (CCScene *)sceneWithGameOutcome:(GameOutcome)gameOutcome didPlayerWin:(BOOL)didPlayerWin time:(float)time isNetworkGame:(BOOL)isNetworkGame;
+ (CCScene *)sceneWithGameOutcome:(GameOutcome)gameOutcome didPlayerWin:(BOOL)didPlayerWin time:(float)time;

- (void)setHighScore:(float)finalTime;

@end

