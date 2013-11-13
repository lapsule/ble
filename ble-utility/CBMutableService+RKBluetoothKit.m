//
//  CBMutableService+RKBluetoothKit.m
//  ble-utility
//
//  Created by joost on 13-11-13.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import "CBMutableService+RKBluetoothKit.h"

@implementation CBMutableService(RKBluetoothKit)
+(CBMutableService *) serviceWithXmlElement:(GDataXMLElement*) element
{
    
    CBMutableService * service = [[CBMutableService alloc] initWithType:nil primary:YES];
    return service;
}
@end
