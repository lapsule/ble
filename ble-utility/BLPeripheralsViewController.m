//
//  BLServiceListViewController.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 13-10-29.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import "BLPeripheralsViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "RKCentralManager.h"
#import "BLServicesViewController.h"
@interface BLPeripheralsViewController ()
@property (nonatomic,strong) RKCentralManager * central;
@end

@implementation BLPeripheralsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)setup
{
    NSDictionary * opts = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
    {
        DebugLog(@"%f",[[UIDevice currentDevice].systemVersion floatValue]);
        opts = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
    }
    self.central = [[RKCentralManager alloc] initWithQueue:nil options:opts];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    self.navigationItem.rightBarButtonItem = self.indicatorItem;
    
    [self.indicator startAnimating];
    
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    __weak BLPeripheralsViewController * wp = self;
    [self.central scanForPeripheralsWithServices:nil options:nil  onUpdated:^(RKPeripheral *peripheral) {
        [wp.tableView reloadData];
    }];
    [self.tableView reloadData];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [self.central stopScan];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return _central.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    RKPeripheral * peripheral = _central.peripherals[indexPath.row] ;
    UILabel * label =(UILabel*) [cell viewWithTag:19];
    label.text = peripheral.name;
    UILabel * rssi =(UILabel*) [cell viewWithTag:20];
//    [peripheral readRSSIOnFinish:^(NSError *error) {
//        rssi.text =[NSString stringWithFormat:@"rssi: %@", [peripheral.RSSI stringValue]];
//    }];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RKPeripheral * peripheral = self.central.peripherals[indexPath.row];
    __weak BLPeripheralsViewController * this = self;
    [self.central connectPeripheral: peripheral options:nil onFinished:^(RKPeripheral * connectedperipheral, NSError *error) {
        if (!error)
        {
            [this performSegueWithIdentifier:@"services" sender: peripheral];
            
        }else
        {
            //error handler here
            DebugLog(@"error when connecting : %@, %@",peripheral,error);
        }
    } onDisconnected:^(RKPeripheral *connectedperipheral, NSError *error) {
        DebugLog(@"disconnected : %@, %@",connectedperipheral,error);
        [this.navigationController popToRootViewControllerAnimated:YES];
    }];
    

}

#pragma mark - peripheral connection
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BLServicesViewController * services = segue.destinationViewController;
    services.peripheral = sender;
}
@end
