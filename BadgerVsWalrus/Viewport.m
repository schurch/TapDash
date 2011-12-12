//
//  Viewport.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 08/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Viewport.h"

@implementation Viewport

@synthesize rect;

- (void)visit {
//    glEnable(GL_SCISSOR_TEST);
//    glScissor(13, 0, 118, 320);   
//    [super visit];
//    glDisable(GL_SCISSOR_TEST);
    
    if (!self.visible)
		return;
    
	glPushMatrix();
    
	glEnable(GL_SCISSOR_TEST);
    
	// convert from node space to world space
	CGPoint bottomLeft = [self convertToWorldSpace:self.position];
	CGPoint topRight = ccpAdd(self.position, ccp(self.contentSize.width, self.contentSize.height));
	topRight = [self convertToWorldSpace:topRight];
    
	// calculate scissor rect in world space
	CGSize size = [[CCDirector sharedDirector] winSize];
	CGRect scissorRect = CGRectMake(bottomLeft.x, bottomLeft.y, topRight.x-bottomLeft.x, topRight.y-bottomLeft.y);
    
	// transform the clipping rectangle to adjust to the current screen
	// orientation: the rectangle that has to be passed into glScissor is
	// always based on the coordinate system as if the device was held with the
	// home button at the bottom. the transformations account for different
	// device orientations and adjust the clipping rectangle to what the user
	// expects to happen.
	ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation];
	switch (orientation) {
		case kCCDeviceOrientationPortrait:
			break;
		case kCCDeviceOrientationPortraitUpsideDown:
			scissorRect.origin.x = size.width-scissorRect.size.width-scissorRect.origin.x;
			scissorRect.origin.y = size.height-scissorRect.size.height-scissorRect.origin.y;
			break;
		case kCCDeviceOrientationLandscapeLeft:
		{
			float tmp = scissorRect.origin.x;
			scissorRect.origin.x = scissorRect.origin.y;
			scissorRect.origin.y = size.width-scissorRect.size.width-tmp;
			tmp = scissorRect.size.width;
			scissorRect.size.width = scissorRect.size.height;
			scissorRect.size.height = tmp;
		}
			break;
		case kCCDeviceOrientationLandscapeRight:
		{
			float tmp = scissorRect.origin.y;
			scissorRect.origin.y = scissorRect.origin.x;
			scissorRect.origin.x = size.height-scissorRect.size.height-tmp;
			tmp = scissorRect.size.width;
			scissorRect.size.width = scissorRect.size.height;
			scissorRect.size.height = tmp;
		}
			break;
	}
    
	glScissor(scissorRect.origin.x, scissorRect.origin.y,
			  scissorRect.size.width, scissorRect.size.height);
    
	[super visit];
    
	glDisable(GL_SCISSOR_TEST);
	glPopMatrix();
}

+ (Viewport*) viewportWithRect:(CGRect)rect {
	return [[[self alloc] initWithRect:rect] autorelease];
}

- (id) initWithRect:(CGRect)r {
	if ((self = [super init])) {
		self.position = r.origin;
		self.contentSize = r.size;
	}
    
	return self;
}

@end
