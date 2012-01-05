//
//  HelloWorldLayer.m
//  TapDash
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright Stefan Church 2011. All rights reserved.
//


#import "GameLayer.h"
#import "MainMenuLayer.h"
#import <AudioToolbox/AudioServices.h>

#define INITIAL_TIME_LABEL "0:00"
#define COUNTDOWN_LAYER_TAG 1000
#define BONUS_SPRITE_HEIGHT 260

static const int _tickerMovementConst = 50;

static const float _tickerThresholdTimeSecs = 0.3;
static const float _player1StartY = 210;
static const float _player2StartY = 135;
static const float _startX = 66;
static const float _endX = 359;
static const float _tickerXStartpoint = 140;
static const float _tickerXEndpoint = 27;
static const float _totalBonusDisplayTimeSecs = 0.5;

static BOOL _flashed;
static BOOL _tapped;
static BOOL _startedTapThreshold;
static CGSize _winSize;
static float _bonusDisplayTime;
static float _thresholdTimer;

@implementation GameLayer

@synthesize player1 = _player1;
@synthesize player2 = _player2;
@synthesize player1Selected = _player1Selected;
@synthesize player2Selected = _player2Selected;

@synthesize star1 = _star1;
@synthesize star2 = _star2;
@synthesize doubleTap = _doubleTap;
@synthesize megaTap = _megaTap;
@synthesize monsterTap = _monsterTap;
@synthesize multiTap = _multiTap;
@synthesize ultraTap = _ulraTap;

@synthesize bonuses;

@synthesize bonusCalculator;

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
        _winSize = [[CCDirector sharedDirector] winSize];
        
        self.tickers = [[NSMutableArray alloc] init];
        
        TapInterpreter *interpreter = [[TapInterpreter alloc] init];
        self.tapInterpreter = interpreter;
        self.tapInterpreter.delegate = self;
        [interpreter release];

        CCSprite *backdrop = [CCSprite spriteWithFile:@"game_backdrop.png"];
        backdrop.position = ccp(_winSize.width/2, _winSize.height/2);
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
        
        //Bonus sprites                
        self.doubleTap = [CCSprite spriteWithFile:@"double_tap.png"];
        self.doubleTap.position = ccp(_winSize.width/2, BONUS_SPRITE_HEIGHT);
        self.doubleTap.visible = NO;
        [self addChild:self.doubleTap];
        
        self.megaTap = [CCSprite spriteWithFile:@"mega_tap.png"];
        self.megaTap.position = ccp(_winSize.width/2, BONUS_SPRITE_HEIGHT);
        self.megaTap.visible = NO;
        [self addChild:self.megaTap];
        
        self.monsterTap = [CCSprite spriteWithFile:@"monster_tap.png"];
        self.monsterTap.position = ccp(_winSize.width/2, BONUS_SPRITE_HEIGHT);
        self.monsterTap.visible = NO;
        [self addChild:self.monsterTap];
        
        self.multiTap = [CCSprite spriteWithFile:@"multi_tap.png"];
        self.multiTap.position = ccp(_winSize.width/2, BONUS_SPRITE_HEIGHT);
        self.multiTap.visible = NO;
        [self addChild:self.multiTap];
        
        self.ultraTap = [CCSprite spriteWithFile:@"ultra_tap.png"];
        self.ultraTap.position = ccp(_winSize.width/2, BONUS_SPRITE_HEIGHT);
        self.ultraTap.visible = NO;
        [self addChild:self.ultraTap];
        
        int doubleTapWidth = self.doubleTap.boundingBox.size.width;   
