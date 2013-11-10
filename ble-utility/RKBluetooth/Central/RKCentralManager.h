//
//  RKCentralManager.h
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class RKPeripheral;
typedef void(^RKPeripheralUpdatedBlock)(RKPeripheral * peripheral);
typedef void(^RKPeripheralConnectionBlock)(RKPeripheral * peripheral,NSError * error);

@interface RKCentralManager : NSObject
@property (atomic,strong,readonly) NSMutableArray * peripherals;
@property (nonatomic,weak) id<CBCentralManagerDelegate> delegate;
@property(readonly) CBCentralManagerState state;

- (instancetype) initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *) options;
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(RKPeripheralUpdatedBlock) onUpdate;
- (void)connectPeripheral:(RKPeripheral *)peripheral options:(NSDictionary *)options onFinished:(RKPeripheralConnectionBlock) finished onDisconnected:(RKPeripheralConnectionBlock) disconnected;
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs;
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;
- (void)stopScan;
@end
