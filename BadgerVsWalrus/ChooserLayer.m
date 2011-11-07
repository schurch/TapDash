//
//  ChooserLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 30/10/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import "ChooserLayer.h"
#import "GameLayer.h"
#import "MainMenuLayer.h"

const int buttonHeight = 130;

@implementation ChooserLayer

+ (CCScene *)scene {
    return [ChooserLayer sceneWithNetwork:NO];
}

+ (CCScene *)sceneWithNetwork:(BOOL)networkGame
{
    CCScene *scene = [CCScene node];
    ChooserLayer *layer = [ChooserLayer node];
    if (networkGame) {
        layer.networkManager = [NetworkManager manger];
        layer.networkManager.chooserDelegate = layer;
    }
    [scene addChild: layer];
    
	return scene;
}

- (id)init {
    if(self = [super init]){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *backdrop = [CCSprite spriteWithFile:@"choose_backdrop.png"];
        backdrop.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:backdrop];
        
        CCSprite *optionsLabel = [CCLabelTTF labelWithString:@"OR" fontName:@"MarkerFelt-Wide" fontSize:55];
        optionsLabel.position = ccp(winSize.width/2, buttonHeight);
        [self addChild: optionsLabel];
        
        _cowButton = [CCSprite spriteWithFile:@"choose_button.png"];
        _cowButton.position = ccp(winSize.width/2 - 120, buttonHeight);
        [self addChild: _cowButton];
        
        CCSprite *cow = [CCSprite spriteWithFile:@"cow.png"];
        cow.position = ccp(winSize.width/2 - 120, buttonHeight + 3);
        [self addChild: cow];
        
        _cowButtonSelectedOverlay = [CCSprite spriteWithFile:@"selected_button_overlay.png"];
        _cowButtonSelectedOverlay.position = ccp(winSize.width/2 - 122, buttonHeight + 3);
        _cowButtonSelectedOverlay.visible = NO;
        [self addChild: _cowButtonSelectedOverlay];
        
        _penguinButton = [CCSprite spriteWithFile:@"choose_button.png"];
        _penguinButton.position = ccp(winSize.width/2 + 120, buttonHeight);
        [self addChild: _penguinButton];
        
        CCSprite *penguin = [CCSprite spriteWithFile:@"penguin.png"];
        penguin.position = ccp(winSize.width/2 + 120, buttonHeight + 5);
        [self addChild: penguin];
        
        _penguinButtonSelectedOverLay = [CCSprite spriteWithFile:@"selected_button_overlay.png"];
        _penguinButtonSelectedOverLay.position = ccp(winSize.width/2 + 118, buttonHeight + 3);
        _penguinButtonSelectedOverLay.visible = NO;
        [self addChild: _penguinButtonSelectedOverLay];
        
        _cowChosen = NO;
        _penguinChosen = NO;
        _chosenAnimal = kAnimalNone;
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

- (void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)attemptNetworkGameStart {
    if (self.networkManager && _cowChosen && _penguinChosen) {
        [self.networkManager startGame];
        [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GameLayer sceneWithChosenAnimal:_chosenAnimal isNetworkGame:YES]]];    
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {       
    CGPoint location = [self convertTouchToNodeSpace: touch];    
    BOOL animalChosen = YES;
    
    if (CGRectContainsPoint(_cowButton.boundingBox, location) && !_cowChosen && _chosenAnimal == kAnimalNone) {  
        _chosenAnimal = kAnimalCow;
        _cowChosen = YES;
        NSLog(@"Cow chosen.");
    } else if(CGRectContainsPoint(_penguinButton.boundingBox, location) && !_penguinChosen && _chosenAnimal == kAnimalNone) {
        _chosenAnimal = kAnimalPenguin;
        _penguinChosen = YES;
        NSLog(@"Penguin chosen.");
    } else {
        animalChosen = NO;
    }
    
    if (animalChosen) {
        if (self.networkManager) {
            [self.networkManager chooseAnimal:_chosenAnimal];
            NSLog(@"Attempting to choose animal on network.");
        } else {
            [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GameLayer sceneWithChosenAnimal:_chosenAnimal]]];        
        }
    }
    
    return NO;
}

- (void)choiceRejectedOrAccepted:(BOOL)accepted {
    if (accepted) {
        if (_chosenAnimal == kAnimalCow) {
            _cowButtonSelectedOverlay.visible = YES;
            _cowChosen = YES;
        } else {
            _penguinButtonSelectedOverLay.visible = YES;
            _penguinChosen = YES;
        }
    } else {
        _chosenAnimal = kAnimalNone;
    }
}

- (void)otherPlayerChoseAnimal:(Animal)animal {
    if (animal == kAnimalCow) {
        _cowButtonSelectedOverlay.visible = YES;
        _cowChosen = YES;
    } else {
        _penguinButtonSelectedOverLay.visible = YES;
        _penguinChosen = YES;
    }
    
    [self attemptNetworkGameStart];
}

- (void)otherPlayerStartedGame {
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GameLayer sceneWithChosenAnimal:_chosenAnimal isNetworkGame:YES]]];
}

- (void)pickerCanceled {
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuLayer scene]]];      
}

- (void)dealloc {
    [_networkManager release];
    [_cowButton release];
    [_penguinButton release];
}

@end
