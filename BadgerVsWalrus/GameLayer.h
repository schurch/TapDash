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
#import "NetworkManager.h"
#import "CountDownLayer.h"
#import "NetworkLayer.h"

@interface GameLayer : NetworkLayer<NetworkManagerGameDelegate, CountdownDelegate>
{
    CCSprite *_player1;
    CCSprite *_player2;
    CCSprite *_tapButton;
    GameState _gameState;
    CCLabelTTF *_timeLabel;
    Animal _choosenAnimal;
}

@property (assign, nonatomic) Animal choosenAnimal;
@property (readonly, nonatomic) CCSprite *humanPlayer;
@property (readonly, nonatomic) CCSprite *otherPlayer;

+(CCScene *) sceneWithChosenAnimal:(Animal)animal;
+(CCScene *) sceneWithChosenAnimal:(Animal)animal isNetworkGame:(BOOL)isNetworkGame;

@end
