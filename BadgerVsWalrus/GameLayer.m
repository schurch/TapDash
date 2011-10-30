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

@synthesize choosenAnimal = _choosenAnimal;

+ (CCScene *)sceneWithChosenAnimal:(Animal)animal
{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    layer.choosenAnimal = animal;
    [scene addChild: layer];
    
    return scene;
}

- (void)setStart {
    _gameState = kGameStateStart;
    _gameTime = 0;
    _timeLabel.string = @INITIAL_TIME_LABEL;
    _cow.position = ccp( _startX, _player1StartY );
    _penguin.position = ccp( _startX, _player2StartY );
}

- (void)pause {
    [self pauseSchedulerAndActions];
    _gameState = kGameStatePaused;
}

- (void)play {
    [self resumeSchedulerAndActions];
    _gameState = kGameStateRunning;
}

- (CCSprite *)humanPlayer {
    return _choosenAnimal == kCow ? _cow : _penguin;    
}

- (CCSprite *)computerPlayer {
    return _choosenAnimal == kCow ? _penguin : _cow;
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
        
        _cow = [CCSprite spriteWithFile: @"cow.png"];
        _cow.position = ccp( _startX, _player1StartY );
        [self addChild:_cow];
        
        _penguin = [CCSprite spriteWithFile: @"penguin.png"];
        _penguin.position = ccp( _startX, _player2StartY );
        [self addChild:_penguin];
        
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
        
        id actionTo = [CCMoveTo actionWithDuration:0.1 position:ccp(self.humanPlayer.position.x + 5, self.humanPlayer.position.y)];
        [self.humanPlayer runAction:actionTo];
    }
    
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
}

- (void)gameOverWithOutcome:(GameOutcome)outcome {
    [self pause];
    
    BOOL didWin = NO;
    if (outcome == kGameOutcomeCowWon && self.humanPlayer == _cow) {
        didWin = YES;
    }else if(outcome == kGameOutcomePenguinWon && self.humanPlayer == _penguin) {
        didWin = YES;
    }
    
    CCScene *gameOverScene = [GameOverLayer sceneWithGameOutcome:outcome didPlayerWin:didWin time:_gameTime];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:gameOverScene]];
}

- (void) update:(ccTime)dt {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart){
        return;
    }
    
    self.computerPlayer.position = ccp( self.computerPlayer.position.x + 30 * dt, self.computerPlayer.position.y );

    if(_cow.position.x >= _endX && _penguin.position.x >= _endX){
        [self gameOverWithOutcome:kGameOutcomeDraw];
    }else if(_cow.position.x >= _endX){
        [self gameOverWithOutcome:kGameOutcomeCowWon];
    }else if(_penguin.position.x >= _endX){
        [self gameOverWithOutcome:kGameOutcomePenguinWon];
    }
}

- (void)playAgain {
    [self setStart];
}

- (void) dealloc
{
    [_cow release];
    [_penguin release];
    [_tapButton release];
    [_timeLabel release];
}
@end
