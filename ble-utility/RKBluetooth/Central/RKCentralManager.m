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

@property (nonatomic,strong) NSArray * scanningServices;
@property (nonatomic,strong) NSDictionary*  scanningOptions;
@property (nonatomic,assign) BOOL scanStarted;
@property (nonatomic,strong) NSMutableArray * connectingPeripherals;
@property (nonatomic,strong) NSMutableArray * connectedPeripherals;
@property (nonatomic,strong) NSDictionary * initializedOptions;
@property (nonatomic,strong) dispatch_queue_t queue;
@property (nonatomic,strong) NSMutableDictionary * disconnectedBlocks;
@property (nonatomic,strong) NSMutableDictionary * connectionFinishBlocks;
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
    self.connectingPeripherals = [NSMutableArray arrayWithCapacity:3];
    self.connectedPeripherals = [NSMutableArray arrayWithCapacity:3];
    self.connectionFinishBlocks = [NSMutableDictionary dictionaryWithCapacity:3];
    self.disconnectedBlocks =  [NSMutableDictionary dictionaryWithCapacity:3];
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
    self.connectionFinishBlocks[peripheral.identifier] = finished;
    self.disconnectedBlocks[peripheral.identifier] = disconnected;
    [self.connectingPeripherals addObject: peripheral];
    [_manager connectPeripheral: peripheral.peripheral options:options];
    
}
- (void)cancelPeripheralConnection:(RKPeripheral *)peripheral onFinished:(RKPeripheralConnectionBlock) ondisconnected
{
    self.disconnectedBlocks[peripheral.identifier] = ondisconnected;
    [_manager cancelPeripheralConnection:peripheral.peripheral];
}
#pragma mark Retrieving Lists of Peripherals
//TODO: need to convert
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
    if (_onStateChanged)
    {
        _onStateChanged(nil);
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
    RKPeripheral * rkperipheral = [[RKPeripheral alloc] initWithPeripheral:peripheral];
    if (rkperipheral&& ![self.peripherals containsObject: rkperipheral])
    {
        [self.peripherals addObject: rkperipheral];
        if (_onPeripheralUpdated)
        {
            _onPeripheralUpdated(rkperipheral);
        }
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
    if (thePeripheral)
    {
        RKPeripheralConnectionBlock finish = self.connectionFinishBlocks[thePeripheral.identifier];
        // remove it
        [self.connectingPeripherals removeObject: thePeripheral];
        [self.connectedPeripherals addObject: thePeripheral];
        if (finish)
        {
            finish(thePeripheral,nil);
            [self.connectionFinishBlocks removeObjectForKey: thePeripheral.identifier];
        }
        
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
    
    if (thePeripheral)
    {
        RKPeripheralConnectionBlock finish = self.connectionFinishBlocks[thePeripheral.identifier];
        // remove it
        [self.connectingPeripherals removeObject: thePeripheral];
        if (finish)
        {
            finish(thePeripheral,error);
            [self.connectionFinishBlocks removeObjectForKey: thePeripheral.identifier];
            [self.disconnectedBlocks removeObjectForKey:thePeripheral.identifier];
        }
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
    if (rkperipheral)
    {
        RKPeripheralConnectionBlock finish = self.disconnectedBlocks[rkperipheral.identifier];
        [self.connectedPeripherals removeObject:rkperipheral];
        if (finish)
        {
            finish(rkperipheral,error);
            [self.disconnectedBlocks removeObjectForKey:rkperipheral.identifier];
        }
    }
    

}

@end
