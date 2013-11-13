//
//  RKPeripheralManager.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 10/30/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKBlueBlocks.h"
@interface RKPeripheralManager : NSObject
@property(nonatomic, readonly) BOOL isAdvertising;
@property(nonatomic, readonly) CBPeripheralManagerState state;
@property (nonatomic,copy)RKObjectChangedBlock onStatedUpdated;
@property (nonatomic,copy)RKPeripheralManagerStatedChnagedBlock onWillRestoreState;
@property (nonatomic,copy)RKCentralSubscriptionBlock onSubscribedBlock;
@property (nonatomic,copy)RKCentralSubscriptionBlock onUnsubscribedBlock;
@property (nonatomic,copy)RKCentralReadRequestBlock onReceivedReadRequest;
@property (nonatomic,copy)RKCentralWriteRequestBlock onReceivedWriteRequest;
@property (nonatomic,copy)RKObjectChangedBlock onReadToUpdateSubscribers;

@property (nonatomic,strong)NSArray * services;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;
- (instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options NS_AVAILABLE(NA, 7_0);

#pragma mark Adding and Removing Services
- (void)addService:(CBMutableService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) onfinish;
- (void)removeService:(CBMutableService *)service;
- (void)removeAllServices;

#pragma mark Managing Advertising

- (void)startAdvertising:(NSDictionary *)advertisementData onStarted:(RKObjectChangedBlock) onstarted;
- (void)stopAdvertising;

#pragma mark Sending Updates of a Characteristic’s Value

- (BOOL)updateValue:(NSData *)value forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:(NSArray *)centrals;
#pragma mark Responding to Read and Write Requests

- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result;

#pragma mark Setting Connection Latency

- (void)setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatency)latency forCentral:(CBCentral *)central;
@end