//        NSLog(@"Double tap width = %d.", doubleTapWidth);
        
        self.star1 = [CCSprite spriteWithFile:@"star.png"];
        self.star1.position = ccp(_winSize.width/2 - ((doubleTapWidth/2) + 20), BONUS_SPRITE_HEIGHT);
        self.star1.visible = NO;
        [self addChild:self.star1];
        
        self.star2 = [CCSprite spriteWithFile:@"star.png"];
        self.star2.position = ccp(_winSize.width/2 + ((doubleTapWidth/2) + 20), BONUS_SPRITE_HEIGHT);
        self.star2.visible = NO;
        [self addChild:self.star2];      
        
        self.bonuses = [[NSMutableArray alloc] init];
        
        //Viewport used to clip sprites so they only appear in the ticker backdrop
        CGRect viewportRect = CGRectMake(0, 0, 129, 320);
        self.tickerViewport = [Viewport viewportWithRect:viewportRect];
        [self addChild:self.tickerViewport];
        
        self.timeLabel = [CCLabelTTF labelWithString:@"Time:" fontName:@"Marker Felt" fontSize:40];
        self.timeLabel.position = ccp(_winSize.width/2 - 43, 27);
        [self addChild: self.timeLabel];
        
        self.timeLabel = [CCLabelTTF labelWithString:@INITIAL_TIME_LABEL fontName:@"Marker Felt" fontSize:40];
        self.timeLabel.position = ccp(_winSize.width/2 + 60, 27);
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
        
        _tapped = NO;
        _startedTapThreshold = NO;
        _movementBonus = 1;
        _bonusDisplayTime = 0;
        _thresholdTimer = 0;
        
        BonusCalculator *aiBonusCalculator = [[BonusCalculator alloc] init];
        self.bonusCalculator = aiBonusCalculator;
        [aiBonusCalculator release];
        
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
    
        if (!_tapped) {
            float tapLength = fabsf(_tapStartTime - [NSDate timeIntervalSinceReferenceDate]);
            [self.tapInterpreter registerTapWithLength:tapLength];
            _tapped = YES;
        }
    }
}

