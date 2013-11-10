//
//  BLTableViewController.h
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLTableViewController : UITableViewController
@property (nonatomic,strong) UIActivityIndicatorView * indicator;
@property (nonatomic,strong) UIBarButtonItem * indicatorItem;
@end
