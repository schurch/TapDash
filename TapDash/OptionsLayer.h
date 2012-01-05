//
//  OptionsLayer.h
//  TapDash
//
//  Created by Stefan Church on 29/10/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface OptionsLayer : CCLayer<UIAlertViewDelegate> {
    CCSprite *_musicSlider;
    CCSprite *_musicSliderBackdrop;
    int _musicMinX;
    int _musicMaxX;
}

@property (nonatomic, retain) CCSprite *musicSlider;
@property (nonatomic, retain) CCSprite *musicSliderBackdrop;

+(CCScene *) scene;

@end