- (void)tapWasSuccess:(BOOL)wasSuccess withBonus:(TapBonus)bonus {
    if (wasSuccess) {
//        NSLog(@"Tap success.");
        
        CCSprite *bonusSprite;
        switch (bonus) {
            case kTapBonusDouble:
                bonusSprite = self.doubleTap;
                _movementBonus = 2;                
                break;
            case kTapBounsMulti:
                bonusSprite = self.multiTap;                
                _movementBonus = 3;
                break;
            case kTapBonusMega:
                bonusSprite = self.megaTap;
                _movementBonus = 4;
                break;
            case kTapBonusUltra:
                bonusSprite = self.ultraTap;
                _movementBonus = 5;
                break;
            case kTapBonusMonster:
                bonusSprite = self.monsterTap;
                _movementBonus = 6;
                break;
            default:
                _movementBonus = 1;
                break;
        }
        
        if(bonus != kTapBonusNone) {
            [self.bonuses addObject:bonusSprite];
        }
    } else {
//        NSLog(@"Tap fail.");
        _movementBonus = 1;
    }
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

- (void)showBonusWithTimeDelta:(float)timeDelta {        
    if (self.bonuses.count == 0) {
        return;
    }
    
    if (_bonusDisplayTime == 0) {
        CCSprite *bonusSprite = [self.bonuses objectAtIndex:0];
        
        int bonusSpriteWidth = bonusSprite.boundingBox.size.width;        
//        NSLog(@"Bonus sprite tap width = %d.", bonusSpriteWidth);    
        
        self.star1.position = ccp(_winSize.width/2 - ((bonusSpriteWidth/2) + 20), BONUS_SPRITE_HEIGHT);
        self.star2.position = ccp(_winSize.width/2 + ((bonusSpriteWidth/2) + 20), BONUS_SPRITE_HEIGHT);
        
        self.star1.visible = YES;
        self.star2.visible = YES;
        bonusSprite.visible = YES;
        
        _bonusDisplayTime = _bonusDisplayTime + timeDelta;
    } else if (_bonusDisplayTime > _totalBonusDisplayTimeSecs) {
        ((CCSprite *)[self.bonuses objectAtIndex:0]).visible = NO;
        self.star1.visible = NO;
        self.star2.visible = NO;
        [self.bonuses removeObjectAtIndex:0];
        _bonusDisplayTime = 0;
    } else {
        _bonusDisplayTime = _bonusDisplayTime + timeDelta;
    }
}

- (void)animateTickersWithDeltaTime:(ccTime)dt {    
    //animate
    for (CCSprite *tickerObject in self.tickers) {
        tickerObject.position = ccp(tickerObject.position.x - _tickerMovementConst * dt, tickerObject.position.y);
    }
    
    //add
    BOOL shouldAddTickerItem = NO;
    
    if (self.tickers.count == 0) {
        shouldAddTickerItem = YES;
    } else {
        CCSprite *lastTickerItem = [self.tickers objectAtIndex:(self.tickers.count - 1)];
        int tickerX = lastTickerItem.boundingBoxInPixels.origin.x;
        int tickerWidth = lastTickerItem.boundingBoxInPixels.size.width;
        
        //This needs improving
        int randomTickerWidth = (arc4random() % 150) + 10;
//        NSLog(@"Random ticker width is %d.", randomTickerWidth);
        
        if ((tickerX + tickerWidth + randomTickerWidth) < _tickerXStartpoint) {
            shouldAddTickerItem = YES;
        }
    }

    if (shouldAddTickerItem) {
        NSString *tickerItemPng = @"dot.png";    
        CCSprite *tickerItem = [CCSprite spriteWithFile:tickerItemPng];
        tickerItem.position = ccp(_tickerXStartpoint, 296);
        
        [self.tickers addObject:tickerItem];
        [self.tickerViewport addChild:tickerItem];
    }
    
    //remove
    CCSprite *longestRunningTicker = [self.tickers objectAtIndex:0];
    if (longestRunningTicker) {
        //estimate time till ticker dissapears
        float estimatedMovementPerUpdate = _tickerMovementConst * dt;
        int distanceRemaining = longestRunningTicker.position.x - _tickerXEndpoint;
        float tickerTravelTimeRemaining = (distanceRemaining/estimatedMovementPerUpdate) * dt;
        
        if (tickerTravelTimeRemaining < (_tickerThresholdTimeSecs/2) && !_startedTapThreshold) {
            [self.tapInterpreter startTapThresholdForTap];
            _startedTapThreshold = YES;
        }
        
        if (longestRunningTicker.position.x < (_tickerXEndpoint + 10) && !_flashed) {
            [self playTickerFlash];   //Play flash just before ticker item disappears
            _flashed = YES;
        } else if (longestRunningTicker.position.x < _tickerXEndpoint && _flashed) {
            [self.tickerViewport removeChild:longestRunningTicker cleanup:YES];
            [self.tickers removeObjectAtIndex:0];

            _flashed = NO;
        }
        
        if(_startedTapThreshold) {
            _thresholdTimer = _thresholdTimer + dt;
            
            if (_thresholdTimer > _tickerThresholdTimeSecs) {
                [self.tapInterpreter stopTapThreshold];
                if (!_tapped) {
                    _movementBonus = 1;
                }
                _startedTapThreshold = NO;
                _tapped = NO;
                _thresholdTimer = 0;
            }
        }
        
    }
}

- (void)update:(ccTime)dt {
    if(_gameState == kGameStatePaused || _gameState == kGameStateStart){
        return;
    }
    
    [self animateTickersWithDeltaTime:dt];
    [self showBonusWithTimeDelta:dt];
    
    float xPosition = self.humanPlayer.position.x + 10 * dt * _movementBonus;
//    NSLog(@"Player 1 X Pos = %f", xPosition);
    self.humanPlayer.position = ccp(xPosition, self.humanPlayer.position.y);       
    
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
        
        [self.bonusCalculator calculateMovementBonus:_gameTime playerXPostion:self.humanPlayer.position.x computerXPostion:self.otherPlayer.position.x];
//        NSLog(@"Movemenxt bonus is %i.", self.bonusCalculator.movementBonus);
        self.otherPlayer.position = ccp(self.otherPlayer.position.x + 10 * dt * self.bonusCalculator.movementBonus, self.otherPlayer.position.y);   
        
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
    [_bonuses release];
    
    self.tapInterpreter.delegate = nil;
    
    [super dealloc];
}
@end
