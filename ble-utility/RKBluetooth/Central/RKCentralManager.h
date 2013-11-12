//
//  RKCentralManager.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 10/30/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RKBlueBlocks.h"
@class RKPeripheral;


@interface RKCentralManager : NSObject
@property (atomic,strong,readonly) NSMutableArray * peripherals;
@property(readonly) CBCentralManagerState state;
@property (nonatomic,copy)RKObjectChangedBlock onStateChanged;
- (instancetype) initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *) options NS_AVAILABLE(NA, 7_0);
- (instancetype) initWithQueue:(dispatch_queue_t)queue;

#pragma mark Scanning or Stopping Scans of Peripherals

- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(RKPeripheralUpdatedBlock) onUpdate;
- (void)stopScan;

#pragma mark Establishing or Canceling Connections with Peripherals

- (void)connectPeripheral:(RKPeripheral *)peripheral options:(NSDictionary *)options onFinished:(RKPeripheralConnectionBlock) finished onDisconnected:(RKPeripheralConnectionBlock) disconnected;
- (void)cancelPeripheralConnection:(RKPeripheral *)peripheral onFinished:(RKPeripheralConnectionBlock) ondisconnected;
#pragma mark Retrieving Lists of Peripherals
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs NS_AVAILABLE(NA, 7_0);
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers NS_AVAILABLE(NA, 7_0);

@end
