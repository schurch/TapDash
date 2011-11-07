//
//  HelloWorldLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright Stefan Church 2011. All rights reserved.
//


#import "GameLayer.h"
#import "MainMenuLayer.h"

#define INITIAL_TIME_LABEL "0:00"
#define COUNTDOWN_LAYER_TAG 1000

float _player1StartY = 210;
float _player2StartY = 130;
float _startX = 66;
float _endX = 359;
float _gameTime;

@implementation GameLayer

@synthesize choosenAnimal = _choosenAnimal;

+ (CCScene *)sceneWithChosenAnimal:(Animal)animal {
    CCScene *scene = [self sceneWithChosenAnimal:animal isNetworkGame:NO];
    return scene;
}

+ (CCScene *)sceneWithChosenAnimal:(Animal)animal isNetworkGame:(BOOL)isNetworkGame
{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    layer.choosenAnimal = animal;
    
    NSLog(@"GameLayer::Choosen animal is %@.", animal == kAnimalCow ? @"Cow" : @"Penguin");
    
    if (isNetworkGame) {
        layer.networkManager = [NetworkManager manger];
        layer.networkManager.gameDelegate = layer;
    }
    
    [scene addChild: layer];
    
    return scene;
}

- (void)setStart {
    NSLog(@"Set start positions.");
    _gameState = kGameStateStart;
    _gameTime = 0;
    _timeLabel.string = @INITIAL_TIME_LABEL;
    _player1.position = ccp( _startX, _player1StartY );
    _player2.position = ccp( _startX, _player2StartY );
}

- (void)startCountDown {
    CountdownLayer *countDownLayer = [[CountdownLayer alloc] init];
    countDownLayer.delegate = self;
    [self addChild:countDownLayer z:9999 tag:COUNTDOWN_LAYER_TAG];
    [countDownLayer release];
}

- (void)pause {
    NSLog(@"Pause Game.");
    [self pauseSchedulerAndActions];
    _gameState = kGameStatePaused;
}

- (void)play {
    NSLog(@"Play Game.");
    [self resumeSchedulerAndActions];
    _gameState = kGameStateRunning;
}

- (CCSprite *)humanPlayer {
    return _choosenAnimal == kAnimalCow ? _player1 : _player2;    
}

- (CCSprite *)otherPlayer {
    return _choosenAnimal == kAnimalCow ? _player2 : _player1;
}

- (id)init {
	if( (self=[super init])) {         
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        CCSprite *backdrop = [CCSprite spriteWithFile:@"game_backdrop.png"];
        backdrop.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:backdrop];
        
        _tapButton = [CCSprite spriteWithFile: @"tap_button.png"];
        _tapButton.position = ccp( 440, 40 );  
        [self addChild:_tapButton];
        
        _player1 = [CCSprite spriteWithFile: @"cow.png"];
        _player1.position = ccp( _startX, _player1StartY );
        [self addChild:_player1];
        
        _player2 = [CCSprite spriteWithFile: @"penguin.png"];
        _player2.position = ccp( _startX, _player2StartY );
        [self addChild:_player2];
        
        _timeLabel = [CCLabelTTF labelWithString:@INITIAL_TIME_LABEL fontName:@"Marker Felt" fontSize:35];
        _timeLabel.position = ccp(278,40);
        [self addChild: _timeLabel];
        
        [self scheduleUpdate];
        [self schedule:@selector(timerUpdate:) interval:0.01];
        [self setStart];
        [self startCountDown];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

- (void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)timerUpdate:(ccTime)dt {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart){
        return;
    }
    
    _gameTime += dt;
    _timeLabel.string = [NSString stringWithFormat:@"%.2f", _gameTime];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart) {
        return NO;
    }
    
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    if (CGRectContainsPoint(_tapButton.boundingBox, location)) {                
        id actionTo = [CCMoveTo actionWithDuration:0.1 position:ccp(self.humanPlayer.position.x + 5, self.humanPlayer.position.y)];
        [self.humanPlayer runAction:actionTo];
    }
    
    return YES;
}

- (void)gameOverWithOutcome:(GameOutcome)outcome withTime:(float)time {
    [self pause];

    BOOL didWin = NO;
    if (!self.networkManager) {
        if (outcome == kGameOutcomeCowWon && self.humanPlayer == _player1) {
            didWin = YES;
        }else if(outcome == kGameOutcomePenguinWon && self.humanPlayer == _player2) {
            didWin = YES;
        }
    }
    
    BOOL isNetworkGame = self.networkManager ? YES : NO;
    CCScene *gameOverScene = [GameOverLayer sceneWithGameOutcome:outcome didPlayerWin:didWin time:time isNetworkGame:isNetworkGame];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:gameOverScene]];
}

- (void)update:(ccTime)dt {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart){
        return;
    }
    
    if (self.networkManager) {
        static int counter = 1;
        
        if (counter % 8 == 0) { //send network heartbeat once every 8 counts
            [self.networkManager heartbeatWithXPostion:self.humanPlayer.position.x time:_gameTime];
        }
        
        if (self.humanPlayer.position.x >= _endX) {
            [self.networkManager wonWithXPosition:self.humanPlayer.position.x time:_gameTime];
        }
        
        counter++;
    } else {
        self.otherPlayer.position = ccp( self.otherPlayer.position.x + 30 * dt, self.otherPlayer.position.y );   
        
        if (_player1.position.x >= _endX && _player2.position.x >= _endX) {
            [self gameOverWithOutcome:kGameOutcomeDraw withTime:_gameTime];
        } else if(_player1.position.x >= _endX) {
            [self gameOverWithOutcome:kGameOutcomeCowWon withTime:_gameTime];
        } else if(_player2.position.x >= _endX) {
            [self gameOverWithOutcome:kGameOutcomePenguinWon withTime:_gameTime];
        }
    }
}

- (void)playAgain {
    [self setStart];
}

- (void)connectionLost {
    NSLog(@"GameLayer::Connection Lost.");
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuLayer scene]]]; 
}

- (void)heartbeatWithOtherPlayerXPosition:(int)xPostion {
    NSLog(@"Other player is at x postion '%@'. Updating position.", [NSNumber numberWithInt:xPostion] );     
    id actionTo = [CCMoveTo actionWithDuration:0.1 position:ccp(xPostion, self.otherPlayer.position.y)];
    [self.otherPlayer runAction:actionTo];
}

- (void)winningDetails:(Animal)animal time:(float)time {
    GameOutcome outcome =  _choosenAnimal == kAnimalCow ? kGameOutcomeCowWon : kGameOutcomePenguinWon;
    [self gameOverWithOutcome:outcome withTime:time];
}

- (void)startGame {
    NSLog(@"Start game.");
    [self removeChildByTag:COUNTDOWN_LAYER_TAG cleanup:YES];
    [self play];
}

- (void) dealloc {
    [_player1 release];
    [_player2 release];
    [_tapButton release];
    [_timeLabel release];
}
@end
