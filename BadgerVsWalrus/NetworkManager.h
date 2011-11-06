//
//  NetworkManager.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GKPeerPickerController.h>
#import "Game.h"

@protocol NetworkManagerDelegate <NSObject>
- (void)connectionLost;
@end

@protocol NetworkManagerChooserDelegate <NetworkManagerDelegate>
- (void)otherPlayerChoseAnimal:(Animal)animal;
- (void)pickerCanceled;
- (void)otherPlayerStartedGame;
@end

@protocol NetworkManagerGameDelegate <NetworkManagerDelegate>
- (void)heartbeatWithOtherPlayerXPosition:(int)xPostion;
- (void)otherPlayerWon;
@end

@protocol NetworkManagerGameOverDelegate <NetworkManagerDelegate>
- (void)otherPlayerPlayedAgain;
@end

@interface NetworkManager : NSObject<GKPeerPickerControllerDelegate, GKSessionDelegate> {
    id _chooserDelegate;
    id _gameDelegate;
    GKSession *_gameSession;
}

@property (nonatomic, assign) id<NetworkManagerChooserDelegate> chooserDelegate;
@property (nonatomic, assign) id<NetworkManagerGameDelegate> gameDelegate;
@property (nonatomic, assign) id<NetworkManagerGameOverDelegate> gameOverDelegate;
@property (nonatomic, retain) GKSession *gameSession;

+ (NetworkManager *)manger;

- (void)initNetworkGame;
- (void)chooseAnimal:(Animal)animal;
- (void)startGame;
- (void)heartbeatWithXPostion:(int)postion;
- (void)won;
- (void)playAgain;
- (void)invalidateSession;
@end
