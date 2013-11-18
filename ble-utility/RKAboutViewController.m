//
//  RKAboutViewController.m
//  ble-utility
//
//  Created by Du Jun on 11/18/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "RKAboutViewController.h"

@interface RKAboutViewController ()

@end

@implementation RKAboutViewController

- (IBAction)contactusAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ruiking.com"]];
}

- (IBAction)mailusAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:support@ruiking.com"]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
