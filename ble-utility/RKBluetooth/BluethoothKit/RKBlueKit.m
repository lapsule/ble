//
//  RKBlueKit.m
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import "RKBlueKit.h"
static  NSString * const sPropertyNames[]={@"Broadcast",@"Read",@"WriteWithoutResponse",@"Notify",@"Indicate",@"AuthenticatedSignedWrites",
@"ExtendedProperties",@"NotifyEncryptionRequired",@"IndicateEncryptionRequired"};
@implementation RKBlueKit
+ (NSArray *)propertiesFrom:(CBCharacteristicProperties) properties
{
    int c = sizeof(sPropertyNames)/sizeof(NSString*);
    NSMutableArray * temp = [NSMutableArray arrayWithCapacity:c];
    for (int i =0 ; i!= c; ++i)
    {
        int t = 2<<i;
        if ((t&properties) >0)
        {
            [temp addObject:sPropertyNames[i]];
        }
    }
    return temp;
}
@end
