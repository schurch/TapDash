//
//  NetworkManager.m
//  FarmyardDash
//
//  Created by Stefan Church on 02/11/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

#import "NetworkManager.h"

typedef enum {
    kPacketTypeChooseAnimal,
    kPacketTypeStartGame,
    kPacketTypeWon,
    kPacketTypePlayAgain,
    kPacketTypeGameHeartbeat,
    kPacketTypeNetworkPing,
    kPacketTypeCoinToss,
    kPacketTypeAnimalChoiceRejectedOrAccepted,
    kPackTypeWinDetails
} PacketType; 

const float kPingTimeMaxDelay = 5.0f;

@implementation NetworkManager

#pragma mark properties

@synthesize chooserDelegate = _chooserDelegate;
@synthesize gameDelegate = _gameDelegate;
@synthesize gameSession = _gameSession;
@synthesize gameOverDelegate = _gameOverDelegate;
@synthesize peerType = _peerType;
@synthesize lastPing = _lastPing;
@synthesize pingTimer = _pingTimer;


#pragma mark -
#pragma mark class methods

+ (NetworkManager *)manger {
    static NetworkManager *manager;
    
    if (!manager) {
        manager = [[NetworkManager alloc] init];
    }
    
    return manager;
}

#pragma mark -
#pragma mark init

- (id)init {
    if (self = [super init]) {
        _coinTossRoll = [[[UIDevice currentDevice] uniqueIdentifier] hash];
        self.lastPing = nil;
        _multiplayerGameState = malloc(sizeof(MultiPlayerGameState));
    }
    
    return self;
}

- (void)initNetworkGame {
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [picker show];
}

#pragma mark -
#pragma mark helper methods

- (void)resetGameState {
    _multiplayerGameState -> clientTime = 0.0f;
    _multiplayerGameState -> serverTime = 0.0f;
    _multiplayerGameState -> clientXPosition = 0;
    _multiplayerGameState -> serverXPosition = 0;
    _multiplayerGameState -> clientAnimal = kAnimalNone;
    _multiplayerGameState -> serverAnimal = kAnimalNone;
    _multiplayerGameState -> clientWon = NO;
    _multiplayerGameState -> serverWon = NO;
}

#pragma mark -
#pragma mark data conversion

- (NSData *)convertIntToNetworkData:(int)intValue {
    uint32_t networkInt = CFSwapInt32HostToBig((uint32_t)intValue);
    NSData *data = [NSData dataWithBytes:&networkInt length:sizeof(uint32_t)];
    return data;
}

- (int)convertNetworkDataToInt:(NSData *)dataValue {
    int intValue;
    [dataValue getBytes:&intValue length:sizeof(uint32_t)];
    return CFSwapInt32BigToHost(intValue);
}

- (NSData *)convertFloatToNetworkData:(float)floatValue {
    NSData *data = [NSData dataWithBytes:&floatValue length:sizeof(float)];
    return data;
}

- (float)convertNetworkDataToFloat:(NSData *)dataValue {
    float floatValue;
    [dataValue getBytes:&floatValue length:sizeof(float)];
    return floatValue;
}

- (NSData *)convertIntAndFloatToData:(int)intValue floatValue:(float)floatValue {
    NSData *intData = [self convertIntToNetworkData:intValue];
    NSData *floatData = [self convertFloatToNetworkData:floatValue];
    
    NSMutableData *data = [NSMutableData dataWithCapacity:([intData length] + [floatData length])];
    [data appendData:intData];
    [data appendData:floatData];
    
    return data;
}

- (void)convertNetworkDataToIntFloat:(NSData *)data intValue:(int *)intValue floatValue:(float *)floatValue {
    int networkInt;
    NSRange intRange = { 0, sizeof(uint32_t) };
    [data getBytes:&networkInt range:intRange];
    *intValue = CFSwapInt32BigToHost(networkInt);
    
    NSRange floatRange = { sizeof(uint32_t), sizeof(float) };
    [data getBytes:floatValue range:floatRange];
}

#pragma mark -
#pragma mark GKSessionDelegate

