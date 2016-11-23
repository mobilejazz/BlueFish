//
//  MJBTPeripheral_Private.h
//  Pods
//
//  Created by Paolo Tagliani on 23/11/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MJBTPeripheral.h"

@interface MJBTPeripheral ()

/**
 *  Designated initializers
 *
 *  @param btPeripheral The CBPeripheral
 *
 *  @return A newly instantiated instance
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)btPeripheral;

@end
