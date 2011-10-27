//
//  MainMenuLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 27/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameLayer.h"

@implementation MainMenuLayer

CCSprite *_backdrop;

+(CCScene *) scene
{
	static CCScene *scene;
    
    if(!scene){
        scene = [CCScene node];
        MainMenuLayer *layer = [MainMenuLayer node];
        [scene addChild: layer];
    }
    
	return scene;
}

-(id) init
{
	if( (self=[super init])) {     
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _backdrop = [CCSprite spriteWithFile:@"main_menu_backdrop.png"];
        _backdrop.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_backdrop];
        
        CCSprite *versionLabel = [CCLabelTTF labelWithString:@"v0.1" fontName:@"Marker Felt" fontSize:15];
        versionLabel.position = ccp(18,310);
        versionLabel.color = ccc3(0,0,0);
        [self addChild: versionLabel];
        
        CCMenuItemImage *playMenuItem = [CCMenuItemImage itemFromNormalImage:@"play_button.png"
                                                            selectedImage: @"play_button.png"
                                                                   target:self
                                                                 selector:@selector(play:)];
        
        CCMenuItemImage *hiScoresMenuItem = [CCMenuItemImage itemFromNormalImage:@"hi_scores_button.png"
                                                               selectedImage: @"hi_scores_button.png"
                                                                      target:self
                                                                    selector:@selector(hiScores:)];
        
        CCMenu *menu = [CCMenu menuWithItems:playMenuItem, hiScoresMenuItem, nil];
        menu.position = ccp(winSize.width/2,170);
        [menu alignItemsVerticallyWithPadding:5];
        
        [self addChild:menu];

        
        self.isTouchEnabled = YES;
	}
	return self;
}

- (void)play:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[GameLayer scene]]];
}

- (void)hiScores:(CCMenuItem  *)menuItem {

}

@end
