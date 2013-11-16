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
@property (nonatomic,weak) NSTimer  * timer;
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
    self.navigationItem.title = @"Peripherals";
    NSDictionary * opts = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
    {
        DebugLog(@"%f",[[UIDevice currentDevice].systemVersion floatValue]);
        opts = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
    }
    self.central = [[RKCentralManager alloc] initWithQueue:nil options:opts];
    self.navigationItem.rightBarButtonItem = self.indicatorItem;
   
    __weak BLPeripheralsViewController * wp = self;
    if (self.central.state != CBCentralManagerStatePoweredOn)
    {
        self.central.onStateChanged = ^(NSError * error){
            [wp.indicator startAnimating];
            [wp.central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}  onUpdated:^(RKPeripheral *peripheral) {
                [wp.tableView reloadData];
            }];
        };
        
    }
    [self.tableView reloadData];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //timer for rssi reading
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(updateRSSI:) userInfo:nil repeats:YES];
//    [self.timer fire];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    [self.timer invalidate];
//    [self.central stopScan];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateRSSI:(NSTimer *) t
{
    __weak BLPeripheralsViewController *this = self;
    int i =0;
    for (RKPeripheral * peripheral in self.central.peripherals)
    {
        if (peripheral.state == CBPeripheralStateConnected)
        {
            [peripheral readRSSIOnFinish:^(NSError *error) {
                UITableViewCell * cell = [this.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                UILabel * rssiLabel = (UILabel *)[cell viewWithTag:22];
                rssiLabel.text = [peripheral.RSSI stringValue];
            }];
        }
        
        ++i;
    }
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
    UILabel * idLable =(UILabel*) [cell viewWithTag:20];
    idLable.text = peripheral.identifier.UUIDString;
    UILabel * rssiLabel = (UILabel *)[cell viewWithTag:22];
    rssiLabel.text = [peripheral.RSSI stringValue];
    [peripheral readRSSIOnFinish:^(NSError *error) {
        rssiLabel.text = [peripheral.RSSI stringValue];
    }];
    
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
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    if(peripheral.state == CBPeripheralStateDisconnected)
    {
        self.hud.labelText = @"";
        self.hud.detailsLabelText = @"connecting ...";
        [self.hud show:YES];
        [self.central connectPeripheral: peripheral options:nil onFinished:^(RKPeripheral * connectedperipheral, NSError *error) {
            if (!error)
            {
                [this performSegueWithIdentifier:@"services" sender: peripheral];
                [this.hud hide:NO];
            }else
            {
                //error handler here
                DebugLog(@"error when connecting : %@, %@",peripheral,error);
                this.hud.labelText = @"connect failed!";
                this.hud.detailsLabelText = [error localizedDescription];
                [this.hud hide:YES afterDelay:0.4];
            }
            
        } onDisconnected:^(RKPeripheral *connectedperipheral, NSError *error) {
            DebugLog(@"disconnected : %@, %@",connectedperipheral,error);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray * vcs  = [this.navigationController viewControllers];
                BLTableViewController * top = vcs[vcs.count-1];
                [top.hud show:YES];
                top.hud.labelText = @"disconnected!";
                top.hud.detailsLabelText = [error localizedDescription];
                [top.hud hide:YES afterDelay:0.7];
            });
            
        }];
    }else
    {
        [self performSegueWithIdentifier:@"services" sender: peripheral];
    }
    
}

#pragma mark - peripheral connection
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BLServicesViewController * services = segue.destinationViewController;
    services.isCentralManager = YES;
    services.peripheral = sender;
}
@end
