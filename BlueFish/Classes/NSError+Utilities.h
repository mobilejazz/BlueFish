//
//  NSError+Utilities.h
//  BFBluetoothManager
//
//  Created by Paolo Tagliani on 29/07/16.
//  Copyright © 2016 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Utilities)

+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description;

+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description originalError:(NSString *)originalError;

@end
