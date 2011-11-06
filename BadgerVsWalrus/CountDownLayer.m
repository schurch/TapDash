//
//  CountDownLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 04/11/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CountdownLayer.h"


@implementation CountdownLayer

@synthesize delegate = _delegate;

+ (CCScene *)scene
{
    CCScene *scene = [CCScene node];
    CountdownLayer *layer = [CountdownLayer node];
    [scene addChild: layer];
    
	return scene;
}

- (id)init
{
	if ((self=[super init])) {      
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        _countdownValue = INITIAL_COUNTDOWN_VALUE;
        
        NSString *initalCountdownString = [NSString stringWithFormat:@"%i", _countdownValue];
        _countDownLabel = [CCLabelTTF labelWithString:initalCountdownString fontName:@"MarkerFelt-Wide" fontSize:70];
        _countDownLabel.position = ccp(winSize.width/2, winSize.height/2 + 20);
        _countDownLabel.color = ccc3(0, 0, 0);
        
        [self addChild: _countDownLabel];
        [self schedule:@selector(countDownUpdate:) interval:1];
        
        self.isTouchEnabled = NO;
	}
    
	return self;
}

- (void)countDownUpdate:(ccTime)dt {
    _countdownValue -= 1;
    
    NSString *currentCountdownString;
    if (_countdownValue == 0) {
        currentCountdownString = [NSString stringWithString:@"GO!"];
    } else {
        currentCountdownString = [NSString stringWithFormat:@"%i", _countdownValue];
    }
    _countDownLabel.string = currentCountdownString;
    
    if (_countdownValue == 0) {
        if([self.delegate respondsToSelector:@selector(startGame)]) {
            [self.delegate performSelector:@selector(startGame) withObject:nil afterDelay:0.5];
        }
    }
}

- (void)dealloc {
    _delegate = nil;
    [_countDownLabel release];
    _countDownLabel = nil;
}

@end
