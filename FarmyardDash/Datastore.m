//
//  HiScoreDataStore.m
//  FarmyardDash
//
//  Created by Stefan Church on 29/10/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import "Datastore.h"

static const int MAX_HI_SCORE_COUNT = 4;

@implementation Datastore

+ (Datastore *)dataStore {
    static Datastore *hiScoreDataStore;
    
    if (!hiScoreDataStore) {
        hiScoreDataStore = [[Datastore alloc] init]; 
    }
    
    return hiScoreDataStore;
}

- (id)init {
    if (self = [super init]) {
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"hi_scores.db"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        const char *dbpath = [databasePath UTF8String];
        if ([fileManager fileExistsAtPath:databasePath] == NO)
        {
            if (sqlite3_open(dbpath, &_hiScoresDb) == SQLITE_OK) {
                char *errMsg;
                const char *sql_stmt = "CREATE TABLE IF NOT EXISTS HiScores (Id INTEGER PRIMARY KEY AUTOINCREMENT, Time INTEGER);";
                
                if (sqlite3_exec(_hiScoresDb, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
            } else {
                NSLog(@"Failed to open/create database");
            }
        }else{
            sqlite3_open(dbpath, &_hiScoresDb);
        }
        
        [databasePath release];
    }
    
    return self;
}

- (void)executeSqlCommand:(NSString *)sqlCommand {
    const char *sql = [sqlCommand UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_hiScoresDb, sql, -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Succesfully executed SQL COMMAND: %@", sqlCommand);
        } else {
            NSLog(@"Failed to executed SQL COMMAND: %@", sqlCommand);
        }
    }
    
    sqlite3_finalize(statement);
}

- (int)currentHighScoreCount {
    int count = 0;
    
    const char *countSql = "SELECT COUNT(*) FROM HiScores;";
    sqlite3_stmt *countStatement;
    
    if (sqlite3_prepare_v2(_hiScoresDb, countSql, -1, &countStatement, NULL) == SQLITE_OK) {
        if (sqlite3_step(countStatement) == SQLITE_ROW) {
            count = sqlite3_column_int(countStatement, 0);
        }
    }
    
    sqlite3_finalize(countStatement);
    
    return count;
}

- (BOOL)isTimeHighScore:(double)time {
    if ([self currentHighScoreCount] < MAX_HI_SCORE_COUNT) {
        return YES;
    }
    
    double currentLowest = 0;
    
    const char *sql = "SELECT * FROM HiScores ORDER BY Time DESC LIMIT 1;";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_hiScoresDb, sql, -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            currentLowest = sqlite3_column_double(statement, 1);
        }
    }
    
    sqlite3_finalize(statement);
    
    if (time < currentLowest) {
        return YES;
    }
    
    return NO;
}

- (void)saveHighScoreTime:(double)time {
    if(![self isTimeHighScore:time]) {
        NSLog(@"Time not new high score.");
        return;
    }
    
    NSLog(@"Saving new high score..");
   
    if ([self currentHighScoreCount] >= MAX_HI_SCORE_COUNT) {
        [self executeSqlCommand:@"DELETE FROM HiScores WHERE Id = (SELECT Id FROM HiScores ORDER BY Time DESC LIMIT 1);"];
    }
    
    NSString *formatedInsertSql = [NSString stringWithFormat: @"INSERT INTO HiScores VALUES(NULL,%f)", time];
    [self executeSqlCommand:formatedInsertSql];
}

- (NSArray *)getHighScores {
    NSMutableArray *highScores = [[NSMutableArray alloc] init];
    
    const char *sql = "SELECT * FROM HiScores ORDER BY Time ASC;";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_hiScoresDb, sql, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            double time = sqlite3_column_double(statement, 1);
            [highScores addObject:[NSNumber numberWithDouble:time]];
            NSLog(@"Fetched time from database: %f", time);
        }
    }
    
    sqlite3_finalize(statement);
    
    return [highScores autorelease];
}

- (void)deleteHiScores {
    [self executeSqlCommand:@"DELETE FROM HiScores;"];
}

- (void)dealloc {
    sqlite3_close(_hiScoresDb);
    
    [super dealloc];
}

@end
