//
//  NSData+Hex.h
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(Hex)
- (NSString *)hexadecimalString;
+ (NSData *)dataWithHexString:(NSString *)hexstring;
@end
