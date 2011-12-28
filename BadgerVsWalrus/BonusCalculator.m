//
//  ComputerBonusCalculator.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 22/12/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import "BonusCalculator.h"

@implementation BonusCalculator

@synthesize movementBonus = _aiMovementBonus;

- (id)init {
    if (self = [super init]) {
        _aiMovementBonus = 1;
        _timeOfLastBonus = 0;
        _bonusRun = NO;
        _bonusNumber = 0;
        _startedPlayerAheadBonus = NO;
        _randomBonusStartTime = arc4random_uniform(10) + 5;
    }
    
    return self;
}

- (int)generateRandomBonus {
    return arc4random_uniform(6) + 2;
}

- (void)calculateMovementBonus:(float)gameTime playerXPostion:(int)playerXPostion computerXPostion:(int)computerXPostion {
    float timeDifference = gameTime - _timeOfLastBonus;
    
    //don't bother calculating bonus if it's been less then a second or the game has only been running for 2 secs
    if ((timeDifference < 0.5) || (gameTime < 2)) {
        return;
    }
    
    _timeOfLastBonus = gameTime;
    NSLog(@"Calculate AI movement bonus..");
    
    int pixelDifferenceBetweenPlayers = playerXPostion - computerXPostion;
    
    //computer is infront by too much so don't add bonus
    if (pixelDifferenceBetweenPlayers < -20) {
        NSLog(@"Remove movement bonus.");
        _aiMovementBonus = 1;
    } else if (pixelDifferenceBetweenPlayers > 50) {  //if other player more than x pixels ahead, start random winnning bonus
        if (!_startedPlayerAheadBonus) {
            _bonusNumber = [self generateRandomBonus];
            _aiMovementBonus = _aiMovementBonus + 1;
            _startedPlayerAheadBonus = YES;
            NSLog(@"Started play ahead bonus.");
        } else {
            if (_aiMovementBonus < _bonusNumber) {
                _aiMovementBonus = _aiMovementBonus + 1;
                NSLog(@"Incremented AI movement bonus to %i of %i.", _aiMovementBonus, _bonusNumber);
            } else if (_aiMovementBonus == _bonusNumber) {
                _aiMovementBonus = 1;
                _startedPlayerAheadBonus = NO;
                _bonusNumber = 1;
                NSLog(@"Right, that's enough AI movement bonus. Time to SLOW down.");
            }
        }
    } else {    
        if (!_bonusRun && gameTime > _randomBonusStartTime) {
            _bonusNumber = [self generateRandomBonus];
            _aiMovementBonus = _aiMovementBonus + 1;
            _bonusRun = YES;
            NSLog(@"Started random bonus up to %i.", _bonusNumber);
        } else {
            if (_aiMovementBonus < _bonusNumber) {
                _aiMovementBonus = _aiMovementBonus + 1;
                NSLog(@"Increased AI bonus to %i.", _aiMovementBonus);
            } else {
                _aiMovementBonus = 1;
                NSLog(@"No bonus.");
            }
        }   
    }
}

@end
