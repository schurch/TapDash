//
//  HiScoreDataStore.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 29/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface HiScoreDataStore : NSObject {
    sqlite3 *_hiScoresDb;
}

+ (HiScoreDataStore *)dataStore;

- (BOOL)isTimeHighScore:(double)time;
- (void)saveHighScoreTime:(double)time;
- (NSArray *)getHighScores;
- (void)deleteHiScores;

@end
