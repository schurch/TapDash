//
//  ComputerBonusCalculator.h
//  FarmyardDash
//
//  Created by Stefan Church on 22/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BonusCalculator : NSObject {
    int _aiMovementBonus;
    float _timeOfLastBonus;
    BOOL _bonusRun;
    int _bonusNumber;
    BOOL _startedPlayerAheadBonus;
    int _randomBonusStartTime;
}

@property (readonly) int movementBonus;

- (void)calculateMovementBonus:(float)gameTime playerXPostion:(int)playerXPostion computerXPostion:(int)computerXPostion;

@end
