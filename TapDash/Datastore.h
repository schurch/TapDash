//
//  HiScoreDataStore.h
//  TapDash
//
//  Created by Stefan Church on 29/10/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Datastore : NSObject {
    sqlite3 *_hiScoresDb;
}

+ (Datastore *)dataStore;

- (BOOL)isTimeHighScore:(double)time;
- (void)saveHighScoreTime:(double)time;
- (NSArray *)getHighScores;
- (void)deleteHiScores;

@end
