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

//@property (nonatomic,strong) NSArray * scanningServices;
//@property (nonatomic,strong) NSDictionary*  scanningOptions;
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
    return self.manager.state;
}
- (CBCentralManager *) manager
{
    @synchronized(_manager)
    {
        if (!_manager)
        {
            if (![CBCentralManager instancesRespondToSelector:@selector(initWithDelegate:queue:options:)])
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
    NSAssert(onUpdate!=nil, @"onUpdate should be nil!");
    [self.manager scanForPeripheralsWithServices: serviceUUIDs options:options];
    self.onPeripheralUpdated = onUpdate;
}
- (void)stopScan
{
    [self.manager stopScan];
}
#pragma mark Establishing or Canceling Connections with Peripherals
- (void)connectPeripheral:(RKPeripheral *)peripheral options:(NSDictionary *)options onFinished:(RKPeripheralConnectionBlock) finished onDisconnected:(RKPeripheralConnectionBlock) disconnected
{
    self.connectionFinishBlocks[peripheral.identifier] = finished;
    self.disconnectedBlocks[peripheral.identifier] = disconnected;
    [self.connectingPeripherals addObject: peripheral];
    [self.manager connectPeripheral: peripheral.peripheral options:options];
    
}
- (void)cancelPeripheralConnection:(RKPeripheral *)peripheral onFinished:(RKPeripheralConnectionBlock) ondisconnected
{
    self.disconnectedBlocks[peripheral.identifier] = ondisconnected;
    [self.manager cancelPeripheralConnection:peripheral.peripheral];
}
#pragma mark Retrieving Lists of Peripherals
//#: need to convert to RKPeripheral , with pre-delegate unchanged
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs
{
    NSArray * t  =  [self.manager retrieveConnectedPeripheralsWithServices: serviceUUIDs];
    NSMutableArray * rkpers = [NSMutableArray arrayWithCapacity:t.count];
    for (CBPeripheral * per in t)
    {
        RKPeripheral * rkper = per.delegate;
        if (!rkper)
        {
            rkper = [[RKPeripheral alloc] initWithPeripheral:per];
        }
        [rkpers addObject: rkper];
    }
    return rkpers;
}
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers
{
    NSArray * t = [self.manager retrievePeripheralsWithIdentifiers:identifiers];
    NSMutableArray * rkpers = [NSMutableArray arrayWithCapacity:t.count];
    for (CBPeripheral * per in t)
    {
        RKPeripheral * rkper = per.delegate;
        if (!rkper)
        {
            rkper = [[RKPeripheral alloc] initWithPeripheral:per];
        }
        [rkpers addObject: rkper];
    }
    return rkpers;
}
#pragma mark - internal methods
- (void)clearPeripherals
{
    [self.connectedPeripherals removeAllObjects];
    [self.connectingPeripherals removeAllObjects];
    [self.peripherals removeAllObjects];
    [self.connectionFinishBlocks removeAllObjects];
    [self.disconnectedBlocks removeAllObjects];
}
#pragma mark - Delegate
#pragma mark    central state delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central == self.manager)
    {
        switch ([central state])
        {
            case CBCentralManagerStatePoweredOff:
            {
                [self clearPeripherals];
                _onPeripheralUpdated(nil);
                break;
            }
                
            case CBCentralManagerStateUnauthorized:
            {
                /* Tell user the app is not allowed. */
                break;
            }
                
            case CBCentralManagerStateUnknown:
            {
                /* Bad news, let's wait for another event. */
                break;
            }
                
            case CBCentralManagerStatePoweredOn:
            {
                if (_onPeripheralUpdated)
                {
                    _onPeripheralUpdated(nil);
                }
                
                break;
            }
                
            case CBCentralManagerStateResetting:
            {
                [self clearPeripherals];
                _onPeripheralUpdated(nil);
                break;
            }
            case CBCentralManagerStateUnsupported:
                break;
        }
        if (_onStateChanged)
        {
            _onStateChanged(nil);
        }
        
    }
    //
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
   
    RKPeripheral * rkperipheral=peripheral.delegate;
    if (!rkperipheral)
    {
        rkperipheral = [[RKPeripheral alloc] initWithPeripheral:peripheral];
    }
    if (rkperipheral && ![self.peripherals containsObject: rkperipheral])
    {
        [self.peripherals addObject: rkperipheral];
    }
    rkperipheral.RSSI = RSSI;
    _onPeripheralUpdated(rkperipheral);
    
    DebugLog(@"%@ on %@ thread",peripheral, [NSThread isMainThread]?@"Main":@"Other");
}

#pragma mark Monitoring Connections with Peripherals
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    RKPeripheral * thePeripheral = peripheral.delegate;
    if (thePeripheral && [self.connectingPeripherals containsObject: thePeripheral])
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
    RKPeripheral * thePeripheral = peripheral.delegate;
   
    if (thePeripheral&& [self.connectingPeripherals containsObject: thePeripheral])
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
    RKPeripheral * rkperipheral = peripheral.delegate;
   
    if (rkperipheral && [self.connectedPeripherals containsObject: rkperipheral])
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
