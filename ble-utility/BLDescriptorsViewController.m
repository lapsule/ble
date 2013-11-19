//
//  BLDescriptorsViewController.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 11/10/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "BLDescriptorsViewController.h"
#import "RKBlueKit.h"
#import "CBUUID+RKBlueKit.h"
#import "NSData+Hex.h"

@interface BLDescriptorsViewController ()<UITextFieldDelegate>

@end

@implementation BLDescriptorsViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"read" style:UIBarButtonItemStylePlain target:self action:@selector(read:)];
}
- (void)read:(id)sender
{
    if (self.isCentralManager)
    {
        __weak BLDescriptorsViewController * this = self;
        [self.peripheral readValueForCharacteristic:_characteristic onFinish:^(CBCharacteristic *characteristic, NSError *error) {
            this.valueTextField.text =[_characteristic.value hexadecimalString];
        }];
        
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.notifySwitch.hidden = YES;
    self.notifyLabel.hidden = YES;
    //title
    NSString *uuid = [[self.characteristic.UUID representativeString] uppercaseString];
    self.title =self.appd.uuidNames[uuid][@"name"]; ;
    //
    __weak BLDescriptorsViewController * this = self;
    this.valueTextField.text =[_characteristic.value hexadecimalString];
    if (self.isCentralManager)
    {
        [self.hud show:YES];
        self.hud.labelText = @"discovering descriptors";
        self.hud.detailsLabelText = @"";
        [self.peripheral discoverDescriptorsForCharacteristic:_characteristic onFinish:^(CBCharacteristic *characteristic, NSError *error) {
            [this.tableView reloadData];
            float delay =0.3;
            if (error)
            {
                NSLog(@"%@",error);
                delay = 1.5;
                this.hud.detailsLabelText = [error localizedDescription];
            }
            [this.hud hide:YES afterDelay:delay];
        }];
        [self.peripheral readValueForCharacteristic:_characteristic onFinish:^(CBCharacteristic *characteristic, NSError *error) {
            this.valueTextField.text =[_characteristic.value hexadecimalString];
        }];
      
    }else
    {
        [self.tableView reloadData];
        self.peripheralManager.onReceivedReadRequest = ^(CBATTRequest * readRequest)
        {
            if ([readRequest.characteristic.UUID isEqual:this.characteristic.UUID])
            {
                readRequest.value = [this.characteristic.value
                                 subdataWithRange:NSMakeRange(readRequest.offset,
                                                              this.characteristic.value.length - readRequest.offset)];
                [this.peripheralManager respondToRequest:readRequest withResult: CBATTErrorSuccess];
            }else
            {
                [this.peripheralManager respondToRequest:readRequest withResult: CBATTErrorInvalidAttributeValueLength];
            }
            
        };
        self.peripheralManager.onReceivedWriteRequest = ^(NSArray * requests){
            for (CBATTRequest * request in requests)
            {
                this.valueTextField.text =  [request.value hexadecimalString];
                [this.peripheralManager respondToRequest: request withResult:CBATTErrorSuccess];
                break;
            }
            
        };
    }
    //check if write supportted
    if ((_characteristic.properties &CBCharacteristicPropertyWrite) !=0 || (_characteristic.properties &CBCharacteristicPropertyWriteWithoutResponse) !=0)
    {
        self.valueTextField.enabled = self.isCentralManager;
    }else
    {
        self.valueTextField.enabled = !self.isCentralManager;
    }
    self.valueTextField.borderStyle =self.valueTextField.enabled ? UITextBorderStyleRoundedRect:UITextBorderStyleNone;
    //check  if notify
    if ((_characteristic.properties & CBCharacteristicPropertyNotify))
    {
        if (self.isCentralManager)
        {
            self.notifySwitch.on = NO;
            self.notifySwitch.hidden = NO;
            self.notifyLabel.hidden = NO;
        }else
        {
            self.notifySwitch.hidden  = YES;
            self.notifyLabel.hidden = YES;
            self.peripheralManager.onSubscribedBlock= ^(CBCentral * central,CBCharacteristic * characteristic){
                if (characteristic == this.characteristic)
                {
                    this.hud.labelText = @"central subscribed";
                    this.hud.detailsLabelText =[NSString stringWithFormat: @"%@",central.identifier];
                    [this.hud show:YES];
                    [this.hud hide:YES afterDelay:1.3];
                }
            };

        }
        
    }
    //labels
    self.properties.text =[ [RKBlueKit propertiesFrom: _characteristic.properties] componentsJoinedByString:@","];
    self.uuidLabel.text = [_characteristic.UUID representativeString];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillDisappear:(BOOL)animated
{
    //check  if notify
    if ((_characteristic.properties & CBCharacteristicPropertyNotify))
    {
        [self.peripheral setNotifyValue:NO forCharacteristic:self.characteristic onUpdated:nil];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    if (_characteristic.isNotifying)
    {
        if (self.isCentralManager)
        {
            [self.peripheral setNotifyValue:NO forCharacteristic:self.characteristic onUpdated:^(CBCharacteristic *characteristic, NSError *error) {
            }];
        }
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
    return _characteristic.descriptors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CBDescriptor * descriptor = self.characteristic.descriptors[indexPath.row];
    UILabel * label = (UILabel*)[cell viewWithTag:19];
    NSString * uuid = [[[descriptor UUID] representativeString] uppercaseString];
    label.text = self.appd.uuidNames[uuid][@"name"];
    if (!label.text)
    {
        label.text = @"Unknown";
    }
    UILabel * uuidLabel = (UILabel *)[cell viewWithTag:20];
    uuidLabel.text = uuid;
//    [self.peripheral readValueForDescriptor:descriptor onFinish:^(CBDescriptor *tdescriptor, NSError *error) {
//        uuidLabel.text =[NSString stringWithFormat:@"value:%@", tdescriptor.value];
//    }];
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section ==0)
    {
        return [NSString stringWithFormat: @"%lu descriptors",(unsigned long)self.characteristic.descriptors.count];
    }
    return nil;
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    __weak BLDescriptorsViewController * this = self;
    NSData * data = [NSData  dataWithHexString: textField.text ];
    if (data)
    {
        if (self.isCentralManager)
        {
            CBCharacteristicWriteType type =CBCharacteristicWriteWithResponse;
            RKCharacteristicChangedBlock onfinish=nil;
            if ((_characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) !=0)
            {
                type = CBCharacteristicWriteWithoutResponse;
            }else
            {
                self.hud.labelText = @"writing walue ...";
                self.hud.detailsLabelText=@"";
                [self.hud show: YES];
                onfinish = ^(CBCharacteristic * characteristic, NSError * error)
                {
                    DebugLog(@"write response %@",error);
                    float delay =0.3;
                    if (error)
                    {
                        NSLog(@"%@",error);
                        delay = 1.5;
                        this.hud.detailsLabelText = [error localizedDescription];
                    }
                    [this.hud hide:YES afterDelay:delay];
                };
            }
            
            [self.peripheral writeValue:data forCharacteristic:_characteristic type:type onFinish:onfinish];
        }else
        {
            [(CBMutableCharacteristic *)self.characteristic setValue:data ] ;
            if ((_characteristic.properties & CBCharacteristicPropertyNotify))
            {
                [self.peripheralManager updateValue:data forCharacteristic:(CBMutableCharacteristic*)self.characteristic onSubscribedCentrals:nil];
            }
        }
    }
        [textField resignFirstResponder];
    return YES;
}

- (IBAction)changeNotifyState:(id)sender {
    __weak BLDescriptorsViewController * this = self;
    [self.peripheral setNotifyValue:self.notifySwitch.on forCharacteristic:self.characteristic onUpdated:^(CBCharacteristic *characteristic, NSError *error) {
        this.valueTextField.text =[characteristic.value hexadecimalString];
    }];
}
@end
