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

static const float _player1StartY = 210;
static const float _player2StartY = 135;
static const float _startX = 66;
static const float _endX = 359;
static const float _tickerXStartpoint = 140;
static const float _tickerXEndpoint = 27;
static BOOL _flashed;

@implementation GameLayer

@synthesize player1 = _player1;
@synthesize player2 = _player2;
@synthesize player1Selected = _player1Selected;
@synthesize player2Selected = _player2Selected;
@synthesize beatIndicator = _beatIndicator;
@synthesize tapButton = _tapButton;
@synthesize timeLabel = _timeLabel;
@synthesize choosenAnimal = _choosenAnimal;
@synthesize tapInterpreter = _tapInterpreter;
@synthesize tickers = _tickers;
@synthesize tickerViewport = _tickerViewport;
@synthesize flashSprite = _flashSprite;
@synthesize flashAnimation = _flashAnimation;

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
        
        self.tickers = [[NSMutableArray alloc] init];
        
        TapInterpreter *interpreter = [[TapInterpreter alloc] init];
        self.tapInterpreter = interpreter;
        [interpreter release];

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

        self.player1Selected = [CCSprite spriteWithFile:@"cow_glow.png"];
        self.player1Selected.position = selectedPlayerLocation;
        self.player1Selected.visible = NO;
        [self addChild:self.player1Selected];
        
        self.player2Selected = [CCSprite spriteWithFile:@"penguin_glow.png"];
        self.player2Selected.position = selectedPlayerLocation;
        self.player2Selected.visible = NO;
        [self addChild:self.player2Selected];
        
        CCSprite *tickerBackdrop = [CCSprite spriteWithFile:@"ticker_backdrop.png"];
        tickerBackdrop.position = ccp(72, 296);
        [self addChild:tickerBackdrop];
        
        CCSprite *tickerEndpoint = [CCSprite spriteWithFile:@"ticker_endpoint.png"];
        tickerEndpoint.position = ccp(_tickerXEndpoint, 296);
        [self addChild:tickerEndpoint];
        
        //Viewport used to clip sprites so they only appear in the ticker backdrop
        CGRect viewportRect = CGRectMake(0, 0, 129, 320);
        self.tickerViewport = [Viewport viewportWithRect:viewportRect];
        [self addChild:self.tickerViewport];
        
        self.timeLabel = [CCLabelTTF labelWithString:@"Time:" fontName:@"Marker Felt" fontSize:40];
        self.timeLabel.position = ccp(winSize.width/2 - 43, 27);
        [self addChild: self.timeLabel];
        
        self.timeLabel = [CCLabelTTF labelWithString:@INITIAL_TIME_LABEL fontName:@"Marker Felt" fontSize:40];
        self.timeLabel.position = ccp(winSize.width/2 + 60, 27);
        [self addChild: self.timeLabel];
        
        //Setup ticker flash animation
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"flash.plist"];
        
        CCSpriteBatchNode *batchNode = [CCSpriteBatchNode batchNodeWithFile:@"flash.png"];
        [self addChild:batchNode];
        
        NSMutableArray *animFrames = [NSMutableArray array];
        for(int i = 0; i < 19; i++) {
            NSString *frameName = [NSString stringWithFormat:@"flash%04d.png",i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
            [animFrames addObject:frame];
        }
        
        _flashSprite = [CCSprite spriteWithSpriteFrameName:@"flash0000.png"];
        _flashSprite.position = ccp(45, 280);
        [batchNode addChild:_flashSprite];
        
        self.flashAnimation = [CCAnimation animationWithFrames:animFrames];
        _flashed = NO;
        
        //Setup schedulers
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

- (void)playTickerFlash {
    [self.flashSprite runAction:[CCAnimate actionWithDuration:0.5f animation:self.flashAnimation restoreOriginalFrame:NO]];
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
    
        float tapLength = fabsf(_tapStartTime - [NSDate timeIntervalSinceReferenceDate]);
        [self.tapInterpreter registerTapWithLength:tapLength];
    }
}

- (void)tapWasSuccess:(BOOL)wasSuccess withBonus:(TapBonus)bonus {
    
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
    
    BOOL networkGame = self.networkManager ? YES : NO;
    CCScene *gameOverScene = [GameOverLayer sceneWithGameOutcome:outcome didPlayerWin:didWin time:time isNetworkGame:networkGame];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:gameOverScene]];
}


