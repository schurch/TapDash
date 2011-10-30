//
//  HelloWorldLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


#import "GameLayer.h"

#define INITIAL_TIME_LABEL "0:00"

float _player1StartY = 210;
float _player2StartY = 130;
float _startX = 66;
float _endX = 359;
float _gameTime;

@implementation GameLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    [scene addChild: layer];
    
    return scene;
}

- (void)setStart {
    _gameState = kGameStateStart;
    _gameTime = 0;
    _timeLabel.string = @INITIAL_TIME_LABEL;
    _player1.position = ccp( _startX, _player1StartY );
    _player2.position = ccp( _startX, _player2StartY );
}

- (void)pause {
    [self pauseSchedulerAndActions];
    _gameState = kGameStatePaused;
}

- (void)play {
    [self resumeSchedulerAndActions];
    _gameState = kGameStateRunning;
}

-(id) init
{
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
    if(_gameState == kGameStatePaused) {
        return NO;
    }
    
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    if (CGRectContainsPoint(_tapButton.boundingBox, location)) {        
        if(_gameState == kGameStateStart) {
            [self play];
        }
        
        id actionTo = [CCMoveTo actionWithDuration:0.1 position:ccp(_player1.position.x + 5, _player1.position.y)];
        [_player1 runAction:actionTo];
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
    
    NSString *winningSpriteFile = nil;
    
    switch (outcome) {
        case kGameOutcomePlayer1Won:
            winningSpriteFile = @"cow.png";
            break;
        case kGameOutcomePlayer2won:
            winningSpriteFile = @"penguin.png";
        default:
            break;
    }
    
    CCScene *gameOverScene = [GameOverLayer sceneWithGameOutcome:outcome time:_gameTime winningSpriteFile:winningSpriteFile];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:gameOverScene]];
}

- (void) update:(ccTime)dt {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart){
        return;
    }
    
    _player2.position = ccp( _player2.position.x + 30 * dt, _player2.position.y );

    if(_player1.position.x >= _endX && _player2.position.x >= _endX){
        [self gameOverWithOutcome:kGameOutcomeDraw];
    }else if(_player1.position.x >= _endX){
        [self gameOverWithOutcome:kGameOutcomePlayer1Won];
    }else if(_player2.position.x >= _endX){
        [self gameOverWithOutcome:kGameOutcomePlayer2won];
    }
}

- (void)playAgain {
    
    [self setStart];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[super dealloc];
}
@end
