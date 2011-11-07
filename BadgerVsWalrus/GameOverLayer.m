//
//  BWGameOverLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 23/10/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import "GameOverLayer.h"
#import "GameLayer.h"
#import "MainMenuLayer.h"
#import "Datastore.h"
#import "ChooserLayer.h"

#define ALL_ITEMS_Y_OFFSET 65

@implementation GameOverLayer

@synthesize gameOutcome = _gameOutcome;
@synthesize finalTime = _finalTime;
@synthesize winningSpriteFile = _winningSpriteFile;

+ (CCScene *)sceneWithGameOutcome:(GameOutcome)gameOutcome didPlayerWin:(BOOL)didPlayerWin time:(float)time {
    return [GameOverLayer sceneWithGameOutcome:gameOutcome didPlayerWin:didPlayerWin time:time isNetworkGame:NO];
}

+ (CCScene *)sceneWithGameOutcome:(GameOutcome)gameOutcome didPlayerWin:(BOOL)didPlayerWin time:(float)time isNetworkGame:(BOOL)isNetworkGame {
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [GameOverLayer node];
    
    if (didPlayerWin) {
        [layer setHighScore:time];
    }
    
    if (isNetworkGame) {
        layer.networkManager = [NetworkManager manger];
        layer.networkManager.gameOverDelegate = layer;
    }
    
    layer.gameOutcome = gameOutcome;
    layer.finalTime = time;
    
    NSString *winningSpriteFile = nil;
    switch (gameOutcome) {
        case kGameOutcomeCowWon:
            winningSpriteFile = @"cow.png";
            break;
        case kGameOutcomePenguinWon:
            winningSpriteFile = @"penguin.png";
        default:
            break;
    }
    
    layer.winningSpriteFile = winningSpriteFile;
    [scene addChild: layer];
    return scene;
}

-(id) init
{
	if(self=[super init]) {    
        _winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *backdrop = [CCSprite spriteWithFile:@"game_over_backdrop.png"];
        backdrop.position = ccp(_winSize.width/2, _winSize.height/2);
        [self addChild:backdrop];
        
        CCMenuItemImage *mainMenuMenuItem = [CCMenuItemImage itemFromNormalImage:@"main_menu_button.png"
                                                               selectedImage: @"main_menu_button.png"
                                                                      target:self
                                                                    selector:@selector(showMainMenu:)];
        
        CCMenuItemImage *playAgainMenuItem = [CCMenuItemImage itemFromNormalImage:@"play_again_button.png"
                                                                   selectedImage: @"play_again_button.png"
                                                                          target:self
                                                                        selector:@selector(playAgain:)];
        
        CCMenu *menu = [CCMenu menuWithItems:mainMenuMenuItem, playAgainMenuItem, nil];
        menu.position = ccp(_winSize.width/2,ALL_ITEMS_Y_OFFSET);
        [menu alignItemsHorizontallyWithPadding:5];
        [self addChild:menu];
        
        CCSprite *winsLabel = [CCLabelTTF labelWithString:@"WINS" fontName:@"MarkerFelt-Wide" fontSize:55];
        winsLabel.position = ccp((_winSize.width/2) + 30,190 + ALL_ITEMS_Y_OFFSET);
        winsLabel.color = ccc3(64,64,64);
        [self addChild: winsLabel];
        
        self.isTouchEnabled = YES;
	}
    
	return self;
}

- (void)setHighScore:(float)finalTime {
    if ([[Datastore dataStore] isTimeHighScore:finalTime]) {
        CCSprite *newHighScore = [CCSprite spriteWithFile:@"new_high_score.png"];
        newHighScore.position = ccp(349,136 + ALL_ITEMS_Y_OFFSET);
        [self addChild:newHighScore];   
        
        [[Datastore dataStore] saveHighScoreTime:finalTime];
    }
}

- (void)setFinalTime:(float)finalTime {
    NSString *timeString = [NSString stringWithFormat:@"Time: %.2f", finalTime];
    
    CCSprite *timeLabel = [CCLabelTTF labelWithString:timeString fontName:@"MarkerFelt-Wide" fontSize:50];
    timeLabel.position = ccp((_winSize.width/2),110 + ALL_ITEMS_Y_OFFSET);
    timeLabel.color = ccc3(0,0,0);
    [self addChild: timeLabel];
    
    if (!self.networkManager) {
        NSArray *highScores = [[Datastore dataStore] getHighScores];
        
        if ([highScores count] > 0) {
            double topScore = [[highScores objectAtIndex:0] doubleValue];
            NSString *topScoreString = [NSString stringWithFormat: @"Top Score: %.2f", topScore];
            CCSprite *topScoreLabel = [CCLabelTTF labelWithString:topScoreString fontName:@"MarkerFelt-Wide" fontSize:25];
            
            //right align with time label
            int xPostion = (timeLabel.boundingBox.origin.x + timeLabel.boundingBox.size.width) - (topScoreLabel.boundingBox.size.width/2);
            
            topScoreLabel.position = ccp(xPostion,60 + ALL_ITEMS_Y_OFFSET);
            topScoreLabel.color = ccc3(0,0,0);
            [self addChild: topScoreLabel];
        }
    }
}

- (void)setWinningSpriteFile:(NSString *)winningSpriteFile {
    NSString *oldValue = _winningSpriteFile;
    _winningSpriteFile = [winningSpriteFile retain];
    [oldValue release];
    
    CCSprite *winningSprite = [CCSprite spriteWithFile:self.winningSpriteFile];
    winningSprite.position = ccp((_winSize.width/2) - 70,190 + ALL_ITEMS_Y_OFFSET);
    [self addChild:winningSprite];
}

- (void)playAgain:(CCMenuItem  *)menuItem {    
    if (self.networkManager) {
        [self.networkManager playAgain];
    }
    
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[ChooserLayer sceneWithNetwork:self.networkManager ? YES : NO]]];
}

- (void)showMainMenu:(CCMenuItem  *)menuItem {
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuLayer scene]]];
    
    if (self.networkManager) {
        [self.networkManager invalidateSession];
    }
}

- (void)otherPlayerPlayedAgain {
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[ChooserLayer sceneWithNetwork:YES]]];    
}

- (void)dealloc {
    [_winningSpriteFile release];
    _winningSpriteFile = nil;
    
    [super dealloc];
}

@end
