//
//  BFErrorConstants.h
//  BFBluetoothManager
//
//  Created by Paolo Tagliani on 29/07/16.
//  Copyright © 2016 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BFErrorDomain;

typedef NS_ENUM (NSInteger, BFErrorCode)
{
    BFErrorCodeUnknow,
    BFErrorCodeDeviceNotSupported,
    BFErrorCodeBluetoothNotAuthorized,
    BFErrorCodeDeviceNotConnected,
    BFErrorCodeCharacteristicNotExists,
};
