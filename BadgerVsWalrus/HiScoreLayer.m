//
//  HiScoreLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 27/10/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HiScoreLayer.h"


@implementation HiScoreLayer

+(CCScene *) scene
{
	static CCScene *scene;
    
    if(!scene){
        scene = [CCScene node];
        HiScoreLayer *layer = [HiScoreLayer node];
        [scene addChild: layer];
    }
    
	return scene;
}

@end
