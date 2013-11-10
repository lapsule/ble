//
//  RKPeripheralManager.m
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import "RKPeripheralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface RKPeripheralManager()<CBPeripheralManagerDelegate>
@property (nonatomic,strong) CBPeripheralManager * peripheralManager;
@end
#pragma mark - implementation
@implementation RKPeripheralManager
- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        _peripheralManager= [[CBPeripheralManager alloc] initWithDelegate:self queue:queue];
    }
    return self;
}
#pragma mark - Delegates
#pragma mark Monitoring Changes to the Peripheral Manager’s State
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
    
}
#pragma mark Adding Services
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    
}
#pragma mark Advertising Peripheral Data
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    
}
#pragma mark Monitoring Subscriptions to Characteristic Values
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    
}
#pragma mark Receiving Read and Write Requests
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    
}

@end
