//
//  HelloWorldLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 22/10/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"
#import "BWGameOverLayer.h"
#import "Game.h"

@interface GameLayer : CCLayer<GameOverDelegate>
{
}

+(CCScene *) scene;

@end
