ble
===

BLE library for iOS

This lib intends to reduce your work from implementing delegate method with block call backs when developing Bluetooth Low Energy On iOS.

The most benefit is that you don't need delegate methods just make operation you want and put processing code in blocks when it finishes.
And the demo shows the basicly use of it.

----------
Platforms
===

Platform supportted: *iOS7.0 and Above* (with Bluetooth Low Energy supported devices).

### Installation with CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like rkBLE in your projects.

#### Podfile

```ruby
platform :ios, '7.0'
pod "rkBLE", 
```

Structures
-------
The library is located in [ble / ble-utility / RKBluetooth](https://github.com/ruiking/ble/tree/develop/ble-utility/RKBluetooth)

##### <i class="icon-folder-open"></i>Central
**RKCentralManager** is a wrapper for *CBCentralManager* , the method names simplely applys CoreBluetooth's. Ex:

To initialize a central manager:

    - (instancetype) initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *) options;
To scan for peripherals:
    
     - (void)scanForPeripheralsWithServices:(NSArray *)serviceUUIDs options:(NSDictionary *)options onUpdated:(RKPeripheralUpdatedBlock) onUpdate;
you should add your code for process discovered peripherals in block *onUpdate*. 

And use 

    - (void)stopScan;
to stop scanning.

To connect and disconnect a peripheral, use:
    
    - (void)connectPeripheral:(RKPeripheral *)peripheral options:(NSDictionary *)options onFinished:(RKPeripheralConnectionBlock) finished onDisconnected:(RKPeripheralConnectionBlock) disconnected;
    
and
    
    - (void)cancelPeripheralConnection:(RKPeripheral *)peripheral onFinished:(RKPeripheralConnectionBlock) ondisconnected;

**RKPeripheral** is a wrapper for *CBPeripheral*.

To discover services and included services for spcified one,

    - (void)discoverServices:(NSArray *)serviceUUIDs onFinish:(RKObjectChangedBlock) discoverFinished;
    - (void)discoverIncludedServices:(NSArray *)includedServiceUUIDs forService:(CBService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) finished;

Discover Characteristics and Characteristic Descriptors

    - (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) onfinish;
    - (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic onFinish:(RKCharacteristicChangedBlock) onfinish;

Reading Characteristic and Characteristic Descriptor Values

    - (void)readValueForCharacteristic:(CBCharacteristic *)characteristic onFinish:(RKCharacteristicChangedBlock) onUpdate;
    - (void)readValueForDescriptor:(CBDescriptor *)descriptor onFinish:(RKDescriptorChangedBlock) onUpdate;

Writing Characteristic and Characteristic Descriptor Values
    
    - (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type onFinish:(RKCharacteristicChangedBlock) onfinish;
    - (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor onFinish:(RKDescriptorChangedBlock) onfinish;

Setting Notifications for a Characteristic’s Value

    - (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic onUpdated:(RKCharacteristicChangedBlock) onUpdated;

Read RSSI

    - (void)readRSSIOnFinish:(RKObjectChangedBlock) onUpdated;

All callback blocks would be called when the CBPeripheral object calls the delegate method for you operation.

Examples:
    
    reading characteristc value
    
    [self.peripheral readValueForCharacteristic:_characteristic onFinish:^(CBCharacteristic *characteristic, NSError *error) {
            this.valueTextField.text =[_characteristic.value hexadecimalString];
        }];
    
set notify state for characteristic
    
     [self.peripheral setNotifyValue:self.notifySwitch.on forCharacteristic:self.characteristic onUpdated:^(CBCharacteristic *characteristic, NSError *error) {
        this.valueTextField.text =[characteristic.value hexadecimalString];
    }];

----
##### <i class="icon-folder-open"></i>Peripheral
**RKPeripheralManager** is a wrapper for *CBPeripheralManager* , and implements *CBPeripheralManagerDelegate*  methods, turns them into blocks.

Use folowing methods to initilaze a RKPeripheralManager object:

    - (instancetype)initWithQueue:(dispatch_queue_t)queue;
    - (instancetype)initWithQueue:(dispatch_queue_t)queue options:(NSDictionary *)options;

Adding and Removing Services

    - (void)addService:(CBMutableService *)service onFinish:(RKSpecifiedServiceUpdatedBlock) onfinish;
    - (void)removeService:(CBMutableService *)service;
    - (void)removeAllServices;

Managing Advertising, start and stop:

    - (void)startAdvertising:(NSDictionary *)advertisementData onStarted:(RKObjectChangedBlock) onstarted;
    - (void)stopAdvertising;

Sending Updates of a Characteristic’s Value

    - (BOOL)updateValue:(NSData *)value forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:(NSArray *)centrals;

Responding to Read and Write Requests

    - (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result;

Setting Connection Latency

    - (void)setDesiredConnectionLatency:(CBPeripheralManagerConnectionLatency)latency forCentral:(CBCentral *)central;
    
Some callback blocks you should set if you want handle some events,

    RKObjectChangedBlock onStatedUpdated;
    
is used for handle peripheral manager state change, and others

    RKCentralSubscriptionBlock onSubscribedBlock;
    RKCentralSubscriptionBlock onUnsubscribedBlock;
    RKCentralReadRequestBlock onReceivedReadRequest;
    RKCentralWriteRequestBlock onReceivedWriteRequest;
    RKObjectChangedBlock onReadToUpdateSubscribers;

for example , to handle read requests from central devices, and responds to them:

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


---------
