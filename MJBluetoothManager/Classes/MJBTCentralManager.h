//
// Created by Paolo Tagliani on 11/05/16.
// Copyright (c) 2016 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class MJBTPeripheral;

@protocol MJBTCentralManagerDelegate <NSObject>

- (void)didDisconnectPeripheral:(MJBTPeripheral *)peripheral error:(NSError *)error;
- (void)didTurnedOffBluetooth;

@end

/**
 * SDK class that manages discovery, connection and disconnection to peripherals.
 * NOTE: All calls of the completion blocks are done in the main thread
 */

@interface MJBTCentralManager : NSObject <CBCentralManagerDelegate>

/*
 * The current connected peripheral
 */
@property (strong, nonatomic, readonly) MJBTPeripheral *connectedPeripheral;

/**
 *  The delegate which will receive updates on peripheral disconnection
 */
@property (weak, nonatomic, readwrite) id <MJBTCentralManagerDelegate> delegate;

#pragma mark - Scan methods

/**
 *  Launch scan of nearby devices.
 */
- (void)startScanningWithUpdateBlock:(void (^)(MJBTPeripheral *peripheral, NSError *error))updateBlock;

/**
 *  Launch scan for nearby devices that expose the services passed as parameter
 *
 *  @param services    An array of CBUUID indicating the services to scan for
 *  @param updateBLock A block to be executed each time there's an update in the devices discovery
 */
- (void)startScanningWithServices:(NSArray <CBUUID *> *)services updateBlock:(void (^)(MJBTPeripheral *peripheral, NSError *error))updateBlock;

/**
 *  Stop the scan of devices
 */
- (void)stopScanning;

#pragma mark - Connection methods

/**
 *  Start connection on a given peripheral. THIS METHOD DOES NOT TIME OUT
 *
 *  @param peripheral      The peripheral to connect to
 *  @param completionBlock The block called on completion with an error, if present, passed as parameter
 */
- (void)connectToPeripheral:(MJBTPeripheral *)peripheral completionBlock:(void (^)(NSError *error))completionBlock;

/**
 *  Disconnect from a connected peripheral
 *
 *  @param peripheral The peripheral to which disconnect to
 */
- (void)disconnectPeripheral:(MJBTPeripheral *)peripheral;

/**
 *  Cancel all current pending connection with peripheral
 *
 *  @param peripheral The peripheral on which interrupt all connections
 */
- (void)cancelConnectionToPeripheral:(MJBTPeripheral *)peripheral;

#pragma mark - Device retrieval

/**
 *  Retrieve peripheral cached in the CoreBluetooth stack. To be used before scanning for nearby peripherals.
 *
 *  @param ID              The ID of the peripheral to search for
 *  @param completionBlock A block to be executed on completion, with the the peripheral if existing or an error.
 */
- (MJBTPeripheral *)retrievePeripheralWithID:(NSString *)ID;

@end
