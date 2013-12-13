//
//  RKPeripheral.m
//  ble-utility
//
//  Created by 北京锐和信科技有限公司 on 10/30/13.
//  Copyright (c) 2013 北京锐和信科技有限公司. All rights reserved.
//

#import "RKPeripheral.h"
#import "RKBlueBlocks.h"
@interface RKPeripheral()<CBPeripheralDelegate>
@property (nonatomic,copy) RKObjectChangedBlock didFinishServiceDiscovery;
@property (nonatomic,copy)RKObjectChangedBlock rssiUpdated;
@property (nonatomic,strong) NSMutableDictionary * servicesFindingIncludeService;
@property (nonatomic,strong) NSMutableDictionary * characteristicsDiscoveredBlocks;
@property (nonatomic,strong) NSMutableDictionary * descriptorDiscoveredBlocks;
@property (nonatomic,strong) NSMutableDictionary * characteristicsValueUpdatedBlocks;
@property (nonatomic,strong) NSMutableDictionary * descriptorValueUpdatedBlocks;
@property (nonatomic,strong) NSMutableDictionary * characteristicValueWrtieBlocks;
@property (nonatomic,strong) NSMutableDictionary * descriptorValueWrtieBlocks;
@property (nonatomic,strong) NSMutableDictionary * characteristicsNotifyBlocks;
@end

