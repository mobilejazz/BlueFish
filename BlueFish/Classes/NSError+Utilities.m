//
//  NSError+Utilities.m
//  BFBluetoothManager
//
//  Created by Paolo Tagliani on 29/07/16.
//  Copyright © 2016 Mobile Jazz. All rights reserved.
//

#import "NSError+Utilities.h"

@implementation NSError (Utilities)

+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description
{
    NSDictionary *userInfo = description ? @{ NSLocalizedDescriptionKey : description } : nil;
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

+ (NSError *)createErrorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description originalError:(NSString *)originalError
{
    NSMutableDictionary *userinfo = [NSMutableDictionary dictionary];
    if (description)
    {
        [userinfo setObject:description forKey:NSLocalizedDescriptionKey];
    }
    
    if (originalError)
    {
        [userinfo setObject:originalError forKey:@"originalError"];
    }
    return [NSError errorWithDomain:domain code:code userInfo:userinfo];
}

@end
