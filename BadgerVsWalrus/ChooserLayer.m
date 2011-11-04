//
//  ChooserLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 30/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChooserLayer.h"
#import "GameLayer.h"
#import "MainMenuLayer.h"

@implementation ChooserLayer

@synthesize networkManager = _networkManager;

+ (CCScene *)scene {
    return [ChooserLayer sceneWithNetwork:NO];
}

+ (CCScene *)sceneWithNetwork:(BOOL)networkGame
{
    CCScene *scene = [CCScene node];
    ChooserLayer *layer = [ChooserLayer node];
    if (networkGame) {
        layer.networkManager = [NetworkManager manger];
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
        
        CCSprite *optionsLabel = [CCLabelTTF labelWithString:@"Choose:" fontName:@"MarkerFelt-Wide" fontSize:55];
        optionsLabel.position = ccp(winSize.width/2,210);
        [self addChild: optionsLabel];
        
        _cowButton = [CCSprite spriteWithFile:@"choose_button.png"];
        _cowButton.position = ccp(winSize.width/2 - 80,100);
        [self addChild: _cowButton];
        
        CCSprite *cow = [CCSprite spriteWithFile:@"cow.png"];
        cow.position = ccp(winSize.width/2 - 80,103);
        [self addChild: cow];
        
        _penguinButton = [CCSprite spriteWithFile:@"choose_button.png"];
        _penguinButton.position = ccp(winSize.width/2 + 80,100);
        [self addChild: _penguinButton];
        
        CCSprite *penguin = [CCSprite spriteWithFile:@"penguin.png"];
        penguin.position = ccp(winSize.width/2 + 80,105);
        [self addChild: penguin];
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

- (void)setNetworkManager:(NetworkManager *)networkManger {
    [networkManger retain];
    [_networkManager release];
    _networkManager = networkManger;
    networkManger.chooserDelegate = self;
}

//- (NetworkManager *)networkManager {
//    return [_networkManager autorelease];
//}

- (void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    BOOL animalChosen = YES;
    
    Animal chosenAnimal;
    if (CGRectContainsPoint(_cowButton.boundingBox, location)) {  
        chosenAnimal = kCow;
        NSLog(@"Cow chosen.");
    }else if(CGRectContainsPoint(_penguinButton.boundingBox, location)) {
        chosenAnimal = kPenguin;
        NSLog(@"Penguin chosen.");
    }else{
        animalChosen = NO;
    }
    
    if (animalChosen) {
        if (self.networkManager) {
            [self.networkManager chooseAnimal:chosenAnimal];
            NSLog(@"Chose animal on network.");
        } else {
            [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GameLayer sceneWithChosenAnimal:chosenAnimal]]];        
        }
    }
    
    return NO;
}

- (void)otherPlayerChoseAnimal:(Animal)animal {
    NSLog(@"Other player chose animal: %@.", animal == kCow ? @"Cow" : @"Penguin");
}

- (void)connectionLost {
    NSLog(@"Lost network connection.");
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Network Problem." message:@"There was an error with the network and the connection has been lost." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuLayer scene]]];  
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
