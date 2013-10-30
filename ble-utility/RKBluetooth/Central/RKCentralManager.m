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
@end

@implementation RKCentralManager
- (id) init
{
    self = [super init];
    if (self)
    {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.peripherals = [NSMutableArray arrayWithCapacity:10];
    }
    return  self;
}
- (void)scan
{
    [_manager scanForPeripheralsWithServices:nil options:nil];
    
}
#pragma mark - central manager delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        [self scan];
    }
}
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    [_peripherals addObject: peripheral];
    
}

@end
