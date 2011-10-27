//
//  HelloWorldLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"
#import "GameOverLayer.h"
#import "Game.h"

@interface GameLayer : CCLayer<GameOverDelegate>
{
    CCSprite *_backdrop;
    CCSprite *_player1;
    CCSprite *_player2;
    CCSprite *_tapButton;
    CCSprite *_boostButton;
    GameState _gameState;
    GameOverLayer *gameOverLayer;
    CCLabelTTF *_timeLabel;
}

+(CCScene *) scene;

@end
