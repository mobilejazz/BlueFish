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

#import "BFPeripheral.h"
#import "CBPeripheral+BlueFish.h"
#import "NSError+BlueFish.h"
#import "BFErrorConstants.h"

@interface BFPeripheral ()

@property (nonatomic, strong, readwrite) CBPeripheral *BTPeripheral;

/*
 * Completion blocks
 */
@property (nonatomic, copy, readwrite) void (^ BFServiceDiscoveryBlock)(NSArray <CBService *> *services, NSError *error);
@property (nonatomic, copy, readwrite) void (^ BFCharacteristicDiscoveryBlock)(NSError *error);
@property (nonatomic, copy, readwrite) void (^ BFCharacteristicsListReadBlock)(NSDictionary *data, NSError *error);

/*
 * Read/write blocks storage
 */
@property (strong, nonatomic, readwrite) NSMapTable *characteristicReadBlocks;
@property (strong, nonatomic, readwrite) NSMapTable *characteristicWriteBlocks;
@property (strong, nonatomic, readwrite) NSMapTable *characteristicNotificationSubscriptionBlocks;

/*
 * Temp variables
 */
@property (nonatomic, strong, readwrite) NSMutableArray <CBService *> *temporaryServiceArray;
@property (nonatomic, strong, readwrite) NSMutableArray <NSString *> *tempReadCharacteristicsArray;
@property (nonatomic, strong, readwrite) NSMutableDictionary <NSString *, NSData *> *tempReadCharacteristicsValues;

@end

@implementation BFPeripheral

- (instancetype)initWithPeripheral:(CBPeripheral *)btPeripheral
{
    self = [super init];
    if (self)
    {
        _BTPeripheral = btPeripheral;
        _BTPeripheral.delegate = self;

        _characteristicReadBlocks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsCopyIn capacity:10];
        _characteristicWriteBlocks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsCopyIn capacity:10];
        _characteristicNotificationSubscriptionBlocks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsCopyIn capacity:10];
    }

    return self;
}

#pragma mark - Utilities

- (void)setupPeripheralForUse:(void (^)(NSError *error))completionBlock
{
    [self listServices:^(NSArray *services, NSError *servicesError) {
        if (servicesError)
        {
            if (completionBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(servicesError);
                });
            }
            return;
        }
        [self listCharacteristics:^(NSError *characteristicsError) {
            if (completionBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(characteristicsError);
                });
            }
        }];
    }];
}

#pragma mark - Getter

- (NSData *)getValueForCharacteristic:(NSString *)characteristicID
{
    CBCharacteristic *characteristic = [_BTPeripheral bf_characteristicWithID:characteristicID];

    return characteristic.value;
}

- (NSString *)identifier
{
    return [_BTPeripheral.identifier UUIDString];
}

#pragma mark - Public methods

- (BOOL)isConnected
{
    return _BTPeripheral.state == CBPeripheralStateConnected;
}

- (NSArray <CBService *> *)services
{
    return _BTPeripheral.services;
}

- (NSArray <CBCharacteristic *> *)characteristics
{
    NSMutableArray *characteristics = [NSMutableArray array];

    for (CBService *service in _BTPeripheral.services)
    {
        [characteristics addObjectsFromArray:service.characteristics];
    }

    return [NSArray arrayWithArray:characteristics];
}

#pragma mark - Services management

- (void)listServices:(void (^)(NSArray <CBService *> *services, NSError *error))completionBlock
{
    if (_BTPeripheral.state != CBPeripheralStateConnected)
    {
        completionBlock(nil, [NSError bf_createErrorWithDomain:BFErrorDomain code:BFErrorCodeDeviceNotConnected description:nil]);
        return;
    }

    self.BFServiceDiscoveryBlock = completionBlock;
    [_BTPeripheral discoverServices:nil];
}

#pragma mark - Characteristic management

- (void)listCharacteristics:(void (^)(NSError *))completionBlock
{
    self.BFCharacteristicDiscoveryBlock = completionBlock;
    NSArray *services = _BTPeripheral.services;
    self.temporaryServiceArray = [services mutableCopy];

    [self bf_discoverNextCharacteristic];
}

- (void)readCharacteristic:(NSString *)characteristicID completionBlock:(void (^)(NSData *value, NSError *error))completionBlock
{
    [_characteristicReadBlocks setObject:completionBlock forKey:characteristicID];

    CBCharacteristic *characteristic = [_BTPeripheral bf_characteristicWithID:characteristicID];

    if (!characteristic)
    {
        completionBlock(nil, [NSError bf_createErrorWithDomain:BFErrorDomain code:BFErrorCodeCharacteristicNotExists description:nil]);
        return;
    }

    [_BTPeripheral readValueForCharacteristic:characteristic];
}

- (void)readCharacteristics:(NSArray <NSString *> *)characteristicsID completionBlock:(void (^)(NSDictionary <NSString *, NSData *> *values, NSError *error))completionBlock
{
    self.BFCharacteristicsListReadBlock = completionBlock;

    self.tempReadCharacteristicsArray = [characteristicsID mutableCopy];
    self.tempReadCharacteristicsValues = [NSMutableDictionary dictionary];
    [self bf_readNextCharacteristic];
}

