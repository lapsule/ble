//
//  BLServicesViewController.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 13-10-29.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKPeripheral.h"
#import "BLTableViewController.h"
@interface BLServicesViewController : BLTableViewController
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (nonatomic,strong) NSArray * services;
@end
