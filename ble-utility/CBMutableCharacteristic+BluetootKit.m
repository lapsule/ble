//
//  CBMutableCharacteristic+BluetootKit.m
//  ble-utility
//
//  Created by joost on 13-11-13.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import "CBMutableCharacteristic+BluetootKit.h"
#import "CBMutableService+RKBluetoothKit.h"
#import "RKBlueKit.h"
@implementation CBMutableCharacteristic(BluetootKit)
+ (CBMutableCharacteristic*)characteristicsWithXmlElement:(GDataXMLElement *) element
{
    NSString * type =[[element attributeForName:@"type"]stringValue];
    NSString * uuid = nil;
    CBMutableCharacteristic * characteristic = nil;
    //# get properties
    CBCharacteristicProperties p=0 ;
    CBAttributePermissions permission = 0;
    NSError * err=nil;
    NSArray * t = [element nodesForXPath: @"Properties/*" error:& err];
    for (GDataXMLNode * node in t)
    {
        if (![[node stringValue] isEqualToString:@"Excluded"])
        {
            p|=[RKBlueKit propertyWithString: [node name] ];
        }
    }
    //permissions
     if ((p &CBCharacteristicPropertyWrite) !=0 ||(p&CBCharacteristicPropertyWriteWithoutResponse)!=0 )
     {
         permission |= CBAttributePermissionsWriteable;
     }
    if ((p &CBCharacteristicPropertyAuthenticatedSignedWrites) !=0 )
    {
        permission |= CBAttributePermissionsWriteEncryptionRequired;
    }
    if ((p &CBCharacteristicPropertyRead) !=0 )
    {
        permission |= CBAttributePermissionsReadable;
    }
    //detailed characteristics
    NSString * file = [type stringByAppendingPathExtension:@"xml"];
    file = [folder stringByAppendingPathComponent: file];
    NSData * data = [NSData dataWithContentsOfFile:file];
    GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithData:data error:nil];
    if (doc)
    {
        
        
        GDataXMLElement * servicexml = [doc rootElement];
        uuid = [[servicexml attributeForName:@"uuid"] stringValue];
        characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString: uuid] properties:p value:nil permissions:permission];
        
        //# add descriptors
//        [characteristic addDescriptorsWithXmlElement:servicexml];
    }
    
    return characteristic;
}
- (void)addDescriptorsWithXmlElement:(GDataXMLElement *)element
{
    
}
@end
