//
// Created by Paolo Tagliani on 20/07/16.
// Copyright (c) 2016 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

@interface NSArray (Peripherals)

- (CBPeripheral *)peripheralWithID:(NSString *)id;

@end
