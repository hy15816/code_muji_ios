//
//  BLEmanager.h
//  TXBoxNew
//
//  Created by Naron on 15/6/18.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEmanagerDelegate <NSObject>

-(void)managerConnectedPeripheral:(BOOL)isConnect;
-(void)mangerDisConnectedPeripheral :(CBPeripheral *)peripheral;
-(void)mangerReceiveDataPeripheralData :(NSData *)data fromCharacteristic :(CBCharacteristic *)curCharacteristic;
-(void)managerWriteData:(NSData *)data fromCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;

@end

@interface BLEmanager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

+(BLEmanager *)shareInstance;

@property (strong,nonatomic) CBCentralManager *centralManager;//中心管理器
@property (strong,nonatomic) CBPeripheral *currentPeripheral;          //外设
@property (strong,nonatomic) NSMutableArray *peripheralArray;   //外设数组

@property (strong,nonatomic) NSString *CharacteristicUUIDString;
@property (strong,nonatomic) NSData *writeData;
@property (assign,nonatomic)  CBCharacteristicWriteType type;

@property (assign,nonatomic) id<BLEmanagerDelegate> managerDelegate;

-(void)initCentralManager;

@end
