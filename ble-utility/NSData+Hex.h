//
//  NSData+Hex.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(Hex)
- (NSString *)hexadecimalString;
+ (NSData *)dataWithHexString:(NSString *)hexstring;
@end
