//
//  OptionsLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 29/10/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import "OptionsLayer.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"
#import "Datastore.h"

@implementation OptionsLayer

int musicMinX;
int musicMaxX;

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    OptionsLayer *layer = [OptionsLayer node];
    [scene addChild: layer];
    
	return scene;
}

- (id)init {
    if(self = [super init]){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *backdrop = [CCSprite spriteWithFile:@"options_backdrop.png"];
        backdrop.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:backdrop];
        
        CCMenuItemImage *mainMenuMenuItem = [CCMenuItemImage itemFromNormalImage:@"main_menu_button.png"
                                                                   selectedImage: @"main_menu_button.png"
                                                                          target:self
                                                                        selector:@selector(showMainMenu:)];
        
        CCMenu *menu = [CCMenu menuWithItems:mainMenuMenuItem, nil];
        menu.position = ccp(winSize.width/2,50);
        [menu alignItemsHorizontallyWithPadding:5];
        [self addChild:menu];
        
        
        CCMenuItemImage *clearHiScoresMenuItem = [CCMenuItemImage itemFromNormalImage:@"clear_hi_scores_button.png"
                                                                   selectedImage: @"clear_hi_scores_button.png"
                                                                          target:self
                                                                        selector:@selector(clearHiScores:)];
        
        CCMenu *clearHiScoresMenu = [CCMenu menuWithItems:clearHiScoresMenuItem, nil];
        clearHiScoresMenu.position = ccp(winSize.width/2,125);
        [menu alignItemsHorizontallyWithPadding:5];
        [self addChild:clearHiScoresMenu];
        
        
        CCSprite *optionsLabel = [CCLabelTTF labelWithString:@"OPTIONS" fontName:@"MarkerFelt-Wide" fontSize:55];
        optionsLabel.position = ccp(winSize.width/2,280);
        optionsLabel.color = ccc3(255,178,43);
        [self addChild: optionsLabel];
        
        CCSprite *musicVolumeLabel = [CCLabelTTF labelWithString:@"Music Volume" fontName:@"MarkerFelt-Wide" fontSize:24];
        musicVolumeLabel.position = ccp(winSize.width/2 -50,210);
        [self addChild: musicVolumeLabel];
        
        _musicSliderBackdrop = [CCSprite spriteWithFile:@"slider_marker.png"];
        _musicSliderBackdrop.position = ccp(winSize.width/2, 170);
        [self addChild:_musicSliderBackdrop];

        musicMinX = _musicSliderBackdrop.boundingBox.origin.x;
        musicMaxX = _musicSliderBackdrop.boundingBox.origin.x + _musicSliderBackdrop.boundingBox.size.width;        

        float volume = [CDAudioManager sharedManager].backgroundMusic.volume;
        float xPos = musicMinX + ((float)(musicMaxX - musicMinX) * volume);
        NSLog(@"Slider X Postion: %f", xPos);
        
        _musicSlider = [CCSprite spriteWithFile:@"penguin_small.png"];
        _musicSlider.position = ccp((int)xPos, 170);
        [self addChild:_musicSlider];
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

- (void)registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertTouchToNodeSpace: touch];
	if(CGRectContainsPoint(_musicSlider.boundingBox, location)) {
		return YES;
	}
	return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace: touch];
    if((location.x < musicMinX) || (location.x > musicMaxX)) {
        return;
    }
    
	_musicSlider.position=ccp(location.x,170);
    
    float musicVolumeLineLenth = musicMaxX - musicMinX;
    float distanceAlongLength = location.x - musicMinX;
    float musicVolume = (distanceAlongLength / musicVolumeLineLenth);
    [CDAudioManager sharedManager].backgroundMusic.volume = musicVolume;
}

- (void)showMainMenu:(CCMenuItem *)menuItem {
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuLayer scene]]];
}

- (void)clearHiScores:(CCMenuItem *)menuItem {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Clear Highscores?" message:nil delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
	[alertView show];
	[alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 0) {
		NSLog(@"Clear highscores.");
        [[Datastore dataStore] deleteHiScores];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Highscores cleared." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
	} else {
        NSLog(@"Don't clear highscores.");
	}
}

@end
