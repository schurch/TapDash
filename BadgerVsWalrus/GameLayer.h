//
//  HelloWorldLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright Stefan Church 2011. All rights reserved.
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
    CCLabelTTF *_timeLabel;
    GameState _gameState;
    Animal _choosenAnimal;
    float _gameTime;
}

@property (nonatomic, retain) CCSprite *player1;
@property (nonatomic, retain) CCSprite *player2;
@property (nonatomic, retain) CCSprite *tapButton;
@property (nonatomic, retain) CCLabelTTF *timeLabel;
@property (nonatomic, assign) Animal choosenAnimal;
@property (nonatomic, readonly) CCSprite *humanPlayer;
@property (nonatomic, readonly) CCSprite *otherPlayer;

+(CCScene *) sceneWithChosenAnimal:(Animal)animal;
+(CCScene *) sceneWithChosenAnimal:(Animal)animal isNetworkGame:(BOOL)isNetworkGame;

@end
