//
//  RKCentralManager.h
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
typedef void(^RKPeripheralUpdatedBlock)(CBPeripheral * peripheral);

@interface RKCentralManager : NSObject
@property (nonatomic,strong) NSMutableArray * peripherals;
- (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(RKPeripheralUpdatedBlock) onUpdate;
- (NSArray *)retrieveConnectedPeripheralsWithServices:(NSArray *)serviceUUIDs;
- (NSArray *)retrievePeripheralsWithIdentifiers:(NSArray *)identifiers;
- (void)stopScan;
@end