@implementation RKPeripheral
- (instancetype)initWithPeripheral:(CBPeripheral *) peripheral
{
    self = [super init];
    if (self)
    {
        _peripheral = peripheral;
        _peripheral.delegate = self;
        //#callbacks for finding included services of specified service
        self.servicesFindingIncludeService = [NSMutableDictionary dictionaryWithCapacity:5];
        //
        self.characteristicsDiscoveredBlocks = [NSMutableDictionary dictionaryWithCapacity:5];
        self.descriptorDiscoveredBlocks = [NSMutableDictionary dictionaryWithCapacity:5];
        //# read value callbacks
        self.characteristicsValueUpdatedBlocks =[NSMutableDictionary dictionaryWithCapacity:5];
        self.descriptorValueUpdatedBlocks  =[NSMutableDictionary dictionaryWithCapacity:5];
        //# write value callbacks
        self.characteristicValueWrtieBlocks =[NSMutableDictionary dictionaryWithCapacity:5];
        self.descriptorValueWrtieBlocks =[NSMutableDictionary dictionaryWithCapacity:5];
        
        //#for characteristics notification
        self.characteristicsNotifyBlocks = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

#pragma mark propertys
- (NSString *)name
{
    if (!_name)
    {
        self.name = _peripheral.name;
    }
    return _name;
}
- (NSUUID*)identifier
{
    
    if (!_identifier)
    {
        @try {
            self.identifier = _peripheral.identifier;
        }
        @catch (NSException *exception) {
            // ios6
            NSString * uuidStr =_peripheral.identifier.UUIDString;
            self.identifier = [[NSUUID alloc] initWithUUIDString: uuidStr];
            NSLog(@"solved");
        }
        @finally
        {
            
        }
    }
    return _identifier;
}
- (NSNumber *)RSSI
{
    if (!_RSSI)
    {
        self.RSSI = self.peripheral.RSSI;
    }
    return _RSSI;
}
- (CBPeripheralState )state
{
    return self.peripheral.state;
}
- (BOOL)isEqual:(id)object
{
    return [self.peripheral isEqual: [object peripheral]];
}
#pragma mark discovery services
- (void)discoverServices:(NSArray *)serviceUUIDs onFinish:(RKObjectChangedBlock) discoverFinished
{
    NSAssert(discoverFinished!=nil, @"block finished must'not be nil!");
    self.didFinishServiceDiscovery = discoverFinished;
    [_peripheral discoverServices:serviceUUIDs];
}
- (void)discoverIncludedServices:(NSArray *)includedServiceUUIDs forService:(CBService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) finished
{
    NSAssert(finished!=nil, @"block finished must'not be nil!");
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
    NSAssert(onfinish!=nil, @"block onfinish must'not be nil!");
    _characteristicsDiscoveredBlocks[service.UUID] = onfinish;
    [_peripheral discoverCharacteristics: characteristicUUIDs forService:service];
}
- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic onFinish:(RKCharacteristicChangedBlock) onfinish
{
    NSAssert(onfinish!=nil, @"block onfinish must'not be nil!");
    _descriptorDiscoveredBlocks[characteristic.UUID] = onfinish;
    [_peripheral discoverDescriptorsForCharacteristic: characteristic];
}
#pragma mark Reading Characteristic and Characteristic Descriptor Values
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic onFinish:(RKCharacteristicChangedBlock) onUpdate
{
    NSAssert(onUpdate!=nil, @"block onUpdate must'not be nil!");
    _characteristicsValueUpdatedBlocks[characteristic.UUID] = onUpdate;
    [_peripheral readValueForCharacteristic: characteristic];
}
- (void)readValueForDescriptor:(CBDescriptor *)descriptor onFinish:(RKDescriptorChangedBlock) onUpdate
{
    NSAssert(onUpdate!=nil, @"block onUpdate must'not be nil!");
    _descriptorValueUpdatedBlocks[descriptor.UUID] = onUpdate;
    [_peripheral readValueForDescriptor: descriptor];
}
#pragma mark Writing Characteristic and Characteristic Descriptor Values
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type onFinish:(RKCharacteristicChangedBlock) onfinish
{
    
    if (type == CBCharacteristicWriteWithResponse)
    {
        NSAssert(onfinish!=nil, @"block onfinish must'not be nil!");
        _characteristicValueWrtieBlocks[characteristic.UUID] = onfinish;
    }
    [_peripheral writeValue:data forCharacteristic:characteristic type: type];
}
- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor onFinish:(RKDescriptorChangedBlock) onfinish
{
    if (onfinish)
    {
        _descriptorValueWrtieBlocks[descriptor.UUID] = onfinish;
    }
    [_peripheral writeValue:data forDescriptor:descriptor];
}
#pragma mark Setting Notifications for a Characteristic’s Value

- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic onUpdated:(RKCharacteristicChangedBlock) onUpdated
{
    if (enabled)
    {
        NSAssert(onUpdated!=nil, @"block onUpdated must'not be nil!");
        self.characteristicsNotifyBlocks[characteristic.UUID] = onUpdated;
    }else
    {
        [self.characteristicsNotifyBlocks removeObjectForKey: characteristic.UUID];
    }
    [_peripheral setNotifyValue:enabled forCharacteristic:characteristic];
}

#pragma mark ReadRSSI
- (void)readRSSIOnFinish:(RKObjectChangedBlock) onUpdated
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
    DebugLog(@"%p & %p",peripheral,_peripheral);
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
        }else
        {
            //notifications
            onupdate = self.characteristicsNotifyBlocks[characteristic.UUID];
            if (onupdate)
            {
                onupdate(characteristic,error);
            }
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
        }
    }
}
#pragma mark Writing Characteristic and Characteristic Descriptor Values
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        RKCharacteristicChangedBlock onwrote = _characteristicValueWrtieBlocks[characteristic.UUID];
        if (onwrote)
        {
            onwrote(characteristic,error);
            [_characteristicValueWrtieBlocks removeObjectForKey:characteristic.UUID];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (peripheral == _peripheral)
    {
        RKDescriptorChangedBlock onwrote = _descriptorValueWrtieBlocks[descriptor.UUID];
        if (onwrote)
        {
            onwrote(descriptor,error);
            [_descriptorValueWrtieBlocks removeObjectForKey:descriptor.UUID];
        }

    }
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
        self.RSSI = self.peripheral.RSSI;
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
- (void)dealloc
{
    _peripheral.delegate = nil;
}
@end
