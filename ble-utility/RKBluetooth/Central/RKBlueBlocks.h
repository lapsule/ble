//
//  RKBlueBlocks.h
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#ifndef ble_utility_RKBlueBlocks_h
#define ble_utility_RKBlueBlocks_h

#pragma mark block defs
@class RKPeripheral;
typedef void(^RKCharacteristicChangedBlock)(CBCharacteristic * characteristic, NSError * error);
typedef void(^RKDescriptorChangedBlock)(CBDescriptor * descriptor, NSError * error);
typedef void(^RKSpecifiedServiceUpdatedBlock)(CBService * service,NSError * error);
typedef void(^RKPeripheralChangedBlock)(NSError * error);
typedef void(^RKServicesUpdated)(NSArray * services);
typedef void(^RKPeripheralUpdatedBlock)(RKPeripheral * peripheral);
typedef void(^RKPeripheralConnectionBlock)(RKPeripheral * peripheral,NSError * error);

#endif
