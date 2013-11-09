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
@property (nonatomic,strong)RKPeripheralChangedBlock rssiUpdated;
@property (nonatomic,strong) RKCharacteristicChangedBlock onCharacteristicsValueUpdated;
@property (nonatomic,strong) RKDescriptorChangedBlock onDescriptorsValueUpdated;
@property (nonatomic,strong) NSMutableDictionary * servicesFindingIncludeService;
@property (nonatomic,strong) NSMutableDictionary * characteristicsDiscoveredBlocks;
@property (nonatomic,strong) NSMutableDictionary * descriptorDiscoveredBlocks;
@property (nonatomic,strong) NSMutableDictionary * characteristicsValueUpdatedBlocks;
@property (nonatomic,strong) NSMutableDictionary * descriptorValueUpdatedBlocks;
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
        self.characteristicsDiscoveredBlocks = [NSMutableDictionary dictionaryWithCapacity:20];
        self.descriptorDiscoveredBlocks = [NSMutableDictionary dictionaryWithCapacity:20];
        self.characteristicsValueUpdatedBlocks =[NSMutableDictionary dictionaryWithCapacity:20];
        self.descriptorValueUpdatedBlocks  =[NSMutableDictionary dictionaryWithCapacity:20];
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
#pragma mark discovery services
- (void)discoverServices:(NSArray *)serviceUUIDs onFinish:(RKPeripheralChangedBlock) discoverFinished
{
    self.didFinishServiceDiscovery = discoverFinished;
    [_peripheral discoverServices:serviceUUIDs];
}
- (void)discoverIncludedServices:(NSArray *)includedServiceUUIDs forService:(CBService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) finished
{
    _servicesFindingIncludeService[service.UUID]=finished;
    [_peripheral discoverIncludedServices: includedServiceUUIDs forService:service];
}
- (NSArray*)services
{
    return _peripheral.services;
}
#pragma mark Discovering Characteristics and Characteristic Descriptors
- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) onfinish
{
    _characteristicsDiscoveredBlocks[service.UUID] = onfinish;
    [_peripheral discoverCharacteristics: characteristicUUIDs forService:service];
}
- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic onFinish:(RKCharacteristicChangedBlock) onfinish
{
    _descriptorDiscoveredBlocks[characteristic.UUID] = onfinish;
    [_peripheral discoverDescriptorsForCharacteristic: characteristic];
}
#pragma mark Reading Characteristic and Characteristic Descriptor Values
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic onFinish:(RKCharacteristicChangedBlock) onUpdate
{
    _characteristicsValueUpdatedBlocks[characteristic.UUID] = onUpdate;
    [_peripheral readValueForCharacteristic: characteristic];
}
- (void)readValueForDescriptor:(CBDescriptor *)descriptor onFinish:(RKDescriptorChangedBlock) onUpdate
{
    _descriptorValueUpdatedBlocks[descriptor.UUID] = onUpdate;
    [_peripheral readValueForDescriptor: descriptor];
}
#pragma mark ReadRSSI
- (void)readRSSIOnFinish:(RKPeripheralChangedBlock) onUpdated
{
    self.rssiUpdated = onUpdated;
    [_peripheral readRSSI];
}

#pragma mark - Delegate
#pragma mark service discovery
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        self.didFinishServiceDiscovery(error);
        self.didFinishServiceDiscovery = nil;
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        RKSpecifiedServiceUpdatedBlock onfound = _servicesFindingIncludeService[service.UUID];
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
    if (peripheral == _peripheral)
    {
        RKSpecifiedServiceUpdatedBlock onfound = _characteristicsDiscoveredBlocks[service.UUID];
        if (onfound)
        {
            onfound(service,error);
            [_characteristicsDiscoveredBlocks removeObjectForKey: service.UUID];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        RKCharacteristicChangedBlock onfound = _descriptorDiscoveredBlocks[characteristic.UUID];
        if (onfound)
        {
            onfound(characteristic,error);
            [_descriptorDiscoveredBlocks removeObjectForKey: characteristic.UUID];
        }
    }
}
#pragma mark Retrieving Characteristic and Characteristic Descriptor Values
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        RKCharacteristicChangedBlock onupdate = _characteristicsValueUpdatedBlocks[characteristic.UUID];
        if (onupdate)
        {
            onupdate(characteristic,error);
            [_characteristicsValueUpdatedBlocks removeObjectForKey: characteristic.UUID];
        }else if(self.onCharacteristicsValueUpdated)
        {
            self.onCharacteristicsValueUpdated(characteristic,error);
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        RKDescriptorChangedBlock onupdate = _descriptorValueUpdatedBlocks[descriptor.UUID];
        if (onupdate)
        {
            onupdate(descriptor,error);
            [_descriptorValueUpdatedBlocks removeObjectForKey:descriptor.UUID];
        }else if(self.onDescriptorsValueUpdated)
        {
            self.onDescriptorsValueUpdated(descriptor,error);
        }
    }
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
    if (peripheral == _peripheral && self.notificationStateChanged)
    {
        self.notificationStateChanged(characteristic,error);
    }
}
#pragma mark Retrieving a Peripheral’s Received Signal Strength Indicator (RSSI) Data
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        self.rssiUpdated(error);
        self.rssiUpdated = nil;
    }
    
}
#pragma mark Monitoring Changes to a Peripheral’s Name or Services
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    if (peripheral == _peripheral && self.onServiceModified)
    {
        self.onServiceModified(invalidatedServices);
    }
}
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    if (peripheral == _peripheral && self.onNameUpdated)
    {
        self.onNameUpdated(nil);
    }
}
@end
