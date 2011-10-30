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

@interface GameLayer : CCLayer
{
    CCSprite *_cow;
    CCSprite *_penguin;
    CCSprite *_tapButton;
    GameState _gameState;
    CCLabelTTF *_timeLabel;
    Animal _choosenAnimal;
}

@property (assign, nonatomic) Animal choosenAnimal;
@property (readonly) CCSprite *humanPlayer;
@property (readonly) CCSprite *computerPlayer;

+(CCScene *) sceneWithChosenAnimal:(Animal)animal;

@end
