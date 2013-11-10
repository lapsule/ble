//
//  BLDescriptorsViewController.h
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 joost. All rights reserved.
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
@end
