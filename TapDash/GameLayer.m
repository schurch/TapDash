//
//  HelloWorldLayer.m
//  TapDash
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright Stefan Church 2011. All rights reserved.
//


#import "GameLayer.h"
#import "MainMenuLayer.h"

#define INITIAL_TIME_LABEL "0:00"
#define COUNTDOWN_LAYER_TAG 1000

static const float _player1StartY = 210;
static const float _player2StartY = 135;
static const float _startX = 66;
static const float _endX = 359;

@implementation GameLayer

@synthesize player1 = _player1;
@synthesize player2 = _player2;
@synthesize player1Selected = _player1Selected;
@synthesize player2Selected = _player2Selected;
@synthesize beatIndicator = _beatIndicator;
@synthesize tapButton = _tapButton;
@synthesize timeLabel = _timeLabel;
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

- (void)setChoosenAnimal:(Animal)choosenAnimal {
    _choosenAnimal = choosenAnimal;
    
    if (_choosenAnimal == kAnimalCow) {
        self.player1Selected.visible = YES;
        self.player2Selected.visible = NO;
    } else {
        self.player2Selected.visible = YES;
        self.player1Selected.visible = NO;
    }
}

- (void)setStart {
    NSLog(@"Set start positions.");
    _gameState = kGameStateStart;
    _gameTime = 0;
    self.timeLabel.string = @INITIAL_TIME_LABEL;
    self.player1.position = ccp( _startX, _player1StartY );
    self.player2.position = ccp( _startX, _player2StartY );
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
        
        [[CCTextureCache sharedTextureCache] addImage:@"tap_button.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"tap_button_pressed.png"];
        
        self.tapButton = [CCSprite spriteWithTexture:[[CCTextureCache sharedTextureCache] textureForKey:@"tap_button.png"]];
        self.tapButton.position = ccp(430, 48);  
        [self addChild:self.tapButton];
        
        self.player1 = [CCSprite spriteWithFile: @"cow.png"];
        self.player1.position = ccp(_startX, _player1StartY);
        [self addChild:self.player1];
        
        self.player2 = [CCSprite spriteWithFile: @"penguin.png"];
        self.player2.position = ccp(_startX, _player2StartY);
        [self addChild:self.player2];
        
        CGPoint selectedPlayerLocation = ccp(57, 46);
        
        self.player1Selected = [CCSprite spriteWithFile: @"cow_glow.png"];
        self.player1Selected.position = selectedPlayerLocation;
        self.player1Selected.visible = NO;
        [self addChild:self.player1Selected];
        
        self.player2Selected = [CCSprite spriteWithFile: @"penguin_glow.png"];
        self.player2Selected.position = selectedPlayerLocation;
        self.player2Selected.visible = NO;
        [self addChild:self.player2Selected];
        
        self.timeLabel = [CCLabelTTF labelWithString:@"Time:" fontName:@"Marker Felt" fontSize:40];
        self.timeLabel.position = ccp(winSize.width/2 - 43, 27);
        [self addChild: self.timeLabel];
        
        self.timeLabel = [CCLabelTTF labelWithString:@INITIAL_TIME_LABEL fontName:@"Marker Felt" fontSize:40];
        self.timeLabel.position = ccp(winSize.width/2 + 60, 27);
        [self addChild: self.timeLabel];
        
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
    self.timeLabel.string = [NSString stringWithFormat:@"%.2f", _gameTime];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart) {
        return NO;
    }
    
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    if (CGRectContainsPoint(self.tapButton.boundingBox, location)) {     
        //Change button texture
        self.tapButton.texture = [[CCTextureCache sharedTextureCache] textureForKey:@"tap_button_pressed.png"];
        _tapStartTime = [NSDate timeIntervalSinceReferenceDate];
        id actionTo = [CCMoveTo actionWithDuration:0.1 position:ccp(self.humanPlayer.position.x + 5, self.humanPlayer.position.y)];
        [self.humanPlayer runAction:actionTo];
    }
    
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart) {
        return;
    }
    
    CGPoint location = [self convertTouchToNodeSpace: touch];
    if (CGRectContainsPoint(self.tapButton.boundingBox, location)) {
        self.tapButton.texture = [[CCTextureCache sharedTextureCache] textureForKey:@"tap_button.png"];
    }
}

- (void)gameOverWithOutcome:(GameOutcome)outcome withTime:(float)time {
    [self pause];
     
    BOOL didWin = NO;
    if (outcome == kGameOutcomeCowWon && self.humanPlayer == _player1) {
        didWin = YES;
    } else if (outcome == kGameOutcomePenguinWon && self.humanPlayer == _player2) {
        didWin = YES;
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
        static int counter = 0;
        counter++;
        if (!(counter&7)) {
            [self.networkManager heartbeatWithXPostion:self.humanPlayer.position.x time:_gameTime];
        }
        
        if (self.humanPlayer.position.x >= _endX) {
            [self.networkManager wonWithXPosition:self.humanPlayer.position.x time:_gameTime];
            [self pause];
        }
    } else {
        self.otherPlayer.position = ccp(self.otherPlayer.position.x + 30 * dt, self.otherPlayer.position.y);   
        
        if(self.player1.position.x >= _endX) {
            [self gameOverWithOutcome:kGameOutcomeCowWon withTime:_gameTime];
            [self pause];
        } else if(self.player2.position.x >= _endX) {
            [self gameOverWithOutcome:kGameOutcomePenguinWon withTime:_gameTime];
            [self pause];
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
    GameOutcome outcome =  animal == kAnimalCow ? kGameOutcomeCowWon : kGameOutcomePenguinWon;
    NSLog(@"Winning details.");
    [self gameOverWithOutcome:outcome withTime:time];
}

- (void)startGame {
    NSLog(@"Start game.");
    [self removeChildByTag:COUNTDOWN_LAYER_TAG cleanup:YES];
    [self play];
}

- (void) dealloc {
    if (self.networkManager) {
        self.networkManager.gameDelegate = nil;
    }
    
    [_player1 release];
    [_player2 release];
    [_player1Selected release];
    [_player2Selected release];
    [_beatIndicator release];
    [_tapButton release];
    [_timeLabel release];
    
    [super dealloc];
}
@end