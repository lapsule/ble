//
//  RKPeripheral.h
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface RKPeripheral : NSObject
@property (nonatomic,readonly,strong) CBPeripheral * peripheral;
- (instancetype)initWithPeripheral:(CBPeripheral *) peripheral;
@end
