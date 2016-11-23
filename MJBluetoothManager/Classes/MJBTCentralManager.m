//
// Created by Paolo Tagliani on 11/05/16.
// Copyright (c) 2016 Mobile Jazz. All rights reserved.
//

#import "MJBTCentralManager.h"

#import "MJBTPeripheral.h"
#import "MJBTPeripheral_Private.h"

#import "NSArray+Peripherals.h"
#import "NSError+Utilities.h"

#import "MJBTErrorConstants.h"

@interface MJBTCentralManager ()

@property (nonatomic, strong, readwrite) CBCentralManager *centralManager;

@property (nonatomic, strong, readwrite) NSMutableArray *internalPeripheralList;
@property (nonatomic, strong, readwrite) NSMutableDictionary <CBPeripheral *, MJBTPeripheral *> *peripheralList;

@property (nonatomic, strong, readwrite) CBPeripheral *connectingPeripheral;
@property (strong, nonatomic, readwrite) MJBTPeripheral *connectedPeripheral;

@property (nonatomic, strong, readwrite) NSArray *servicesToScan;
@property (nonatomic, assign, readwrite) BOOL scanningEnabled;

@property (nonatomic, copy, readwrite) void (^ MJBTDeviceScanBlock)(MJBTPeripheral *peripheral, NSError *error);
@property (nonatomic, copy, readwrite) void (^ MJBTPeripheralConnectionBlock)(NSError *error);

@end

@implementation MJBTCentralManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        dispatch_queue_t bluetoothQueue = dispatch_queue_create("com.mobilejazz.bluetooth", DISPATCH_QUEUE_SERIAL);

        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:bluetoothQueue];

        _internalPeripheralList = [NSMutableArray array];
        _peripheralList = [[NSMutableDictionary alloc] init];
    }

    return self;
}

#pragma mark - Public methods

#pragma mark Scan methods

- (void)startScanningWithUpdateBlock:(void (^)(MJBTPeripheral *peripheral, NSError *error))updateBlock
{
    [self startScanningWithServices:nil updateBlock:updateBlock];
}

- (void)startScanningWithServices:(NSArray <CBUUID *> *)services updateBlock:(void (^)(MJBTPeripheral *peripheral, NSError *error))updateBlock
{
    self.MJBTDeviceScanBlock = updateBlock;
    self.servicesToScan = services;

    [self mj_startScanning];
}

- (void)stopScanning
{
    self.MJBTDeviceScanBlock = nil;
    [_centralManager stopScan];
}

#pragma mark - Retrieve peripheral

- (MJBTPeripheral *)retrievePeripheralWithID:(NSString *)ID
{
    CBPeripheral *peripheral = [_internalPeripheralList peripheralWithID:ID];

    if (peripheral)
    {
        return _peripheralList[peripheral];
    }

    NSUUID *deviceID = [[NSUUID alloc] initWithUUIDString:ID];
    NSArray *peripherals = [_centralManager retrievePeripheralsWithIdentifiers:@[deviceID]];

    if ([peripherals firstObject])
    {
        peripheral = [peripherals firstObject];
        _peripheralList[peripheral] = [[MJBTPeripheral alloc] initWithPeripheral:peripheral];
        return _peripheralList[peripheral];
    }

    return nil;
}

#pragma mark - Connection

- (void)connectToPeripheral:(MJBTPeripheral *)peripheral completionBlock:(void (^)(NSError *error))completionBlock
{
    if (peripheral.BTPeripheral.state == CBPeripheralStateConnected)
    {
        completionBlock(nil);
        return;
    }

    self.connectingPeripheral = peripheral.BTPeripheral;
    self.MJBTPeripheralConnectionBlock = completionBlock;

    [_centralManager connectPeripheral:_connectingPeripheral options:nil];
}

- (void)disconnectPeripheral:(MJBTPeripheral *)peripheral
{
    [self cancelConnectionToPeripheral:peripheral];
}

- (void)cancelConnectionToPeripheral:(MJBTPeripheral *)peripheral
{
    if (!peripheral)
    {
        return;
    }

    self.MJBTPeripheralConnectionBlock = nil;
    self.connectingPeripheral = nil;

    [_centralManager cancelPeripheralConnection:peripheral.BTPeripheral];
}

#pragma mark - Private methods

- (void)mj_startScanning
{
    if (_centralManager.state == CBCentralManagerStatePoweredOn)
    {
        [_centralManager scanForPeripheralsWithServices:_servicesToScan options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @NO}];
    }
    else
    {
        self.scanningEnabled = YES;
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStateUnsupported:
            if (_MJBTDeviceScanBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _MJBTDeviceScanBlock(nil, [NSError createErrorWithDomain:MJBTErrorDomain code:MJBTErrorCodeDeviceNotSupported description:nil]);
                });
            }
            break;
        case CBCentralManagerStateUnauthorized:
            if (_MJBTDeviceScanBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _MJBTDeviceScanBlock(nil, [NSError createErrorWithDomain:MJBTErrorDomain code:MJBTErrorCodeBluetoothNotAuthorized description:nil]);
                });
            }
            break;
        case CBCentralManagerStatePoweredOff:
            if ([_delegate respondsToSelector:@selector(didTurnedOffBluetooth)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate didTurnedOffBluetooth];
                });

            }
            break;
        case CBCentralManagerStatePoweredOn:
            if (_scanningEnabled)
            {
                [self mj_startScanning];
                self.scanningEnabled = NO;
            }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![self.internalPeripheralList containsObject:peripheral])
    {
        [self.internalPeripheralList addObject:peripheral];
        MJBTPeripheral *mjPeripheral = [[MJBTPeripheral alloc] initWithPeripheral:peripheral];
        self.peripheralList[peripheral] = mjPeripheral;
    }
    __weak typeof(self) weakSelf = self;
    if (_MJBTDeviceScanBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.MJBTDeviceScanBlock(_peripheralList[peripheral], nil);
        });
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if ([self.connectingPeripheral isEqual:peripheral])
    {
        self.connectingPeripheral = nil;
        self.connectedPeripheral = _peripheralList[peripheral];

        if (_MJBTPeripheralConnectionBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _MJBTPeripheralConnectionBlock(nil);
                self.MJBTPeripheralConnectionBlock = nil;
            });
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Failed to connect to peripheral: %@ error: %@", peripheral.description, error);
    }
    if ([self.connectingPeripheral isEqual:peripheral])
    {
        self.connectingPeripheral = nil;
        self.connectedPeripheral = nil;

        if (_MJBTPeripheralConnectionBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _MJBTPeripheralConnectionBlock(error);
                self.MJBTPeripheralConnectionBlock = nil;
            });
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Did disconnected peripheral: %@ error:%@", peripheral.description, error.localizedDescription);
    if ([peripheral isEqual:_connectedPeripheral.BTPeripheral])
    {
        self.connectedPeripheral = nil;
        if ([_delegate respondsToSelector:@selector(didDisconnectPeripheral:error:)])
        {
            MJBTPeripheral *BTperipheral = self.peripheralList[peripheral];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate didDisconnectPeripheral:BTperipheral error:error];
            });
        }
    }
}

@end
