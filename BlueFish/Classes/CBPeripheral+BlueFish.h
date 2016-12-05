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

@interface CBPeripheral (BlueFish)

/**
 Search for a given characteristic inside the peripheral object

 @param characteristicID The ID of the characteristic to search

 @return The characteristic, if found, or nil otherwise
 */
- (CBCharacteristic *)bf_characteristicWithID:(NSString *)characteristicID;


/**
 Search for a given characteristic inside the peripheral object and in the specified service

 @param characteristicID The ID of the characteristic to search
 @param serviceID        The ID of the services to search inside

 @return The characteristic, if found, or nil otherwise
 */
- (CBCharacteristic *)bf_characteristicWithID:(NSString *)characteristicID forServiceID:(NSString *)serviceID;

@end
