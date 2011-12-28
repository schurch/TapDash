//
//  HiScoreLayer.m
//  FarmyardDash
//
//  Created by Stefan Church on 27/10/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import "HighscoreLayer.h"
#import "MainMenuLayer.h"
#import "Datastore.h"

static const int INITIAL_SCORE_LABEL_Y_POS = 225;
static const int Y_SCORE_LABEL_INCREMENT = -40;
static const int STAR_X_OFFSET = 20;

@implementation HighscoreLayer

+ (CCScene *)scene
{
	CCScene *scene = [CCScene node];
    HighscoreLayer *layer = [HighscoreLayer node];
    [scene addChild: layer];
    
	return scene;
}

- (id)init {
    if(self = [super init]){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *backdrop = [CCSprite spriteWithFile:@"hi_score_backdrop.png"];
        backdrop.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:backdrop];
        
        CCMenuItemImage *mainMenuMenuItem = [CCMenuItemImage itemFromNormalImage:@"main_menu_button.png"
                                                                   selectedImage: @"main_menu_button.png"
                                                                          target:self
                                                                        selector:@selector(showMainMenu:)];
        
        CCMenu *menu = [CCMenu menuWithItems:mainMenuMenuItem, nil];
        menu.position = ccp(winSize.width/2,40);
        [menu alignItemsHorizontallyWithPadding:5];
        [self addChild:menu];
        
        CCSprite *hiScoresLabel = [CCLabelTTF labelWithString:@"HIGHSCORES" fontName:@"MarkerFelt-Wide" fontSize:55];
        hiScoresLabel.position = ccp(winSize.width/2,280);
        hiScoresLabel.color = ccc3(255,178,43);
        [self addChild: hiScoresLabel];
        
        
        NSArray *hiScores = [[Datastore dataStore] getHighScores];
        
        int yPostion = INITIAL_SCORE_LABEL_Y_POS;
        for (int i = 0; i < hiScores.count; i++) {
            NSString *scoreText = [NSString stringWithFormat:@"%i.      %.2f", i+1, [[hiScores objectAtIndex:i] doubleValue]];
            CCSprite *scoreLabel = [CCLabelTTF labelWithString:scoreText fontName:@"MarkerFelt-Wide" fontSize:35];
            scoreLabel.position = ccp((winSize.width/2) - STAR_X_OFFSET,yPostion);
            [self addChild: scoreLabel];
            
            CCSprite *star = [CCSprite spriteWithFile:@"star.png"];        
            star.position = ccp(scoreLabel.boundingBox.origin.x + scoreLabel.boundingBox.size.width + STAR_X_OFFSET, yPostion);
            [self addChild:star];
            
            yPostion = yPostion + Y_SCORE_LABEL_INCREMENT;
        }
    }
    
    return self;
}

- (void)showMainMenu:(CCMenuItem *)menuItem {
        [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuLayer scene]]];
}

- (void)dealloc {
    [super dealloc];
}

@end
