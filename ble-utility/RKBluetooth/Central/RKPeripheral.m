//
//  RKPeripheral.m
//  ble-utility
//
//  Created by Joost Fu on 10/30/13.
//  Copyright (c) 2013 joost. All rights reserved.
//

#import "RKPeripheral.h"
@interface RKPeripheral()<CBPeripheralDelegate>
@property (nonatomic,strong) RKPeripheralChangedBlock didFinishServiceDiscovery;
@property (nonatomic,strong) NSMutableDictionary * servicesFindingIncludeService;
@property (nonatomic,strong)RKPeripheralChangedBlock rssiUpdated;
@end
@implementation RKPeripheral
- (instancetype)initWithPeripheral:(CBPeripheral *) peripheral
{
    self = [super init];
    if (self)
    {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        self.servicesFindingIncludeService = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}
- (BOOL) isEqual:(id)object
{
    return [_peripheral isEqual: [object peripheral]];
}
#pragma mark propertys
- (NSString *)name
{
    return _peripheral.name;
}
- (NSUUID*)identifier
{
    return _peripheral.identifier;
}
#pragma mark discovery
- (void)discoverServices:(NSArray *)serviceUUIDs onFinish:(RKPeripheralChangedBlock) discoverFinished
{
    self.didFinishServiceDiscovery = discoverFinished;
    [_peripheral discoverServices:serviceUUIDs];
}
- (void)discoverIncludedServices:(NSArray *)includedServiceUUIDs forService:(CBService *)service onFinish:(RKIncluedServiceBlock) finished
{
    _servicesFindingIncludeService[service.UUID]=finished;
    [_peripheral discoverIncludedServices: includedServiceUUIDs forService:service];
}
#pragma mark ReadRSSI
- (void)readRSSIOnFinish:(RKPeripheralChangedBlock) onUpdated
{
    self.rssiUpdated = onUpdated;
    [_peripheral readRSSI];
}
- (NSArray*)services
{
    return _peripheral.services;
}
#pragma mark - Delegate
#pragma mark service discovery
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        self.didFinishServiceDiscovery(error);
        
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        RKIncluedServiceBlock onfound = _servicesFindingIncludeService[service.UUID];
        if (onfound)
        {
            onfound(service,error);
            [_servicesFindingIncludeService removeObjectForKey:service.UUID];
        }
    }
}
#pragma mark Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}
#pragma mark Retrieving Characteristic and Characteristic Descriptor Values
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}
#pragma mark Writing Characteristic and Characteristic Descriptor Values
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}
#pragma mark Managing Notifications for a Characteristic’s Value
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}
#pragma mark Retrieving a Peripheral’s Received Signal Strength Indicator (RSSI) Data
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        self.rssiUpdated(error);
    }
    
}
#pragma mark Monitoring Changes to a Peripheral’s Name or Services
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    
}
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    
}
@end
