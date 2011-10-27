//
//  BWGameOverLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 23/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Game.h"

@interface GameOverLayer : CCLayer {
    id _delegate;
    CCLabelTTF *_gameOverLabel;
}

@property (assign, nonatomic) id delegate;

+(CCScene *) scene;

- (void)setupLayerWithGameOutcome:(GameOutcome)gameOutcome;

@end

@protocol GameOverDelegate <NSObject>
- (void)playAgain;
@end
