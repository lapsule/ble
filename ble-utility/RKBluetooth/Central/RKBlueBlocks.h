//
//  RKBlueBlocks.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#ifndef ble_utility_RKBlueBlocks_h
#define ble_utility_RKBlueBlocks_h
#import <CoreBluetooth/CoreBluetooth.h>
//#pragma mark block defs
@class RKPeripheral;

// central manager
typedef void(^RKCharacteristicChangedBlock)(CBCharacteristic * characteristic, NSError * error);
typedef void(^RKDescriptorChangedBlock)(CBDescriptor * descriptor, NSError * error);
typedef void(^RKSpecifiedServiceUpdatedBlock)(CBService * service,NSError * error);
typedef void(^RKObjectChangedBlock)(NSError * error);
typedef void(^RKServicesUpdated)(NSArray * services);
typedef void(^RKPeripheralUpdatedBlock)(RKPeripheral * peripheral);
typedef void(^RKPeripheralConnectionBlock)(RKPeripheral * peripheral,NSError * error);

//peripheral manager
typedef void(^RKPeripheralManagerStatedChnagedBlock)(NSDictionary * state);
typedef void(^RKCentralSubscriptionBlock)(CBCentral * central,CBCharacteristic * characteristic);
typedef void(^RKCentralReadRequestBlock)(CBATTRequest * readRequest);
typedef void(^RKCentralWriteRequestBlock)(NSArray * writeRequests);
#endif
