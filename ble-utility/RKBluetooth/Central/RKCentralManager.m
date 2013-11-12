//
//  RKCentralManager.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 10/30/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "RKCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "RKPeripheral.h"


@interface RKCentralManager()<CBCentralManagerDelegate>
@property (nonatomic,strong) CBCentralManager * manager;
@property (nonatomic,copy) RKPeripheralUpdatedBlock onPeripheralUpdated;
@property (nonatomic,strong) NSMutableDictionary *  connectionFinishBlocks;
@property (nonatomic,strong) NSMutableDictionary* disconnectedBlocks;
@property (nonatomic,strong) NSArray * scanningServices;
@property (nonatomic,strong) NSDictionary*  scanningOptions;
@property (nonatomic,assign) BOOL scanStarted;
@property (nonatomic,strong) NSMutableArray * connectingPeripherals;
@property (nonatomic,strong) NSMutableArray * connectedPeripherals;
@property (nonatomic,strong) NSDictionary * initializedOptions;
@property (nonatomic,strong) dispatch_queue_t queue;
@end

@implementation RKCentralManager

- (instancetype) initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        [self initializeWithQueue:queue options:nil];
    }
    return  self;
}
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
        [self initializeWithQueue:nil options: nil];
    }
    return self;
}
- (void)initializeWithQueue:(dispatch_queue_t) queue options:(NSDictionary *) options
{
    self.queue = queue;
    self.initializedOptions = options;
    _peripherals = [NSMutableArray arrayWithCapacity:10];
    self.connectionFinishBlocks = [NSMutableDictionary dictionaryWithCapacity:3];
    self.disconnectedBlocks = [NSMutableDictionary dictionaryWithCapacity:3];
    self.connectingPeripherals = [NSMutableArray arrayWithCapacity:3];
    self.connectedPeripherals = [NSMutableArray arrayWithCapacity:3];
}
- (CBCentralManagerState)state
{
    return _manager.state;
}
- (CBCentralManager *) manager
{
    @synchronized(_manager)
    {
        if (!_manager)
        {
            if (![CBCentralManager resolveInstanceMethod:@selector(initWithDelegate:queue:options:)])
            {
                //for ios version lowser than 7.0
                self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:self.queue];
            }else
            {
                
                self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:self.queue options: self.initializedOptions];
            }
        }
    }
    return _manager;
}
- (void)dealloc
{
    _manager.delegate = nil;
}

#pragma mark Scanning or Stopping Scans of Peripherals

- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(RKPeripheralUpdatedBlock) onUpdate
{
    [self.peripherals removeAllObjects];
    self.onPeripheralUpdated = onUpdate;
    if (self.manager.state == CBCentralManagerStatePoweredOn )
    {
        [self.manager scanForPeripheralsWithServices: serviceUUIDs options:options];
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
#pragma mark Establishing or Canceling Connections with Peripherals
- (void)connectPeripheral:(RKPeripheral *)peripheral options:(NSDictionary *)options onFinished:(RKPeripheralConnectionBlock) finished onDisconnected:(RKPeripheralConnectionBlock) disconnected
{
    self.connectionFinishBlocks[peripheral.peripheral] = finished;
    self.disconnectedBlocks[peripheral.peripheral] = disconnected;
    [self.connectingPeripherals addObject: peripheral];
    [_manager connectPeripheral: peripheral.peripheral options:options];
    
}
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral onFinished:(RKPeripheralConnectionBlock) ondisconnected
{
    [_manager cancelPeripheralConnection:peripheral];
}
#pragma mark Retrieving Lists of Peripherals
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs
{
   return  [_manager retrieveConnectedPeripheralsWithServices: serviceUUIDs];
}
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers
{
    return [_manager retrievePeripheralsWithIdentifiers: identifiers];
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
//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(centralManager:willRestoreState:)])
//    {
//        [_delegate centralManager:central willRestoreState: dict];
//    }
//}
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

#pragma mark Monitoring Connections with Peripherals
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    RKPeripheral * thePeripheral = nil;
    for (RKPeripheral * rk in self.connectingPeripherals)
    {
        if (peripheral == rk.peripheral)
        {
            thePeripheral = rk;
            break;
        }
    }
    
    RKPeripheralConnectionBlock finish = self.connectionFinishBlocks[peripheral];
    if (finish)
    {
        finish(thePeripheral,nil);
        // remove it
        [self.connectingPeripherals removeObject: thePeripheral];
        [self.connectedPeripherals addObject: thePeripheral];
        [self.connectionFinishBlocks removeObjectForKey: thePeripheral.peripheral];
    }
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    RKPeripheral * thePeripheral = nil;
    for (RKPeripheral * rk in self.connectingPeripherals)
    {
        if (peripheral == rk.peripheral)
        {
            thePeripheral = rk;
            break;
        }
    }
    
    RKPeripheralConnectionBlock finish = self.connectionFinishBlocks[peripheral];
    if (finish)
    {
        finish(thePeripheral,error);
        // remove it
        [self.connectingPeripherals removeObject: thePeripheral];
        [self.connectionFinishBlocks removeObjectForKey: thePeripheral.peripheral];
        [self.disconnectedBlocks removeObjectForKey:thePeripheral.peripheral];
    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    RKPeripheral * rkperipheral = nil;
    for (int i =0;i!= self.connectedPeripherals.count;++i)
    {
        if (peripheral == [self.connectedPeripherals[i] peripheral])
        {
            rkperipheral = self.connectedPeripherals[i];
            break;
        }
    }
    RKPeripheralConnectionBlock finish = self.disconnectedBlocks[peripheral];
    [self.connectedPeripherals removeObject:rkperipheral];
    if (finish)
    {
        finish(rkperipheral,error);
        [self.disconnectedBlocks removeObjectForKey:peripheral];
    }

}

@end
