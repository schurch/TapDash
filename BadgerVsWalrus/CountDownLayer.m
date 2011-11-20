//
//  CountDownLayer.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 04/11/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import "CountdownLayer.h"


@implementation CountdownLayer

@synthesize delegate = _delegate;
@synthesize countDownImage = _countDownImage;

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
    
        [[CCTextureCache sharedTextureCache] addImage:@"3.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"2.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"1.png"];
        [[CCTextureCache sharedTextureCache] addImage:@"go.png"];
        
        CCTexture2D *threeTexture = [[CCTextureCache sharedTextureCache] textureForKey:@"3.png"];
        
        self.countDownImage = [CCSprite spriteWithTexture:threeTexture];
        self.countDownImage.position = ccp(winSize.width/2, winSize.height/2 + 20);
        [self addChild: self.countDownImage];
        
        _countdownValue = 3;
        
        [self schedule:@selector(countDownUpdate:) interval:1];
        self.isTouchEnabled = NO;
	}
    
	return self;
}

- (void)countDownUpdate:(ccTime)dt {
    _countdownValue -= 1;
    
    CCTexture2D *countdownTexture;
    switch (_countdownValue) {
        case 2:
            countdownTexture = [[CCTextureCache sharedTextureCache] textureForKey:@"2.png"];
            break;
        case 1:
            countdownTexture = [[CCTextureCache sharedTextureCache] textureForKey:@"1.png"];
            break;
        case 0:
            countdownTexture = [[CCTextureCache sharedTextureCache] textureForKey:@"go.png"];
            break;
        default:
            break;
    }

    self.countDownImage.texture = countdownTexture;
    [self.countDownImage setTextureRect:CGRectMake(0.0f, 0.0f, countdownTexture.contentSize.width, countdownTexture.contentSize.height)];
    
    if (_countdownValue == 0) {
        [self.delegate performSelector:@selector(startGame) withObject:nil afterDelay:0.5];
    }
}

- (void)dealloc {
    [_countDownImage release];
    _countDownImage = nil;
    
    [super dealloc];
}

@end
