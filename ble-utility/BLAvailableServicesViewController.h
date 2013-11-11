//
//  BLAvailableServicesViewController.h
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import "BLTableViewController.h"
typedef void(^BLServiceSelected)(NSDictionary * service);
@interface BLAvailableServicesViewController : BLTableViewController
@property (nonatomic,copy) BLServiceSelected onSelectService;
@end
