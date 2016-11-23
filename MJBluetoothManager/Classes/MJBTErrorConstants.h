//
//  MJBTErrorConstants.h
//  MJBluetoothManager
//
//  Created by Paolo Tagliani on 29/07/16.
//  Copyright © 2016 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const MJBTErrorDomain;

typedef NS_ENUM (NSInteger, MJBTErrorCode)
{
    MJBTErrorCodeUnknow,
    MJBTErrorCodeDeviceNotSupported,
    MJBTErrorCodeBluetoothNotAuthorized,
    MJBTErrorCodeDeviceNotConnected,
    MJBTErrorCodeCharacteristicNotExists,
};
