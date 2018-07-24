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

#import "CBPeripheral+BlueFish.h"

@implementation CBPeripheral (BlueFish)

- (CBCharacteristic *)bf_characteristicWithID:(NSString *)characteristicID
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

- (CBCharacteristic *)bf_characteristicWithID:(NSString *)characteristicID forServiceID:(NSString *)serviceID
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
        NSLog(@"Reading characteristic: %@", [characteristic.UUID UUIDString]);
        if ([[characteristic.UUID UUIDString] isEqualToString:characteristicID])
        {
            return characteristic;
        }
    }

    return nil;
}

@end
