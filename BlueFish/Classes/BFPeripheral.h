//
// Copyright 2016 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BFNotificationDelegate <NSObject>

- (void)didNotifyValue:(NSData *)value forCharacteristicID:(NSString *)characteristicID;

@end

@interface BFPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong, readonly) CBPeripheral *BTPeripheral;
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, assign, readonly) BOOL isConnected;

@property (nonatomic, strong, readonly) NSArray <CBService *> *services;
@property (nonatomic, strong, readonly) NSArray <CBCharacteristic *> *characteristics;

@property (nonatomic, weak, readwrite) id <BFNotificationDelegate> notificationDelegate;

#pragma mark - Getters

/**
 *  Quicly get the value of a given characteristic
 *
 *  @param characteristicID The ID of the characteristic to which read for
 *
 *  @return An NSData with the value of the characteristic or nil
 */
- (NSData *)getValueForCharacteristic:(NSString *)characteristicID;

#pragma mark - Setup methods

/**
 *  List all the services and characteristics on the current peripheral. Needs to be called before doing any operation.
 *
 *  @param completionBlock The block to be executed on completion, with the error passed as parameter
 */
- (void)setupPeripheralForUse:(void (^)(NSError *error))completionBlock;

/**
 *  List all the service in the current peripheral.
 *
 *  @param completionBlock The block to be executed on completion
 */
- (void)listServices:(void (^)(NSArray <CBService *> *services, NSError *error))completionBlock;

/**
 *  List all the characteristic of the current peripheral and of all services
 *
 *  @param completionBlock The block to be executed on completion
 */
- (void)listCharacteristics:(void (^)(NSError *error))completionBlock;

#pragma mark - Read methods

/**
 *  Read a single characteristic
 *
 *  @param characteristicID The ID of the characteristic to read
 *  @param completionBlock  The block to be executed on completion
 */
- (void)readCharacteristic:(NSString *)characteristicID completionBlock:(void (^)(NSData *, NSError *))completionBlock;

/**
 *  Read a list of characteristics value
 *
 *  @param characteristicsID An array of characteristics ID to be read
 *  @param completionBlock   A block to be executed on completion
 */
- (void)readCharacteristics:(NSArray <NSString *> *)characteristicsID completionBlock:(void (^)(NSDictionary <NSString *, NSData *> *values, NSError *error))completionBlock;

#pragma mark - Write method

/**
 *  Write a value on a single characteristic
 *
 *  @param characteristicID The characteristic on which write the value
 *  @param data             The data to write
 *  @param completionBlock  A block to be executed on completion
 */
- (void)writeCharacteristic:(NSString *)characteristicID data:(NSData *)data completionBlock:(void (^)(NSError *error))completionBlock;

#pragma mark - Notifications

/**
 *  Subscribe to notification on a given characteristic
 *
 *  @param characteristicID The characteristic ID
 *  @param completionBlock  A block to be executed on completion
 */
- (void)subscribeCharacteristicNotification:(NSString *)characteristicID completionBlock:(void (^)(NSError *error))completionBlock;

@end
