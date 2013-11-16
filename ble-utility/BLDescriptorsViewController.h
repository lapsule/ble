//
//  BLDescriptorsViewController.h
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKPeripheral.h"
#import "BLTableViewController.h"
@interface BLDescriptorsViewController : BLTableViewController
@property (nonatomic,strong) RKPeripheral * peripheral;
@property (nonatomic,strong) CBCharacteristic * characteristic;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *properties;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UISwitch *notifySwitch;
@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;
- (IBAction)changeNotifyState:(id)sender;
@end
