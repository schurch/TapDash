//
//  NetworkLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 05/11/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import "NetworkLayer.h"
#import "MainMenuLayer.h"

@implementation NetworkLayer

@synthesize networkManager = _networkManager;

- (void)connectionLost {    
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuLayer scene]]];  
}

- (void)dealloc {
    
}

@end
