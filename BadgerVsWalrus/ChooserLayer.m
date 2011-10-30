//
//  ChooserLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 30/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChooserLayer.h"
#import "GameLayer.h"

@implementation ChooserLayer

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    ChooserLayer *layer = [ChooserLayer node];
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

- (void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    Animal choosenAnimal;
    if (CGRectContainsPoint(_cowButton.boundingBox, location)) {  
        choosenAnimal = kCow;
        NSLog(@"Cow chosen.");
    }else if(CGRectContainsPoint(_penguinButton.boundingBox, location)) {
        choosenAnimal = kPenguin;
        NSLog(@"Penguin chosen.");
    }
    
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GameLayer sceneWithChosenAnimal:choosenAnimal]]];
    
    return NO;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {    
}

- (void)dealloc {
    [_cowButton release];
    [_penguinButton release];
}

@end
