//
//  ChooserLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 30/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NetworkManager.h"

@interface ChooserLayer : CCLayer<NetworkManagerChooserDelegate> {
    CCSprite *_cowButton;
    CCSprite *_penguinButton;
    NetworkManager *_networkManager;
}

@property (nonatomic, retain) NetworkManager *networkManager;

+ (CCScene *) scene;
+ (CCScene *)sceneWithNetwork:(BOOL)networkGame;

@end
