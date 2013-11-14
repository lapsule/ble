//
//  BLCharacteristicsViewController.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "BLCharacteristicsViewController.h"
#import "BLDescriptorsViewController.h"
#import "RKBlueKit.h"
#import "CBUUID+RKBlueKit.h"

@interface BLCharacteristicsViewController ()

@end

@implementation BLCharacteristicsViewController

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
        self.navigationItem.rightBarButtonItem = self.indicatorItem;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *uuid = [[self.service.UUID representativeString] uppercaseString];
    self.title =self.appd.uuidNames[uuid][@"name"]; ;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewDidAppear:(BOOL)animated
{
    __weak BLCharacteristicsViewController * this = self;
    if (self.isCentralManager)
    {
        [self.indicator startAnimating];
        [self.peripheral discoverCharacteristics:nil forService: _service onFinish:^(CBService *service, NSError *error) {
            if (service == _service)
            {

                [this.tableView reloadData];
                [this.indicator stopAnimating];
            }
        }];
    }else
    {
        [self.tableView reloadData];
    }
   
    
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
    return _service.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CBCharacteristic * characteristic = _service.characteristics[indexPath.row];
    UILabel * label = (UILabel*)[cell viewWithTag:19];
    UILabel * uuidLabel = (UILabel *)[cell viewWithTag:20];
    uuidLabel.text = [[characteristic.UUID representativeString] uppercaseString];
    label.text = self.appd.uuidNames[uuidLabel.text][@"name"];
    if (!label.text)
    {
        label.text = @"Unknown";
    }
    UILabel * propertyLabel = (UILabel *)[cell viewWithTag:21];
    propertyLabel.text = [[RKBlueKit propertiesFrom: characteristic.properties] componentsJoinedByString:@","];

    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * title = nil;
    if (section ==0)
    {
        title = [NSString stringWithFormat:@"%lu characteristics",(unsigned long)self.service.characteristics.count];
    }
    return title;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0)
    {
        return 30;
    }
    return 0;
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
    CBCharacteristic * characteristic = _service.characteristics[indexPath.row];
    [self performSegueWithIdentifier:@"descriptors" sender:characteristic];
}
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BLDescriptorsViewController * vc = segue.destinationViewController;
    vc.isCentralManager = self.isCentralManager;
    vc.peripheral = self.peripheral;
    vc.characteristic = sender;
    vc.peripheralManager = self.peripheralManager;
}



@end
