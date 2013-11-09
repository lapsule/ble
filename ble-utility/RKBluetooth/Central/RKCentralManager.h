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

@interface RKCentralManager : NSObject
@property (atomic,strong) NSMutableArray * peripherals;
@property (nonatomic,weak) id<CBCentralManagerDelegate> delegate;

- (instancetype) initWithOptions:(NSDictionary *) options;
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(RKPeripheralUpdatedBlock) onUpdate;
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs;
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;
- (void)stopScan;
@end
