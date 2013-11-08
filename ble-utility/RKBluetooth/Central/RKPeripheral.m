//
//  RKPeripheral.m
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import "RKPeripheral.h"
@interface RKPeripheral()
@end
@implementation RKPeripheral
- (instancetype)initWithPeripheral:(CBPeripheral *) peripheral
{
    self = [super init];
    if (self)
    {
        _peripheral = peripheral;
    }
    return self;
}
- (BOOL) isEqual:(id)object
{
    return [_peripheral isEqual: [object peripheral]];
}
@end
