//
//  OptionsLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 29/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface OptionsLayer : CCLayer {
    CCSprite *_musicSlider;
    CCSprite *_musicSliderBackdrop;
}

+(CCScene *) scene;

@end
