//
//  RKPeripheralManager.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 10/30/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "RKPeripheralManager.h"


@interface RKPeripheralManager()<CBPeripheralManagerDelegate>
@property (nonatomic,strong) CBPeripheralManager * peripheralManager;
@property (nonatomic,strong) NSMutableDictionary * serviceAddingBlocks;
@property (nonatomic,copy) RKObjectChangedBlock advertisingStartedBlock;
@property (nonatomic,strong) NSMutableArray * addedServices;
@property (nonatomic,strong) NSDictionary * initializedOptions;
@property (nonatomic,strong) dispatch_queue_t queue;
@property(nonatomic,assign) BOOL isAdvertising;
@property(nonatomic,assign) CBPeripheralManagerState state;
@end
#pragma mark - implementation
@implementation RKPeripheralManager
- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:queue options:nil];
    }
    return self;
}
- (instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:queue options:options];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:nil options:nil];
    }
    return self;
}
- (void)initializeWithQueue:(dispatch_queue_t) queue options:(NSDictionary *)options
{
    self.queue = queue;
    self.initializedOptions = options;
    //blocks for adding services
    self.serviceAddingBlocks = [NSMutableDictionary dictionaryWithCapacity:5];
    self.addedServices = [NSMutableArray arrayWithCapacity:10];
}
- (CBPeripheralManager *)peripheralManager
{
    @synchronized(_peripheralManager)
    {
        if (!_peripheralManager)
        {
            if ([CBPeripheralManager instancesRespondToSelector:@selector(initWithDelegate:queue:options:)])
            {
                _peripheralManager= [[CBPeripheralManager alloc] initWithDelegate:self queue:self.queue options:self.initializedOptions];
            }else
            {
                _peripheralManager= [[CBPeripheralManager alloc] initWithDelegate:self queue:self.queue ];
            }

        }
    }
    return _peripheralManager;
}

#pragma mark Adding and Removing Services
- (void)addService:(CBMutableService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) onfinish
{
    self.serviceAddingBlocks[service.UUID] = onfinish;
    [self.peripheralManager addService:service];
}
- (void)removeService:(CBMutableService *)service
{
    [self.peripheralManager removeService:service];
    [self.addedServices removeObject:service];
}
- (void)removeAllServices
{
    [self.peripheralManager removeAllServices];
    [self.addedServices removeAllObjects];
}
#pragma mark Managing Advertising
- (void)startAdvertising:(NSDictionary *)advertisementData onStarted:(RKObjectChangedBlock) onstarted
{
    NSAssert(onstarted != nil, @"block should not be nil");
    self.advertisingStartedBlock = onstarted;
    [_peripheralManager startAdvertising: advertisementData];
}
- (void)stopAdvertising
{
    [self.peripheralManager stopAdvertising];
}
- (BOOL)isAdvertising
{
    
    return  self.peripheralManager.isAdvertising;
}

#pragma mark Sending Updates of a Characteristic’s Value
- (BOOL)updateValue:(NSData *)value forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:(NSArray *)centrals
{
    BOOL res = [self.peripheralManager updateValue:value forCharacteristic:characteristic onSubscribedCentrals:centrals];
    if (!res)
    {
        
    }
    return res;
}
#pragma mark Responding to Read and Write Requests
- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result
{
    [_peripheralManager respondToRequest: request withResult: result];
}
#pragma mark Setting Connection Latency
- (void)setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatency)latency forCentral:(CBCentral *)central
{
    [_peripheralManager setDesiredConnectionLatency: latency forCentral:central];
}
- (CBPeripheralManagerState) state
{

    return self.peripheralManager.state;
}
- (NSArray *)services
{
    return self.addedServices;
}
#pragma mark - Delegates
#pragma mark Monitoring Changes to the Peripheral Manager’s State
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onStatedUpdated)
        {
            self.onStatedUpdated(nil);
        }
    }
}
//- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
//{
//    if (peripheral == self.peripheralManager)
//    {
//        if (self.onWillRestoreState)
//        {
//            self.onWillRestoreState(dict);
//        }
//    }
//}
#pragma mark Adding Services
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (peripheral == self.peripheralManager)
    {
        RKSpecifiedServiceUpdatedBlock onfinish = self.serviceAddingBlocks[service.UUID];
        if (!error)
        {
                [self.addedServices addObject: service];
        }
        if (onfinish)
        {
            onfinish(service,error);
            [self.serviceAddingBlocks removeObjectForKey: service.UUID];
        }
    }
}
#pragma mark Advertising Peripheral Data
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (peripheral == self.peripheralManager)
    {
        if (self.advertisingStartedBlock)
        {
            self.advertisingStartedBlock(error);
            self.advertisingStartedBlock = nil;
        }
    }
    
}
#pragma mark Monitoring Subscriptions to Characteristic Values
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onSubscribedBlock)
        {
            self.onSubscribedBlock(central ,characteristic);
        }
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onUnsubscribedBlock)
        {
            self.onUnsubscribedBlock(central,characteristic);
        }
    }
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onReadToUpdateSubscribers)
        {
            self.onReadToUpdateSubscribers(nil);
        }
    }
}
#pragma mark Receiving Read and Write Requests
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onReceivedReadRequest)
        {
            self.onReceivedReadRequest(request);
        }
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    if (peripheral == self.peripheralManager)
    {
        if (self.onReceivedWriteRequest) {
            self.onReceivedWriteRequest(requests);
        }
    }
}

@end
