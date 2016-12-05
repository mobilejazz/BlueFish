//
//  CBPeripheral+Helper.m
//  BFBluetoothManager
//
// Created by Paolo Tagliani on 13/05/16.
// Copyright (c) 2016 Mobile Jazz. All rights reserved.
//

#import "CBPeripheral+Helper.h"

@implementation CBPeripheral (Helper)

- (BOOL)isInitializedData
{
    return self.services != nil;
}

- (CBCharacteristic *)characteristicWithID:(NSString *)characteristicID
{
    for (CBService *service in self.services)
    {
        CBCharacteristic *characteristic = [self bf_characteristicWithID:characteristicID inService:service];

        if (characteristic)
        {
            return characteristic;
        }

    }
    return nil;
}

- (CBCharacteristic *)characteristicWithID:(NSString *)characteristicID forServiceID:(NSString *)serviceID
{
    CBService *service = [self bf_serviceWithID:serviceID];
    return [self bf_characteristicWithID:characteristicID inService:service];
}

#pragma mark - Private methods

- (CBService *)bf_serviceWithID:(NSString *)serviceID
{
    for (CBService *service in self.services)
    {
        if ([[service.UUID UUIDString] isEqualToString:serviceID])
        {
            return service;
        }
    }

    return nil;
}

- (CBCharacteristic *)bf_characteristicWithID:(NSString *)characteristicID inService:(CBService *)service
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([[characteristic.UUID UUIDString] isEqualToString:characteristicID])
        {
            return characteristic;
        }
    }

    return nil;
}

@end