- (void)sendDataToPeers:(NSData *)data ofType:(PacketType)type {
    NSMutableData *newPacket = [NSMutableData dataWithCapacity:([data length]+sizeof(uint32_t))];
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
    
    NSError *error;
    if (![self.gameSession sendDataToAllPeers:newPacket withDataMode:GKSendDataUnreliable error:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    PacketType header;
    uint32_t swappedHeader;
    if ([data length] >= sizeof(uint32_t)) {    
        [data getBytes:&swappedHeader length:sizeof(uint32_t)];
        header = (PacketType)CFSwapInt32BigToHost(swappedHeader);
        NSRange payloadRange = {sizeof(uint32_t), [data length]-sizeof(uint32_t)};
        NSData* payload = [data subdataWithRange:payloadRange];
        
        Animal animal;
        int xPosition;
        float time;
        int otherPlayerCoinTossRoll;
        BOOL choiceAccepted;
        
        switch (header) {
            case kPacketTypeChooseAnimal:
                animal = (Animal)[self convertNetworkDataToInt:payload];
                if (self.peerType == kServer) {
                    int rejectedOrAccepted;
                    if (_multiplayerGameState -> serverAnimal == animal) {
                        rejectedOrAccepted = 0;
                        NSLog(@"Server rejected animal selection.");
                    } else {
                        _multiplayerGameState -> clientAnimal = animal;
                        rejectedOrAccepted = 1;
                        NSLog(@"Server accepted animal selection.");
                    }
                    NSData *rejectedOrAcceptedData = [self convertIntToNetworkData:rejectedOrAccepted];
                    [self sendDataToPeers:rejectedOrAcceptedData ofType:kPacketTypeAnimalChoiceRejectedOrAccepted];
                    
                    //1 = accepted
                    //server accepted so update chooser delegate
                    if (rejectedOrAccepted == 1) {
                        NSLog(@"Server: other player chose animal.");
                        [self.chooserDelegate otherPlayerChoseAnimal:animal];
                    }
                } else {
                    //on client, server can choose whatever animal it wants so just accept
                    NSLog(@"Client: other player chose animal.");
                    [self.chooserDelegate otherPlayerChoseAnimal:animal];
                }
                break;
            case kPacketTypeStartGame:
                [self.chooserDelegate otherPlayerStartedGame];
                break;
            case kPacketTypeWon:
                NSLog(@"Received win message from other device.");
                if (self.peerType == kServer) {
                    [self convertNetworkDataToIntFloat:payload intValue:&xPosition floatValue:&time];
                    
                    if (!(_multiplayerGameState -> serverWon)) { //if server won already, client is out of luck
                        _multiplayerGameState -> clientWon = YES;
                        NSLog(@"Client won.");
                    }
                    
                    _multiplayerGameState -> clientXPosition = xPosition;
                    _multiplayerGameState -> clientTime = time;
                    
                    Animal winningAnimal;
                    float winningTime;
                    
                    if (_multiplayerGameState -> serverWon) {
                        winningTime = _multiplayerGameState -> serverTime;
                        winningAnimal = _multiplayerGameState -> serverAnimal;
                    } else {
                        winningTime = _multiplayerGameState -> clientTime;
                        winningAnimal = _multiplayerGameState -> clientAnimal;
                    }
                    
                    NSData *winDetailsData = [self convertIntAndFloatToData:winningAnimal floatValue:winningTime];
                    [self sendDataToPeers:winDetailsData ofType:kPackTypeWinDetails];
                    [self.gameDelegate winningDetails:winningAnimal time:winningTime];
                }
                break;
            case kPacketTypePlayAgain:
                NSLog(@"Received request to play again.");
                if (self.peerType == kServer) {
                    [self resetGameState];
                }
                [self.gameOverDelegate otherPlayerPlayedAgain];
                break;
            case kPacketTypeGameHeartbeat:
                [self convertNetworkDataToIntFloat:payload intValue:&xPosition floatValue:&time];
                if (self.peerType == kServer) {
                    _multiplayerGameState -> clientXPosition = xPosition;
                    _multiplayerGameState -> clientTime = time;
                }
                [self.gameDelegate heartbeatWithOtherPlayerXPosition:xPosition];
                break;
            case kPacketTypeCoinToss:
                otherPlayerCoinTossRoll = [self convertNetworkDataToInt:payload];
                self.peerType = _coinTossRoll > otherPlayerCoinTossRoll ? kServer : kClient; //server is god, sorry client
                NSLog(@"Network cointoss. Device is %@.", self.peerType == kServer ? @"Server" : @"Client");
                if (self.peerType == kServer) {
                    [self resetGameState];
                }
                break;
            case kPacketTypeNetworkPing:
                self.lastPing = [NSDate date];
                break;
            case kPacketTypeAnimalChoiceRejectedOrAccepted:
                choiceAccepted = [self convertNetworkDataToInt:payload] == 1 ? YES : NO; 
                NSLog(@"Animal choice was %@.", choiceAccepted ? @"Accepted" : @"Rejected");
                [self.chooserDelegate  choiceRejectedOrAccepted:choiceAccepted];
                break;
            case kPackTypeWinDetails:
                //received the winning details from the server
                [self convertNetworkDataToIntFloat:payload intValue:(int *)&animal floatValue:&time];
                [self.gameDelegate winningDetails:animal time:time];
                break;
            default:
                NSLog(@"Unrecognized packet type.");
                break;
        }
    }   
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateConnecting:
            NSLog(@"%@ peer Connecting.", peerID);
            break;
        case GKPeerStateConnected:
            NSLog(@"%@ peer Connected.", peerID);
            break;
        case GKPeerStateDisconnected:
            NSLog(@"%@ peer Disconnected.", peerID);
            [self invalidateSession];
            break;
        case GKPeerStateAvailable:
            NSLog(@"%@ peer State Available.", peerID);
            break;
        case GKPeerStateUnavailable:
            NSLog(@"%@ peer State Unavailable.", peerID);
            break;
    }
}

#pragma mark -
#pragma mark GKPeerPickerControllerDelegate

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    self.gameSession = session;
    _sessionInvalidated = NO;
    self.gameSession.delegate = self;
    [self.gameSession setDataReceiveHandler:self withContext:nil];

    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
    
    [self sendDataToPeers:[self convertIntToNetworkData:_coinTossRoll] ofType:kPacketTypeCoinToss];
    
    self.lastPing = [NSDate date];
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(ping) userInfo:nil repeats:YES];
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    GKSession *session = [[GKSession alloc] initWithSessionID:@"FarmyardDash" displayName:@"FarmyardDash" sessionMode:GKSessionModePeer];
    return [session autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {   
    picker.delegate = nil;
    [picker autorelease];
    [self.chooserDelegate pickerCanceled];
}

#pragma mark -
#pragma mark methods

- (void)ping {
    float timeSinceLastPing = fabsf([self.lastPing timeIntervalSinceNow]);
    if (timeSinceLastPing > kPingTimeMaxDelay) {
        NSLog(@"Ping timer elapsed. Closing connection..");
        [self.pingTimer invalidate];
        self.pingTimer = nil;
        [self invalidateSession];
    } else {
        [self sendDataToPeers:nil ofType:kPacketTypeNetworkPing];
    }
}

- (void)chooseAnimal:(Animal)animal {
    if (self.peerType == kServer) {
        _multiplayerGameState -> serverAnimal = animal;
        [self.chooserDelegate choiceRejectedOrAccepted:YES];
    }
    
    [self sendDataToPeers:[self convertIntToNetworkData:animal] ofType:kPacketTypeChooseAnimal];
}

- (void)startGame {
    [self sendDataToPeers:nil ofType:kPacketTypeStartGame];
}

- (void)heartbeatWithXPostion:(int)postion time:(float)time {
   if (self.peerType == kServer) {
        _multiplayerGameState -> serverXPosition = postion;
        _multiplayerGameState -> serverTime = time;
    }
   
    NSData *dataToSend = [self convertIntAndFloatToData:postion floatValue:time];
    [self sendDataToPeers:dataToSend ofType:kPacketTypeGameHeartbeat];
}

- (void)wonWithXPosition:(int)postion time:(float)time {
    if (self.peerType == kServer) {
        _multiplayerGameState -> serverWon = YES;
        _multiplayerGameState -> serverXPosition = postion;
        _multiplayerGameState -> serverTime = time;
        
        Animal winningAnimal = _multiplayerGameState -> serverAnimal;
        float winningTime = _multiplayerGameState -> serverTime;
        
        NSData *winDetailsData = [self convertIntAndFloatToData:winningAnimal floatValue:winningTime];
        [self sendDataToPeers:winDetailsData ofType:kPackTypeWinDetails];
        [self.gameDelegate winningDetails:winningAnimal time:winningTime];
     } else {
        NSLog(@"Sending won message from client.");
        NSData *dataToSend = [self convertIntAndFloatToData:postion floatValue:time];
        [self sendDataToPeers:dataToSend ofType:kPacketTypeWon];
     }
}

- (void)invalidateSession {
    //don't invalidate more than once
    if (_sessionInvalidated) {
        return;
    } 
    _sessionInvalidated = YES;
    
    NSLog(@"Lost network connection.");
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Network Problem." message:@"There was an error with the network and the connection has been lost." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
    
    //let delegates know the conneciton has been lost
    [self.chooserDelegate connectionLost];
    [self.gameDelegate connectionLost];
    [self.gameOverDelegate connectionLost];
    
    //cleanup session
    [self.gameSession disconnectFromAllPeers];    
    [self.gameSession setDataReceiveHandler:nil withContext:nil];
    self.gameSession.available = NO;
    
    //reset server game state tracker
    [self resetGameState];
    
    //cleanup delegates
    self.chooserDelegate = nil;
    self.gameDelegate = nil;
    self.gameOverDelegate = nil;    
}

- (void)playAgain {
    if (self.peerType == kServer) {
        [self resetGameState];   
    }
    [self sendDataToPeers:nil ofType:kPacketTypePlayAgain];
}

#pragma mark -
#pragma mark cleanup

- (void)dealloc {    
    if (self.gameSession) {
        [self invalidateSession];
    }
    
    [_gameSession release];
    [_lastPing release];
    [_pingTimer release];
    
    free(_multiplayerGameState);    
    
    [super dealloc];
}

@end
