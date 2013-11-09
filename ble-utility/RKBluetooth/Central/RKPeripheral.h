//
//  RKPeripheral.h
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^RKCharacteristicChangedBlock)(CBCharacteristic * characteristic, NSError * error);
typedef void(^RKDescriptorChangedBlock)(CBDescriptor * descriptor, NSError * error);
typedef void(^RKIncluedServiceBlock)(CBService * service,NSError * error);
typedef void(^RKPeripheralChangedBlock)(NSError * error);
@interface RKPeripheral : NSObject
@property (nonatomic,strong,readonly) CBPeripheral * peripheral;
@property (nonatomic) NSArray * services;
@property (nonatomic,weak) id<CBPeripheralDelegate> delegate;
@property(readonly, nonatomic,strong) NSUUID *identifier;
@property(readonly) NSString *name;
@property(readonly) NSNumber *RSSI;

- (instancetype)initWithPeripheral:(CBPeripheral *) peripheral;
- (void)discoverServices:(NSArray *)serviceUUIDs onFinish:(RKPeripheralChangedBlock) discoverFinished;
- (void)discoverIncludedServices:(NSArray *)includedServiceUUIDs forService:(CBService *)service onFinish:(RKIncluedServiceBlock) finished;
@end
