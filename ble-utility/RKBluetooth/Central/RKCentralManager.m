//
//  RKCentralManager.m
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import "RKCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface RKCentralManager()<CBCentralManagerDelegate>
@property (nonatomic,strong) CBCentralManager * manager;
@property (nonatomic,strong) RKPeripheralUpdatedBlock onPeripheralUpdated;
@end

@implementation RKCentralManager
- (id) initWithOptions:(NSDictionary *) options
{
    self = [super init];
    if (self)
    {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
        self.peripherals = [NSMutableArray arrayWithCapacity:10];
    }
    return  self;
}
#pragma mark scan
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(RKPeripheralUpdatedBlock) onUpdate
{
    self.onPeripheralUpdated = onUpdate;
    [_manager scanForPeripheralsWithServices:serviceUUIDs options:options];
}
- (void)stopScan
{
    [_manager stopScan];
}
#pragma mark connect peripheral
- (void)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary *)options
{
    //TODO: connect callback
    [_manager connectPeripheral: peripheral options:options];
    
}

#pragma mark retrieve connected peripherals
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs
{
   return  [_manager retrieveConnectedPeripheralsWithServices: serviceUUIDs];
}
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers
{
    return [_manager retrieveConnectedPeripheralsWithServices:identifiers];
}

#pragma mark - central manager delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        
    }
    //FIXME:ERROR
    

    DebugLog(@"Central %@ changed to %d",central,central.state);
}
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    [_peripherals addObject: peripheral];
    if (_onPeripheralUpdated)
    {
        _onPeripheralUpdated(peripheral);
    }
    DebugLog(@"name %@",peripheral.name);
}

@end
