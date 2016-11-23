//
// Created by Paolo Tagliani on 20/07/16.
// Copyright (c) 2016 Mobile Jazz. All rights reserved.
//

#import "NSArray+Peripherals.h"
#import <CoreBluetooth/CBPeripheral.h>

@implementation NSArray (Peripherals)

- (CBPeripheral *)peripheralWithID:(NSString *)id
{
    for (NSObject *obj in self)
    {
        if ([obj isKindOfClass:[CBPeripheral class]])
        {
            CBPeripheral *peripheral = (CBPeripheral *) obj;
            if ([peripheral.identifier isEqual:[[NSUUID alloc] initWithUUIDString:id]])
            {
                return peripheral;
            }
        }
    }
    return nil;
}

@end
