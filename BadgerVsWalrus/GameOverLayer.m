//
//  BWGameOverLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 23/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameOverLayer.h"

CGSize winSize;

@implementation GameOverLayer

@synthesize delegate = _delegate;

+(CCScene *) scene
{
	static CCScene *scene;
    
    if(!scene){
        scene = [CCScene node];
        GameOverLayer *layer = [GameOverLayer node];
        [scene addChild: layer];
    }
    
	return scene;
}

-(id) init
{
	if( (self=[super init])) {      
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCLayerColor *colorLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
        [self addChild:colorLayer z:-1];
        
        CCMenuItemImage *menuItem1 = [CCMenuItemImage itemFromNormalImage:@"play_again_button.png"
                                                             selectedImage: @"play_again_button.png"
                                                                    target:self
                                                                  selector:@selector(playAgain:)];
        
        CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, nil];
        myMenu.position = ccp(winSize.width/2,100);
    
        [self addChild:myMenu];
        
        _gameOverLabel = [CCLabelTTF labelWithString:@"Game Over, sucka. You LOST!" fontName:@"Marker Felt" fontSize:30];
        _gameOverLabel.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild: _gameOverLabel];
        
        self.isTouchEnabled = YES;
	}
    
	return self;
}

- (void)setupLayerWithGameOutcome:(GameOutcome)gameOutcome {
    switch (gameOutcome) {
        case kBWGameOutcomeDraw:
            _gameOverLabel.string = @"It was a draw.";
            break;
        case kBWGameOutcomePlayer1Won:
            _gameOverLabel.string = @"You WON! Nice work man.";
            break;
        case KBWGameOutcomePlayer2won:
            _gameOverLabel.string = @"You LOST fool!";
            break;
        default:
            break;
    }
}

- (void)playAgain:(CCMenuItem  *)menuItem {
    if([[self delegate] respondsToSelector:@selector(playAgain)]) {
        [self.delegate playAgain];
	}
}

@end
