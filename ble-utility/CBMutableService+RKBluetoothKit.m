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
NSString * folder = nil;
@implementation CBMutableService(RKBluetoothKit)
+(CBMutableService *) serviceWithDict:(NSDictionary*) info;
{
    if (!folder)
    {
        folder = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"servicesdefs"];
    }
    CBMutableService * service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:info[@"uuid"]] primary:YES];
    
    //read xml for characteristics propertys and detail
    NSString * file = [folder stringByAppendingPathComponent:[info[@"type"] stringByAppendingPathExtension:@"xml"]];
    [service addCharacteristcsWithXmlFile:file];
    return service;
}
- (void)addCharacteristcsWithXmlFile:(NSString *)file
{
    NSData * data = [NSData dataWithContentsOfFile:file];
    GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithData:data error:nil];
    if (doc)
    {
        GDataXMLElement * servicexml = [doc rootElement];
        NSArray * characteristicsxml = [servicexml elementsForName:@"Characteristics"];
        NSMutableArray * tcharacteristics = [NSMutableArray arrayWithCapacity:characteristicsxml.count];
        if ( [characteristicsxml isKindOfClass:[NSArray class]] && characteristicsxml.count>0)
        {
            characteristicsxml = [characteristicsxml[0] elementsForName:@"Characteristic"];
            //one characteristic
            for (GDataXMLElement * ele in characteristicsxml)
            {
               CBMutableCharacteristic * characteristic =  [CBMutableCharacteristic characteristicsWithXmlElement: ele];
                [tcharacteristics addObject: characteristic];
            }
            self.characteristics = tcharacteristics;
        }
    }
    
}

@end
