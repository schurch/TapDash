//
//  ChooserLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 30/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ChooserLayer : CCLayer {
    CCSprite *_cowButton;
    CCSprite *_penguinButton;
}

+(CCScene *) scene;

@end
