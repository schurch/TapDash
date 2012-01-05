//
//  NetworkManager.h
//  TapDash
//
//  Created by Stefan Church on 02/11/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GKPeerPickerController.h>
#import "Game.h"

typedef enum {
    kClient,
    kServer
} PeerType;

typedef struct {
    int clientXPosition;
    int serverXPosition;
    float clientTime;
    float serverTime;
    Animal clientAnimal;
    Animal serverAnimal;
    BOOL clientWon;
    BOOL serverWon;
} MultiPlayerGameState;

@protocol NetworkManagerDelegate <NSObject>
- (void)connectionLost;
@end

@protocol NetworkManagerChooserDelegate <NetworkManagerDelegate>
- (void)otherPlayerChoseAnimal:(Animal)animal;
- (void)choiceRejectedOrAccepted:(BOOL)accepted;
- (void)pickerCanceled;
- (void)otherPlayerStartedGame;
@end

@protocol NetworkManagerGameDelegate <NetworkManagerDelegate>
- (void)heartbeatWithOtherPlayerXPosition:(int)xPostion;
- (void)winningDetails:(Animal)animal time:(float)time;
@end

@protocol NetworkManagerGameOverDelegate <NetworkManagerDelegate>
- (void)otherPlayerPlayedAgain;
@end

@interface NetworkManager : NSObject<GKPeerPickerControllerDelegate, GKSessionDelegate> {
    id _chooserDelegate;
    id _gameDelegate;
    id _gameOverDelegate;
    GKSession *_gameSession;
    PeerType _peerType;
    int _coinTossRoll;
    NSDate *_lastPing;
    NSTimer *_pingTimer;
    MultiPlayerGameState *_multiplayerGameState; //one peer is chosen as server to keep track of game state
    BOOL _sessionInvalidated;
}

@property (nonatomic, assign) id<NetworkManagerChooserDelegate> chooserDelegate;
@property (nonatomic, assign) id<NetworkManagerGameDelegate> gameDelegate;
@property (nonatomic, assign) id<NetworkManagerGameOverDelegate> gameOverDelegate;
@property (nonatomic, retain) GKSession *gameSession;
@property (nonatomic) PeerType peerType;
@property (nonatomic, retain) NSDate *lastPing;
@property (nonatomic, retain) NSTimer *pingTimer;

+ (NetworkManager *)manger;

- (void)initNetworkGame;
- (void)ping;
- (void)chooseAnimal:(Animal)animal;
- (void)startGame;
- (void)heartbeatWithXPostion:(int)postion time:(float)time;
- (void)wonWithXPosition:(int)postion time:(float)time;
- (void)playAgain;
- (void)invalidateSession;
@end
