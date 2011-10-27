//
//  HelloWorldLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

#define GAME_OVER_LAYER 999
#define INITIAL_TIME_LABEL "0:00"

float _player1StartY = 210;
float _player2StartY = 130;
float _startX = 66;
float _endX = 359;
float _currentTime;
bool _boostUsed;

@implementation GameLayer

+(CCScene *) scene
{
	static CCScene *scene;
    
    if(!scene){
        scene = [CCScene node];
        GameLayer *layer = [GameLayer node];
        [scene addChild: layer];
    }
    
	return scene;
}

- (void)setStart {
    _gameState = kBWGameStateStart;
    _currentTime = 0;
    _timeLabel.string = @INITIAL_TIME_LABEL;
    _player1.position = ccp( _startX, _player1StartY );
    _player2.position = ccp( _startX, _player2StartY );
    _boostUsed = false;
}

- (void)pause {
    [self pauseSchedulerAndActions];
    _gameState = kBWGameStatePaused;
}

- (void)play {
    [self resumeSchedulerAndActions];
    _gameState = kBWGameStateRunning;
}

-(id) init
{
	if( (self=[super init])) {         
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _backdrop = [CCSprite spriteWithFile:@"game_backdrop.png"];
        _backdrop.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_backdrop];
        
        _tapButton = [CCSprite spriteWithFile: @"tap_button.png"];
        _tapButton.position = ccp( 440, 40 );  
        [self addChild:_tapButton];
        
//        _boostButton = [CCSprite spriteWithFile: @"boost_button.png"];
//        _boostButton.position = ccp( 40, 40 );  
//        [self addChild:_boostButton];
        
        _player1 = [CCSprite spriteWithFile: @"cow.png"];
        _player1.position = ccp( _startX, _player1StartY );
        [self addChild:_player1];
        
        _player2 = [CCSprite spriteWithFile: @"penguin.png"];
        _player2.position = ccp( _startX, _player2StartY );
        [self addChild:_player2];
        
        _timeLabel = [CCLabelTTF labelWithString:@INITIAL_TIME_LABEL fontName:@"Marker Felt" fontSize:35];
        _timeLabel.position = ccp(278,40);
        [self addChild: _timeLabel];
        
        _boostUsed = false;
        
        [self scheduleUpdate];
        [self schedule:@selector(timerUpdate:) interval:0.01];
        [self setStart];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

- (void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)timerUpdate:(ccTime)dt {
    if(_gameState == kBWGameStatePaused || _gameState == kBWGameStateStart){
        return;
    }
    
    _currentTime += dt;
    _timeLabel.string = [NSString stringWithFormat:@"%.2f", _currentTime];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(_gameState == kBWGameStatePaused) {
        return NO;
    }
    
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    if (CGRectContainsPoint(_tapButton.boundingBox, location)) {        
        if(_gameState == kBWGameStateStart) {
            [self play];
        }
        
        id actionTo = [CCMoveTo actionWithDuration:0.1 position:ccp(_player1.position.x + 5, _player1.position.y)];
        [_player1 runAction:actionTo];
    }
    
    if (CGRectContainsPoint(_boostButton.boundingBox, location)) {                
        if(!_boostUsed) {
            id actionTo = [CCMoveTo actionWithDuration:0.1 position:ccp(_player1.position.x + 30, _player1.position.y)];
            [_player1 runAction:actionTo];
            _boostUsed = true;
        }
    }
    
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    if (CGRectContainsPoint(_tapButton.boundingBox, location)) {

    }
}

- (void)gameOverWithOutcome:(GameOutcome)outcome {
    [self pause];
    
    if (!gameOverLayer) {
        gameOverLayer = [GameOverLayer node];
        [self addChild:gameOverLayer z:999999 tag:GAME_OVER_LAYER];
        gameOverLayer.delegate = self;
    }
    
    [gameOverLayer setupLayerWithGameOutcome:outcome];
    [[self getChildByTag:GAME_OVER_LAYER] setVisible:YES];
}

- (void) update:(ccTime)dt {
    if(_gameState == kBWGameStatePaused || _gameState == kBWGameStateStart){
        return;
    }
    
    _player2.position = ccp( _player2.position.x + 30 * dt, _player2.position.y );

    if(_player1.position.x >= _endX && _player2.position.x >= _endX){
        [self gameOverWithOutcome:kBWGameOutcomeDraw];
    }else if(_player1.position.x >= _endX){
        [self gameOverWithOutcome:kBWGameOutcomePlayer1Won];
    }else if(_player2.position.x >= _endX){
        [self gameOverWithOutcome:KBWGameOutcomePlayer2won];
    }
}

- (void)playAgain {
    [[self getChildByTag:GAME_OVER_LAYER] setVisible:NO];
    [self setStart];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}
@end
