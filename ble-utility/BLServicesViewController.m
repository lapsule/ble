//
//  BLServicesViewController.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 13-10-29.
//  Copyright (c) 2013年 北京锐和信科技有限公司. All rights reserved.
//

#import "BLServicesViewController.h"
#import "BLCharacteristicsViewController.h"
#import "CBUUID+RKBlueKit.h"


@interface BLServicesViewController ()
@end

@implementation BLServicesViewController

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
    if (self.isCentralManager)
    {
        __weak BLServicesViewController * this  = self;
        
        //# read rssi
        [self.peripheral readRSSIOnFinish:^(NSError *error) {
            this.rssiLabel.text = [this.peripheral.RSSI stringValue];
        }];
        
        //#
        self.hud.labelText = @"discover services";
        [self.hud show:YES];
        [self.peripheral discoverServices:nil onFinish:^(NSError *error) {
            this.services = this.peripheral.services;
            [this.tableView reloadData];
            [this.hud hide:YES afterDelay:0.3];
            DebugLog(@"%@",self.peripheral.services);
        }];
    }else
    {
        [self.tableView reloadData];
    }
    self.title = self.peripheral.name;
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return _services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CBService * service = self.services[indexPath.row];
    UILabel * label = (UILabel*)[cell viewWithTag:19];

    UILabel * uuidLabel = (UILabel *)[cell viewWithTag:20];
    uuidLabel.text = [[service.UUID representativeString] uppercaseString];
    label.text = self.appd.uuidNames[uuidLabel.text][@"name"];
    if (!label.text)
    {
        label.text = @"Unknown";
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBService * service = self.services[indexPath.row];
    [self performSegueWithIdentifier:@"characteristics" sender:service];
}
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BLCharacteristicsViewController * vc = segue.destinationViewController;
    vc.isCentralManager = self.isCentralManager;
    vc.service = sender;
    vc.peripheral = self.peripheral;
}



@end
