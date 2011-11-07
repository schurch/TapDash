//
//  NetworkManager.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkManager.h"

union intToFloat
{
    uint32_t i;
    float fp;
};

typedef enum {
    kPacketTypeChooseAnimal,
    kPacketTypeStartGame,
    kPacketTypeWon,
    kPacketTypePlayAgain,
    kPacketTypeGameHeartbeat,
    kPacketTypeNetworkPing,
    kPacketTypeCoinToss
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
        
        switch (header) {
            case kPacketTypeChooseAnimal:
                animal = (Animal)[self convertNetworkDataToInt:payload];
                if (self.peerType == kServer) {
                    if (_multiplayerGameState -> serverAnimal == animal) {
                        //reject
                    } else {
                        _multiplayerGameState -> clientAnimal = animal;
                    }
                } else {
                    if([self.chooserDelegate respondsToSelector:@selector(otherPlayerChoseAnimal:)]) {
                        [self.chooserDelegate otherPlayerChoseAnimal:animal];
                    }
                }
                break;
            case kPacketTypeStartGame:
                if([self.chooserDelegate respondsToSelector:@selector(otherPlayerStartedGame)]) {
                    [self.chooserDelegate otherPlayerStartedGame];
                }
                break;
            case kPacketTypeWon:
                if (self.peerType == kServer) {
                    if (_multiplayerGameState -> serverWon) {
                        //reject
                    } else {
                        _multiplayerGameState -> clientWon = YES;
                    }
                } else {
                    if([self.gameDelegate respondsToSelector:@selector(otherPlayerWon)]) {
                        [self.gameDelegate otherPlayerWon];
                    }
                }
                break;
            case kPacketTypePlayAgain:
                if([self.gameOverDelegate respondsToSelector:@selector(otherPlayerPlayedAgain)]) {
                    [self.gameOverDelegate otherPlayerPlayedAgain];
                }
                break;
            case kPacketTypeGameHeartbeat:
                xPosition = [self convertNetworkDataToInt:payload];
                time = [self convertNetworkDataToFloat:payload];
                if([self.gameDelegate respondsToSelector:@selector(heartbeatWithOtherPlayerXPosition: time:)]) {
                    [self.gameDelegate heartbeatWithOtherPlayerXPosition:xPosition time:time];
                }
                break;
            case kPacketTypeCoinToss:
                otherPlayerCoinTossRoll = [self convertNetworkDataToInt:payload];
                self.peerType = _coinTossRoll > otherPlayerCoinTossRoll ? kServer : kClient; //server is god
                break;
            case kPacketTypeNetworkPing:
                self.lastPing = [NSDate date];
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
    self.gameSession.delegate = self;
    [self.gameSession setDataReceiveHandler:self withContext:nil];

    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
    
    [self sendDataToPeers:[self convertIntToNetworkData:_coinTossRoll] ofType:kPacketTypeCoinToss];
    
    self.lastPing = [NSDate date];
    self.pingTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    GKSession *session = [[GKSession alloc] initWithSessionID:@"BadgerVsWalrus" displayName:nil sessionMode:GKSessionModePeer];
    return [session autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {   
    picker.delegate = nil;
    [picker autorelease];
    
    if([self.chooserDelegate respondsToSelector:@selector(pickerCanceled)]) {
        [self.chooserDelegate pickerCanceled];
    }
}

#pragma mark -
#pragma mark methods

- (void)ping {
    if ([self.lastPing timeIntervalSinceNow] > kPingTimeMaxDelay) {
        [self invalidateSession];
    } else {
        [self sendDataToPeers:nil ofType:kPacketTypeNetworkPing];
    }
}

- (void)chooseAnimal:(Animal)animal {
    if (self.peerType == kServer) {
        _multiplayerGameState -> serverAnimal = animal;
    }
    [self sendDataToPeers:[self convertIntToNetworkData:animal] ofType:kPacketTypeChooseAnimal];
}

- (void)startGame {
    [self sendDataToPeers:nil ofType:kPacketTypeStartGame];
}

- (void)heartbeatWithXPostion:(int)postion time:(float)time {
    NSData *postionData = [self convertIntToNetworkData:postion];
    NSData *timeData = [self convertFloatToNetworkData:time];
    
    NSMutableData *dataToSend = [NSMutableData dataWithCapacity:([postionData length] + [timeData length])];
    [dataToSend appendData:postionData];
    [dataToSend appendData:timeData];
    
    if (self.peerType == kServer) {
        _multiplayerGameState -> serverXPosition = postion;
        _multiplayerGameState -> serverTime = time;
    }
    
    [self sendDataToPeers:dataToSend ofType:kPacketTypeGameHeartbeat];
}

- (void)wonWithXPosition:(int)postion time:(float)time {
    if (self.peerType == kServer) {
        _multiplayerGameState -> serverWon = YES;
        _multiplayerGameState -> serverXPosition = postion;
        _multiplayerGameState -> serverTime = time;
    }
    
    [self sendDataToPeers:nil ofType:kPacketTypeWon];
}

- (void)invalidateSession {
    NSLog(@"Lost network connection.");
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Network Problem." message:@"There was an error with the network and the connection has been lost." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
    
    if([self.chooserDelegate respondsToSelector:@selector(connectionLost)]) {
        [self.chooserDelegate connectionLost];
    }
    
    if([self.gameDelegate respondsToSelector:@selector(connectionLost)]) {
        [self.gameDelegate connectionLost];
    }
    
    if([self.gameOverDelegate respondsToSelector:@selector(connectionLost)]) {
        [self.gameOverDelegate connectionLost];
    }
    
    [self.gameSession disconnectFromAllPeers];    
    [self.gameSession setDataReceiveHandler:nil withContext:nil];
    self.gameSession.available = NO;
    
    [self resetGameState];
    
    self.chooserDelegate = nil;
    self.gameDelegate = nil;
    self.gameOverDelegate = nil;    
}

- (void)playAgain {
    [self sendDataToPeers:nil ofType:kPacketTypePlayAgain];
}

#pragma mark -
#pragma mark cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.gameSession) {
        [self invalidateSession];
    }
    
    [_gameSession release];
    _chooserDelegate = nil;
    _gameDelegate = nil;
    
    free(_multiplayerGameState);    
    
    [super dealloc];
}

@end
