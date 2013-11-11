//
//  BLCharacteristicsViewController.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKPeripheral.h"
#import "BLTableViewController.h"
@interface BLCharacteristicsViewController : BLTableViewController
@property (nonatomic,strong) RKPeripheral * peripheral;
@property (nonatomic,strong) CBService * service;
@end
