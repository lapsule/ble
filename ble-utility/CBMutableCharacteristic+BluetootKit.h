//
//  CBMutableCharacteristic+BluetootKit.h
//  ble-utility
//
//  Created by joost on 13-11-13.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "GDataXMLNode.h"

@interface CBMutableCharacteristic(BluetootKit)
+ (CBMutableCharacteristic*)characteristicsWithXmlElement:(GDataXMLElement *) element;
- (void)addDescriptorsWithXmlElement:(GDataXMLElement *)element;
@end
