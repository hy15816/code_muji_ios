//
//  BLEPeripheral.h
//  TXBoxNew
//
//  Created by Naron on 15/6/18.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEPeripheral : NSObject<CBPeripheralDelegate>

@property(nonatomic,strong) CBPeripheral *peri;
@property(nonatomic,strong) NSString *periIdentifier;
@property(nonatomic,strong) NSString *periLocaName;
@property(nonatomic,strong) NSString *periName;
@property(nonatomic,strong) NSNumber *periRSSI;
@property(nonatomic,assign) NSInteger  periServices;

@property (nonatomic,strong) NSData *writeData;
@property (nonatomic,assign) CBCharacteristicWriteType characteristicWriteType;

@end
