//
//  BLCentralsViewController.m
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "BLCentralsViewController.h"
#import "RKPeripheralManager.h"
#import "BLAvailableServicesViewController.h"
@interface BLCentralsViewController ()
@property (nonatomic,strong) RKPeripheralManager * manager;
@end

@implementation BLCentralsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
   
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.manager = [[RKPeripheralManager alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addService:)];
	// Do any additional setup after loading the view.
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return _manager.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CBService * service = _manager.services[indexPath.row];
    UILabel * label = (UILabel*)[cell viewWithTag:19];
    label.text = [service.UUID description];
    UILabel * uuidLabel = (UILabel *)[cell viewWithTag:20];
    uuidLabel.text = [NSString stringWithFormat:@"%@",service.UUID];
    DebugLog(@"%@",label.text);
    
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


 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     __weak BLCentralsViewController * this = self;
     BLAvailableServicesViewController * vc  = [(UINavigationController*)segue.destinationViewController viewControllers][0];
     vc.onSelectService =  ^(NSDictionary * service)
     {
         [this addServiceWithDict:service];
     };
 }
- (void)addServiceWithDict:(NSDictionary *) info
{
    CBMutableService * service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:[info allKeys][0]] primary:YES];
    NSString * oldTitle = self.title;
    __weak BLCentralsViewController * this = self;
    [self.manager addService:service onFinish:^(CBService *service, NSError *error) {
        [this.tableView reloadData];
    }];
                                  
}

@end
