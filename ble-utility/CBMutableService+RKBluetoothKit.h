//
//  CBMutableService+RKBluetoothKit.h
//  ble-utility
//
//  Created by joost on 13-11-13.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "GDataXMLNode.h"
extern  NSString * folder;
@interface CBMutableService(RKBluetoothKit)
+(CBMutableService *) serviceWithDict:(NSDictionary*) info;
@end
