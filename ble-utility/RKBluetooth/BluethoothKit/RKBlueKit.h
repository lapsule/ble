//
//  RKBlueKit.h
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface RKBlueKit : NSObject
+ (NSArray *)propertiesFrom:(CBCharacteristicProperties) properties;
@end
