//
//  BFBTErrorConstants.h
//  BFBluetoothManager
//
//  Created by Paolo Tagliani on 29/07/16.
//  Copyright © 2016 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BFBTErrorDomain;

typedef NS_ENUM (NSInteger, BFBTErrorCode)
{
    BFBTErrorCodeUnknow,
    BFBTErrorCodeDeviceNotSupported,
    BFBTErrorCodeBluetoothNotAuthorized,
    BFBTErrorCodeDeviceNotConnected,
    BFBTErrorCodeCharacteristicNotExists,
};
