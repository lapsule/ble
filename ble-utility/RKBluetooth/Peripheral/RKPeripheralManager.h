//
//  RKPeripheralManager.h
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKPeripheralManager : NSObject

- (instancetype)initWithQueue:(dispatch_queue_t)queue;
- (instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options NS_AVAILABLE(NA, 7_0);

@end
