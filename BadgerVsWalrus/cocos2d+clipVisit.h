//
//  BadgerVsWalrus
//
//  Created by Stefan Church on 08/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCNode(clipVisit)

-(void)preVisitWithClippingRect:(CGRect)rect;
-(void)postVisit;

@end