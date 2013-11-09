//
//  RKPeripheral.h
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#pragma mark block defs
typedef void(^RKCharacteristicChangedBlock)(CBCharacteristic * characteristic, NSError * error);
typedef void(^RKDescriptorChangedBlock)(CBDescriptor * descriptor, NSError * error);
typedef void(^RKSpecifiedServiceUpdatedBlock)(CBService * service,NSError * error);
typedef void(^RKPeripheralChangedBlock)(NSError * error);
typedef void(^RKServicesUpdated)(NSArray * services);

@interface RKPeripheral : NSObject
@property (nonatomic,strong,readonly) CBPeripheral * peripheral;
@property (nonatomic) NSArray * services;
@property (nonatomic,weak) id<CBPeripheralDelegate> delegate;
@property(readonly, nonatomic,strong) NSUUID *identifier;
@property(readonly) NSString *name;
@property(readonly) NSNumber *RSSI;
@property (nonatomic,strong) RKServicesUpdated onServiceModified;
@property (nonatomic,strong) RKPeripheralChangedBlock onNameUpdated;
@property (nonatomic,strong) RKCharacteristicChangedBlock notificationStateChanged;

- (instancetype)initWithPeripheral:(CBPeripheral *) peripheral;
#pragma mark discovery services
- (void)discoverServices:(NSArray *)serviceUUIDs onFinish:(RKPeripheralChangedBlock) discoverFinished;
- (void)discoverIncludedServices:(NSArray *)includedServiceUUIDs forService:(CBService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) finished;
#pragma mark Discovering Characteristics and Characteristic Descriptors
- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) onfinish;
- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic onFinish:(RKCharacteristicChangedBlock) onfinish;
#pragma mark ReadRSSI
- (void)readRSSIOnFinish:(RKPeripheralChangedBlock) onUpdated;
@end
