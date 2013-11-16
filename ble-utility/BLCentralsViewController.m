//
//  BLCentralsViewController.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "BLCentralsViewController.h"
#import "RKPeripheralManager.h"
#import "BLAvailableServicesViewController.h"
#import "CBMutableService+RKBluetoothKit.h"
#import "BLCharacteristicsViewController.h"
@interface BLCentralsViewController ()
@property (nonatomic,strong) RKPeripheralManager * manager;
@end

@implementation BLCentralsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isCentralManager = NO;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
   
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Services";
	// Do any additional setup after loading the view.
}
- (void)setup
{
    self.navigationItem.leftBarButtonItem = self.indicatorItem;
    self.manager = [[RKPeripheralManager alloc] init];
    if (self.manager.state != CBPeripheralManagerStatePoweredOn)
    {
        __weak BLCentralsViewController * this = self;
        self.manager.onStatedUpdated=  ^(NSError * error)
        {
            if (this.manager.state == CBPeripheralManagerStatePoweredOn)
            {
                this.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:this action:@selector(addService:)];
                [this.manager startAdvertising:nil onStarted:^(NSError *error) {
                    [this.indicator startAnimating];
                }];
                NSLog(@"powered on!");
            }
        };
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addService:(id)sender
{
     [self performSegueWithIdentifier:@"availableServices" sender:self];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
     CBMutableService * service = self.services[indexPath.row];
      [self.manager removeService:service];
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     __weak BLCentralsViewController * this = self;
     if ([segue.identifier isEqualToString:@"availableServices"])
     {
         BLAvailableServicesViewController * vc  = [(UINavigationController*)segue.destinationViewController viewControllers][0];
         vc.onSelectService =  ^(NSDictionary * service)
         {
             [this addServiceWithDict:service];
         };

     }else
     {
         BLCharacteristicsViewController * vc = segue.destinationViewController;
         vc.isCentralManager = NO;
         vc.service = sender;
         vc.peripheralManager = self.manager;
     }
     
}
- (void)addServiceWithDict:(NSDictionary *) info
{
    CBMutableService * service = [CBMutableService serviceWithDict:info];
    __weak BLCentralsViewController * this = self;
    [self.manager addService:service onFinish:^(CBService *service, NSError *error) {
        this.services = this.manager.services;
        [this.tableView reloadData];
        if (error)
        {
            this.hud.labelText = @"Error";
            this.hud.detailsLabelText = [error localizedDescription];
            [this.hud show:YES];
            [this.hud hide:YES afterDelay:1.4];
        }
    }];
                                  
}

@end
