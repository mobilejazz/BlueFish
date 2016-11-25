![MJBluetoothManager](https://raw.githubusercontent.com/mobilejazz/metadata/master/images/banners/mobile-jazz-bluefish-ios.jpg)
# ![Mobile Jazz Badge](https://raw.githubusercontent.com/mobilejazz/metadata/master/images/icons/mj-40x40.png) MJBluetoothManager

[![CI Status](http://img.shields.io/travis/Paolo Tagliani/MJBluetoothManager.svg?style=flat)](https://travis-ci.org/Paolo Tagliani/MJBluetoothManager)
[![Version](https://img.shields.io/cocoapods/v/MJBluetoothManager.svg?style=flat)](http://cocoapods.org/pods/MJBluetoothManager)
[![License](https://img.shields.io/cocoapods/l/MJBluetoothManager.svg?style=flat)](http://cocoapods.org/pods/MJBluetoothManager)
[![Platform](https://img.shields.io/cocoapods/p/MJBluetoothManager.svg?style=flat)](http://cocoapods.org/pods/MJBluetoothManager)



#MJBluetoothManager

> CoreBluetooth with block-based APIs

MJBluetoothManager is a wrapper around CoreBluetooth concepts like CBCentralManager and CBPeripheral. All the delegate based API are substituted with blocks.

## Installation

MJBluetoothManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MJBluetoothManager"
```

## Basic Usage
The main objects to interact with are **MJBTCentralManager** and **MJBTPeripheral**.

### MJBTCentralManager

This object is responsible for:

- Scanning for nearby bluetooth devices (with filters)
- Connecting/disconnecting to bluetooth peripheral
- Retrieve bluetooth peripherals from Core Bluetooth cache

Example of use:

```objective-c

    NSString *deviceID = @"hdl83h6sd-gl95-bn4f-37gd-jd73hd0tn8za";
    MJBTCentralManager *manager = [[MJBTCentralManager alloc] init];
    MJBTPeripheral *peripheral = [manager retrievePeripheralWithID:deviceID];
    if (peripheral)
    {
        //Peripheral found in cache, connect
        [manager connectToPeripheral:peripheral completionBlock:^(NSError *error) {
            //TODO: Manage error or do operation on peripheral
        }];
        return;
    }
    
    //If not in cache, search for it in the nearby area
    [manager startScanningWithUpdateBlock:^(MJBTPeripheral *peripheral, NSError *error) {
        if ([peripheral.identifier isEqualToString:deviceID])
        {
            //Stop Scan
            [manager stopScanning];
            
            //Connect to peripheral
            [manager connectToPeripheral:peripheral completionBlock:^(NSError *error) {
                //TODO: Manage error or do operation on peripheral
            }];
        }
    }];
``` 

### MJBTPeripheral

This object represents a peripheral, and is responsible for:

- Discovering services and characteristics
- Subscription to notification
- Read/write from/to characteristics
- Notification handling

#### Service and characteristic discovery

After connection, a peripheral does not hold information about characteristics and discovery. To make it ready to use the method `- (void)setupPeripheralForUse:(void (^)(NSError *error))completionBlock` must be called.

```objective-c
//Global discovery
    [peripheral setupPeripheralForUse:^(NSError *error) {
        NSLog(@"Peripheral services: %@", peripheral.services.description);
        NSLog(@"Peripheral characteristics: %@", peripheral.characteristics.description);
    }];
    
    //Alternative version
    [peripheral listServices:^(NSArray<CBService *> *services, NSError *error) {
        NSLog(@"Peripheral services: %@", peripheral.services.description);
        
        [peripheral listCharacteristics:^(NSError *error) {
            NSLog(@"Peripheral characteristics: %@", peripheral.characteristics.description);
        }];
    }];
``` 
#### Read and write characteristics

```objective-c
NSString *characteristicID = @"sd2343h6sd-gl95-bn4f-37gd-jd73hd0tn8za";
    NSData *data = [@"Mobile Jazz" dataUsingEncoding:NSUTF8StringEncoding];
    
    [peripheral writeCharacteristic:characteristicID data:data completionBlock:^(NSError *error) {
       //Handle error if needed ....
    }];
    
    [peripheral readCharacteristic:characteristicID completionBlock:^(NSData *data, NSError *error) {
       //Handle error if needed ....
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", string); //Mobile Jazz
    }];
``` 

#### Notifications

We can subscribe to a peripheral notification on a characteristic value change. When the value changes, the peripheral will notify its notificationDelegate.

```objective-c
    NSString *characteristicID = @"sd2343h6sd-gl95-bn4f-37gd-jd73hd0tn8za";
    peripheral.notificationDelegate = self;
    
    [peripheral subscribeCharacteristicNotification:characteristicID completionBlock:^(NSError *error) {
        //Handle error if needed ....
    }];
    
#pragma mark - MJBTNotificationDelegate
    
    - (void)didNotifiedValue:(NSData *)value forCharacteristicID:(NSString *)characteristicID
    {
        NSLog(@"Received: %@ from characteristic:%@", [value description], characteristicID);
    }
``` 

## Author

Paolo Tagliani, paolo@mobilejazz.com

## TODO

- [] Create example application

## License

MJBluetoothManager is available under the MIT license. See the LICENSE file for more info.
