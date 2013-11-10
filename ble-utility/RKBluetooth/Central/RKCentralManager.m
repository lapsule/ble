//
//  RKCentralManager.m
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import "RKCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "RKPeripheral.h"


@interface RKCentralManager()<CBCentralManagerDelegate>
@property (nonatomic,strong) CBCentralManager * manager;
@property (nonatomic,copy) RKPeripheralUpdatedBlock onPeripheralUpdated;
@property (nonatomic,copy) RKPeripheralConnectionBlock onConnectionFinish;
@property (nonatomic,copy) RKPeripheralConnectionBlock onDisconnected;
@property (nonatomic,strong) NSArray * scanningServices;
@property (nonatomic,strong) NSDictionary*  scanningOptions;
@property (nonatomic,assign) BOOL scanStarted;
@property (nonatomic,strong) RKPeripheral * connectingPeripheral;
@end

@implementation RKCentralManager

- (instancetype) initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *) options
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:queue options:options];
    }
    return  self;
}
- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:nil options: @{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    }
    return self;
}
- (void)initializeWithQueue:(dispatch_queue_t) queue options:(NSDictionary *) options
{
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:options];
    _peripherals = [NSMutableArray arrayWithCapacity:10];
}
- (CBCentralManagerState)state
{
    return _manager.state;
}
#pragma mark scan
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(RKPeripheralUpdatedBlock) onUpdate
{
    self.onPeripheralUpdated = onUpdate;
    if (_manager.state == CBCentralManagerStatePoweredOn )
    {
        [_manager scanForPeripheralsWithServices: serviceUUIDs options:options];
    }else
    {
        self.scanningOptions = options;
        self.scanningServices = serviceUUIDs;
        self.scanStarted = YES;
    }
}
- (void)stopScan
{
    [_manager stopScan];
}
#pragma mark connect peripheral
- (void)connectPeripheral:(RKPeripheral *)peripheral options:(NSDictionary *)options onFinished:(RKPeripheralConnectionBlock) finished onDisconnected:(RKPeripheralConnectionBlock) disconnected
{
    self.onConnectionFinish = finished;
    self.onDisconnected = disconnected;
    self.connectingPeripheral = peripheral;
    [_manager connectPeripheral: peripheral.peripheral options:options];
    
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

#pragma mark - Delegate
#pragma mark    central state delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (_delegate && [_delegate respondsToSelector:@selector(centralManagerDidUpdateState:)])
    {
        [_delegate centralManagerDidUpdateState: central];
    }
    if(central.state==CBCentralManagerStatePoweredOn && _scanStarted)
    {
        [self scanForPeripheralsWithServices:self.scanningServices options:self.scanningOptions onUpdated: self.onPeripheralUpdated];
    }
    //FIXME:ERROR
    DebugLog(@"Central %@ changed to %d",central,(int)central.state);
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    if (_delegate && [_delegate respondsToSelector:@selector(centralManager:willRestoreState:)])
    {
        [_delegate centralManager:central willRestoreState: dict];
    }
}
#pragma mark discovery delegate
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    RKPeripheral * rkperipheral = [[RKPeripheral alloc] initWithPeripheral: peripheral];
    if (![self.peripherals containsObject: rkperipheral])
    {
        [self.peripherals addObject: rkperipheral];
    }
    if (_onPeripheralUpdated)
    {
        _onPeripheralUpdated(rkperipheral);
    }
    DebugLog(@"name %@",peripheral.name);
}

#pragma mark connection delegate
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral == self.connectingPeripheral.peripheral)
    {
        if (self.onConnectionFinish)
        {
            self.onConnectionFinish(self.connectingPeripheral,nil);
        }
        self.connectingPeripheral = nil;
    }
    
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral == self.connectingPeripheral.peripheral)
    {
        if (self.onConnectionFinish)
        {
            self.onConnectionFinish(self.connectingPeripheral,error);
        }
        self.connectingPeripheral = nil;
    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{

    if (self.onDisconnected)
    {
        RKPeripheral * rkperipheral = [[RKPeripheral alloc] initWithPeripheral: peripheral];
        self.onDisconnected(rkperipheral,error);
    }

}

@end
