//
//  BLAvailableServicesViewController.m
//  ble-utility
//
//  Created by Joost Fu on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "BLAvailableServicesViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "GDataXMLNode.h"
#import "CBMutableService+RKBluetoothKit.h"
@interface BLAvailableServicesViewController ()
@property (nonatomic,strong) NSMutableArray * services;
@end

@implementation BLAvailableServicesViewController

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
    [self loadServicesFromXmls];
    [self.tableView reloadData];
	// Do any additional setup after loading the view.
}
- (void)loadServicesFromXmls
{
    NSString * folder = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"servicesdefs"];
    NSFileManager * filer = [NSFileManager defaultManager];
    NSDirectoryEnumerator * enumerator =  [filer enumeratorAtPath: folder];
    NSString * item = nil;
    self.services = [NSMutableArray arrayWithCapacity:30];
    while (item = [enumerator nextObject])
    {
        if ([item hasPrefix:@"org.bluetooth.service"])
        {
            NSData * data = [NSData dataWithContentsOfFile:[folder stringByAppendingPathComponent:item]];
            GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithData:data error:nil];
            if (doc)
            {
                GDataXMLElement * servicexml = [doc rootElement];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
                for (GDataXMLNode * att in servicexml.attributes)
                {
                    dict[att.name] = [att.children[0] XMLString];
                }
                NSArray * characteristicsxml = [servicexml elementsForName:@"Characteristics"];
                if ( [characteristicsxml isKindOfClass:[NSArray class]] && characteristicsxml.count>0)
                {
                    characteristicsxml = [characteristicsxml[0] elementsForName:@"Characteristic"];
                    NSMutableArray * characteristics = [NSMutableArray arrayWithCapacity:characteristicsxml.count];
                    //one characteristic
                    for (GDataXMLElement * characterNode in characteristicsxml)
                    {
                        NSMutableDictionary * nodedict = [NSMutableDictionary dictionaryWithCapacity:10];
                        for (GDataXMLNode * att in characterNode.attributes)
                        {
                            nodedict[att.name] = [att.children[0] XMLString];
                        }
                        //add to array
                        [characteristics addObject:nodedict];
                    }
                    dict[@"characteristics"]=characteristics;
                }

                
                [_services addObject: dict];
            }
        }
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
    return self.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary * service = self.services[indexPath.row];
    cell.textLabel.text =service[@"name"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * service = self.services[indexPath.row];
    self.onSelectService(service);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
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
 }*/

@end
