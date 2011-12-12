//
//  Viewport.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 08/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CCNode.h"
#import "cocos2d+clipVisit.h"

@interface Viewport : CCNode {
	// the clipping rectangle
	CGRect rect;
}

@property (assign) CGRect rect;

+ (Viewport*) viewportWithRect:(CGRect)rect;
- (id) initWithRect:(CGRect)rect;

@end
