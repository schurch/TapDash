//
//  ChooserLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 30/10/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NetworkManager.h"
#import "NetworkLayer.h"

@interface ChooserLayer : NetworkLayer<NetworkManagerChooserDelegate> {
    CCSprite *_cowButton;
    CCSprite *_penguinButton;
    CCSprite *_cowButtonSelectedOverlay;
    CCSprite *_penguinButtonSelectedOverLay;
    BOOL _cowChosen;
    BOOL _penguinChosen;
    Animal _chosenAnimal;
}

+ (CCScene *) scene;
+ (CCScene *)sceneWithNetwork:(BOOL)networkGame;

@end
