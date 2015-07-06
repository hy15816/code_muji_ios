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

@optional
/**
 *  是否连接成功
 *  @param peripheral 当前连接的设备
 *  @param isConnect BOOL类型
 */
-(void)managerConnectedPeripheral:(CBPeripheral *)peripheral connect:(BOOL)isConnect;

/**
 *  是否断线重连
 *  @param peripheral 当前外设
 *  @return YES是, NO否
 */
-(BOOL)managerDisConnectedPeripheral :(CBPeripheral *)peripheral;

/**
 *  返回蓝牙接收到的值
 *  @param data              data
 *  @param hexString         16进制string
 *  @param curCharacteristic 当前特征
 */
-(void)managerReceiveDataPeripheralData:(NSData *)data toHexString:(NSString *)hexString fromCharacteristic:(CBCharacteristic *)curCharacteristic;

/**
 *  扫描到的所有外设并返回当前连接的哪一个
 *  @param pArray 所有外设
 *  
 */
-(void)searchedPeripheral:(NSMutableArray *)peripArray;
@optional
-(void)systemBLEState:(CBCentralManagerState)state;
-(void)showAlertView;
@end


@interface BLEmanager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    NSDictionary *chcDict;
    CBPeripheral *cPeripheral;          //外设
    NSMutableArray *peripheralArray;   //外设数组
    NSMutableArray *chacteristicArray;  //特征
    CBCharacteristic *currentWriteChacteristic;
    CBCharacteristic *currentReadChacteristic;
}

+(BLEmanager *)sharedInstance;
@property (strong,nonatomic) CBCentralManager *centralManager;//中心管理器
@property (assign,nonatomic) id<BLEmanagerDelegate> managerDelegate;

-(void)initCentralManager;
-(void)writeDatas:(NSData *)data;// type:(CBCharacteristicWriteType)type;
-(void)isOrNotSetNotify:(BOOL)setNotify;

@end
