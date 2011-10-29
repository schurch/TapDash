//
//  BWGameOverLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 23/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Game.h"

@interface GameOverLayer : CCLayer {
    CCLabelTTF *_gameOverLabel;
    GameOutcome _gameOutcome;
    float _finalTime;
    NSString *_winningSpriteFile;
}

@property (assign, nonatomic) GameOutcome gameOutcome;
@property (assign, nonatomic) float finalTime;
@property (retain, nonatomic) NSString* winningSpriteFile;

+ (CCScene *)sceneWithGameOutcome:(GameOutcome)gameOutcome time:(float)time 
                    winningSpriteFile:(NSString *)winningSpriteFile;

- (void)setHighScore:(float)finalTime;

@end

