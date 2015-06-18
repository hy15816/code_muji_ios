//
//  BLEPeripheral.h
//  TXBoxNew
//
//  Created by Naron on 15/6/18.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol PeripDelegate <NSObject>

-(void)writeData:(NSData *)data toCharacteristic:(CBCharacteristic *)c type:(CBCharacteristicWriteType)type;

@end

@interface BLEPeripheral : NSObject

@property(nonatomic,strong) CBPeripheral *peri;
@property(nonatomic,strong) NSString *periIdentifier;
@property(nonatomic,strong) NSString *periLocaName;
@property(nonatomic,strong) NSString *periName;
@property(nonatomic,strong) NSNumber *periRSSI;
@property(nonatomic,assign) NSInteger  periServices;

@property (assign,nonatomic) id<PeripDelegate> peripDelegate;

@end
