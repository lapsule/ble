//
//  CBMutableService+RKBluetoothKit.m
//  ble-utility
//
//  Created by joost on 13-11-13.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import "CBMutableService+RKBluetoothKit.h"
#import "GDataXMLNode.h"
#import "CBMutableCharacteristic+BluetootKit.h"
static NSString * folder = nil;
@implementation CBMutableService(RKBluetoothKit)
+(CBMutableService *) serviceWithDict:(NSDictionary*) info;
{
    
    if (!folder)
    {
        folder = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"servicesdefs"];
    }
   
    CBMutableService * service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:info[@"uuid"]] primary:YES];
    [service addCharacteristcsWithArr:info[@"characteristics"]];
    return service;
}
- (void) addCharacteristcsWithArr:(NSArray *) chardicts
{
    //add characteristics
    NSMutableArray * charas= [NSMutableArray arrayWithCapacity: chardicts.count];
    for (NSDictionary * chdict in chardicts)
    {
        NSString * type = chdict[@"type"];
        NSString * file = [type stringByAppendingPathExtension:@"xml"];
        file = [folder stringByAppendingPathComponent: file];
        NSData * data = [NSData dataWithContentsOfFile:file];
        GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithData:data error:nil];
        if (doc)
        {
            GDataXMLElement * servicexml = [doc rootElement];
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:servicexml.attributes.count];
            for (GDataXMLNode * att in servicexml.attributes)
            {
                dict[att.name] = [att.children[0] XMLString];
            }
            CBMutableCharacteristic * characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString: dict[@"uuid"]] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
            //descriptor
            GDataXMLElement * descriptoreles = [servicexml elementsForName:@"descriptoreles"][0];
            [characteristic addDescriptorsWithXmlElement: descriptoreles];
            //
            [charas addObject: characteristic];
        }
        
    }
    self.characteristics = charas;
}
@end
