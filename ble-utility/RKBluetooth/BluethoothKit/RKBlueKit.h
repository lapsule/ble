//
//  RKBlueKit.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
static  NSString * const sPropertyNames[]={@"Broadcast",@"Read",@"WriteWithoutResponse",@"Write",@"Notify",@"Indicate",@"SignedWrite",
    @"ExtendedProperties",@"NotifyEncryptionRequired",@"IndicateEncryptionRequired"};

@interface RKBlueKit : NSObject
+ (NSArray *)propertiesFrom:(CBCharacteristicProperties) properties;
+(CBCharacteristicProperties )propertyWithString:(NSString *) string;
@end