- (void)writeCharacteristic:(NSString *)characteristicID data:(NSData *)data completionBlock:(void (^)(NSError *error))completionBlock
{
    [_characteristicWriteBlocks setObject:completionBlock forKey:characteristicID];
    CBCharacteristic *characteristic = [_BTPeripheral bf_characteristicWithID:characteristicID];
    if (!characteristic)
    {
        completionBlock([NSError bf_createErrorWithDomain:BFErrorDomain code:BFErrorCodeCharacteristicNotExists description:nil]);
        return;
    }

    [_BTPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)subscribeCharacteristicNotification:(NSString *)characteristicID completionBlock:(void (^)(NSError *error))completionBlock
{
    [_characteristicNotificationSubscriptionBlocks setObject:completionBlock forKey:characteristicID];
    CBCharacteristic *characteristic = [_BTPeripheral bf_characteristicWithID:characteristicID];

    [_BTPeripheral setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)unsubscribeCharacteristicNotification:(NSString *)characteristicID
{
    CBCharacteristic *characteristic = [_BTPeripheral bf_characteristicWithID:characteristicID];

    [_BTPeripheral setNotifyValue:NO forCharacteristic:characteristic];
    [_characteristicNotificationSubscriptionBlocks setObject:nil forKey:characteristicID];
}

#pragma mark - Private methods

- (void)bf_discoverNextCharacteristic
{
    if (self.temporaryServiceArray.count != 0)
    {
        CBService *service = [self.temporaryServiceArray lastObject];
        [_BTPeripheral discoverCharacteristics:nil forService:service];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        if (_BFCharacteristicDiscoveryBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.BFCharacteristicDiscoveryBlock(nil);
            });
        }
    }
}

- (void)bf_readNextCharacteristic
{
    if (_tempReadCharacteristicsArray.count != 0)
    {
        CBCharacteristic *characteristic = [_BTPeripheral bf_characteristicWithID:[_tempReadCharacteristicsArray lastObject]];
        [_BTPeripheral readValueForCharacteristic:characteristic];
    }
    else
    {
        self.tempReadCharacteristicsArray = nil;
        NSDictionary *values = [_tempReadCharacteristicsValues copy];

        if (_BFCharacteristicsListReadBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _BFCharacteristicsListReadBlock(values, nil);
            });
        }
    }
}

#pragma mark BTPeripheralDelegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray *services = error ? nil : peripheral.services;

    if (_BFServiceDiscoveryBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _BFServiceDiscoveryBlock(services, error);
        });
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        if (_BFCharacteristicDiscoveryBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _BFCharacteristicDiscoveryBlock(error);
            });
        }
    }
    else
    {
        [_temporaryServiceArray removeLastObject];
        [self bf_discoverNextCharacteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Check if it's a sequencial reading
    if (_tempReadCharacteristicsArray.count != 0 && [_tempReadCharacteristicsArray containsObject:[characteristic.UUID UUIDString]])
    {
        if (error)
        {
            NSDictionary *values = [_tempReadCharacteristicsValues copy];

            if (_BFCharacteristicsListReadBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _BFCharacteristicsListReadBlock(values, error);
                });
            }
            return;
        }

        _tempReadCharacteristicsValues[[characteristic.UUID UUIDString]] = characteristic.value;
        [_tempReadCharacteristicsArray removeObject:[characteristic.UUID UUIDString]];
        [self bf_readNextCharacteristic];
        return;
    }

    // Check if there's a single reading goind on, otherwise it's a notification
    void (^ characteristicReadBLock)(NSData *data, NSError *readError) = [_characteristicReadBlocks objectForKey:[characteristic.UUID UUIDString]];
    if (!characteristicReadBLock)
    { // It's a notification and need to be updated asynchronously
        if ([_notificationDelegate respondsToSelector:@selector(peripheral:didNotifyValue:forCharacteristicID:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_notificationDelegate peripheral:self didNotifyValue:characteristic.value forCharacteristicID:[characteristic.UUID UUIDString]];
            });
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            characteristicReadBLock(characteristic.value, error);
        });
        [_characteristicReadBlocks removeObjectForKey:[characteristic.UUID UUIDString]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    void (^ notificationBlock)(NSError *errorSubscription) = [_characteristicNotificationSubscriptionBlocks objectForKey:[characteristic.UUID UUIDString]];
    if (notificationBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            notificationBlock(error);
            [_characteristicNotificationSubscriptionBlocks removeObjectForKey:[characteristic.UUID UUIDString]];
        });
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    void (^ writeBlock)(NSError *writeError) = [_characteristicWriteBlocks objectForKey:[characteristic.UUID UUIDString]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (writeBlock)
        {
            writeBlock(error);
        }
    });
    [_characteristicWriteBlocks removeObjectForKey:[characteristic.UUID UUIDString]];
}

@end
