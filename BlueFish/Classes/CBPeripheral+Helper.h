//
//  CBPeripheral+Helper.h
//  BFBluetoothManager
//
// Created by Paolo Tagliani on 13/05/16.
// Copyright (c) 2016 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (Helper)

/**
 Search for a given characteristic inside the peripheral object

 @param characteristicID The ID of the characteristic to search

 @return The characteristic, if found, or nil otherwise
 */
- (CBCharacteristic *)characteristicWithID:(NSString *)characteristicID;


/**
 Search for a given characteristic inside the peripheral object and in the specified service

 @param characteristicID The ID of the characteristic to search
 @param serviceID        The ID of the services to search inside

 @return The characteristic, if found, or nil otherwise
 */
- (CBCharacteristic *)characteristicWithID:(NSString *)characteristicID forServiceID:(NSString *)serviceID;

@end
