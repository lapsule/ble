//
//  RKBlueKit.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "RKBlueKit.h"

@implementation RKBlueKit
+ (NSArray *)propertiesFrom:(CBCharacteristicProperties) properties
{
    int c = sizeof(sPropertyNames)/sizeof(NSString*);
    NSMutableArray * temp = [NSMutableArray arrayWithCapacity:c];
    for (int i =0 ; i!= c; ++i)
    {
        NSInteger t = 0x1<<i;
        if ((t&properties) !=0)
        {
            [temp addObject:sPropertyNames[i]];
        }
    }
    return temp;
}
+(CBCharacteristicProperties )propertyWithString:(NSString *) string
{
    int c = sizeof(sPropertyNames)/sizeof(NSString*);
    CBCharacteristicProperties t=0;
    for (int i =0 ; i!= c; ++i)
    {
        if ([sPropertyNames[i] isEqualToString:string])
        {
            t = 0x1<<i;
            break;
        }
    }
    return t;
}
@end
