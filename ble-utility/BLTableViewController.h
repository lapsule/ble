//
//  BLTableViewController.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLAppDelegate.h"
#import "RKPeripheral.h"
#import "RKPeripheralManager.h"
#import "MBProgressHUD.h"
@interface BLTableViewController : UITableViewController
@property (nonatomic,strong) UIActivityIndicatorView * indicator;
@property (nonatomic,strong) UIBarButtonItem * indicatorItem;
@property (nonatomic,assign) BOOL isCentralManager;
@property (nonatomic,weak) BLAppDelegate * appd;
@property (nonatomic,strong) RKPeripheral * peripheral;
@property (nonatomic,strong)RKPeripheralManager * peripheralManager;
@property (nonatomic,strong) MBProgressHUD * hud;
- (void)setup;
@end