#pragma mark animation

- (void)animateTickersWithTimeDelta:(ccTime)dt {
    //animate
    for (CCSprite *tickerObject in self.tickers) {
        tickerObject.position = ccp(tickerObject.position.x - 70 * dt, tickerObject.position.y);
    }
    
    //add
    BOOL shouldAddTickerItem = NO;
    
    if (self.tickers.count == 0) {
        shouldAddTickerItem = YES;
    } else {
        CCSprite *lastTickerItem = [self.tickers objectAtIndex:(self.tickers.count - 1)];
        int tickerX = lastTickerItem.boundingBoxInPixels.origin.x;
        int tickerWidth = lastTickerItem.boundingBoxInPixels.size.width;
        
        if ((tickerX + tickerWidth + 30) < _tickerXStartpoint) {
            shouldAddTickerItem = YES;
        }
    }

    if (shouldAddTickerItem) {
        TickerElementType tickerType = (TickerElementType)(arc4random() % 2);
        
        NSString *tickerItemPng = tickerType == kDot ? @"dot.png" : @"dash.png";    
        CCSprite *tickerItem = [CCSprite spriteWithFile:tickerItemPng];
        tickerItem.position = ccp(_tickerXStartpoint, 296);
        
        TickerElementType *tickerElementType = malloc(sizeof(TickerElementType));
        *tickerElementType = tickerType;
        tickerItem.userData = tickerElementType;
        
        [self.tickers addObject:tickerItem];
        [self.tickerViewport addChild:tickerItem];
    }
    
    //remove
    CCSprite *longestRunningTicker = [self.tickers objectAtIndex:0];
    if (longestRunningTicker) {
        if (longestRunningTicker.position.x < (_tickerXEndpoint + 10) && !_flashed) {
            [self playTickerFlash];   //Play flash just before ticker item disappears
            
            TickerElementType *tickerElementType = longestRunningTicker.userData;
            TapType tapType = (*tickerElementType) == kDot ? kShortTap : kLongTap;
            free(tickerElementType);
            
            [self.tapInterpreter startTapThresholdForTapType:tapType];
            
            _flashed = YES;
        } else if (longestRunningTicker.position.x < _tickerXEndpoint && _flashed) {
            [self.tickerViewport removeChild:longestRunningTicker cleanup:YES];
            [self.tickers removeObjectAtIndex:0];
            [self.tapInterpreter stopTapThreshold];
            _flashed = NO;
        }
    }
}

- (void)update:(ccTime)dt {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart){
        return;
    }
    
    [self animateTickersWithTimeDelta:dt];
    
    if (self.networkManager) {
        static int counter = 1;
        
        if (counter % 8 == 0) { //send network heartbeat once every 8 counts
            [self.networkManager heartbeatWithXPostion:self.humanPlayer.position.x time:_gameTime];
        }
        
        if (self.humanPlayer.position.x >= _endX) {
            [self.networkManager wonWithXPosition:self.humanPlayer.position.x time:_gameTime];
            [self pause];
        }
        
        counter++;
    } else {
        self.otherPlayer.position = ccp(self.otherPlayer.position.x + 10 * dt, self.otherPlayer.position.y);   
        
        if (self.player1.position.x >= _endX && self.player2.position.x >= _endX) {
            [self pause];
            [self gameOverWithOutcome:kGameOutcomeDraw withTime:_gameTime];
        } else if(self.player1.position.x >= _endX) {
            [self pause];            
            [self gameOverWithOutcome:kGameOutcomeCowWon withTime:_gameTime];
        } else if(self.player2.position.x >= _endX) {
            [self pause];            
            [self gameOverWithOutcome:kGameOutcomePenguinWon withTime:_gameTime];
        }
    }
}

- (void)timerUpdate:(ccTime)dt {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart){
        return;
    }
    
    _gameTime += dt;
    self.timeLabel.string = [NSString stringWithFormat:@"%.2f", _gameTime];
}

#pragma mark -

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
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    [_player1 release];
    [_player2 release];
    [_player1Selected release];
    [_player2Selected release];
    [_beatIndicator release];
    [_tapButton release];
    [_timeLabel release];
    [_tickers release];
    [_tickerViewport release];
    [_tapInterpreter release];
    
    [super dealloc];
}
@end
