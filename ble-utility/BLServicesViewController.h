//
//  BLServicesViewController.h
//  ble-utility
//
//  Created by joost on 13-10-29.
//  Copyright (c) 2013年 joost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKPeripheral.h"
#import "BLTableViewController.h"
@interface BLServicesViewController : BLTableViewController
@property (nonatomic,strong) RKPeripheral * peripheral;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@end
