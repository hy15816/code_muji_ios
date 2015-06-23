//
//  BLEmanager.h
//  TXBoxNew
//
//  Created by Naron on 15/6/18.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEPeripheral.h"

@protocol BLEmanagerDelegate <NSObject>

@optional
/**
 *  是否连接成功
 *  @param isConnect BOOL类型
 */
-(void)managerConnectedPeripheral:(BOOL)isConnect;

/**
 *  是否断线重连
 *  @param peripheral 当前外设
 *  @return YES是, NO否
 */
-(BOOL)mangerDisConnectedPeripheral :(CBPeripheral *)peripheral;

/**
 *  返回蓝牙接收到的值
 *  @param data              data
 *  @param hexString         16进制string
 *  @param curCharacteristic 当前特征
 */
-(void)mangerReceiveDataPeripheralData:(NSData *)data toHexString:(NSString *)hexString fromCharacteristic:(CBCharacteristic *)curCharacteristic;

/**
 *  @method 是否监听值
 *  @return YES是, NO否
 */
-(BOOL)managerSetNotifyValue;

/**
 *  获取要发送的数据和数据类型
 *  @return BLEPeripheral类
 */
-(BLEPeripheral *)getPeripheralInfo;

/**
 *  扫描到的所有外设并返回当前连接的哪一个
 *  @param pArray 所有外设
 *  @return 当前连接的
 */
-(CBPeripheral *)searchedPeripheral:(NSArray *)peripArray;

/**
 *  返回服务的特征值
 *  @return dict：{writeChc = "",readChc = ""};
 */
-(NSDictionary *)peripheralChacteristicString;
@end

@interface BLEmanager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    NSDictionary *chcDict;
    CBPeripheral *cPeripheral;          //外设
    NSMutableArray *peripheralArray;   //外设数组
}

+(BLEmanager *)sharedInstance;
@property (strong,nonatomic) CBCentralManager *centralManager;//中心管理器
@property (assign,nonatomic) id<BLEmanagerDelegate> managerDelegate;

-(void)initCentralManager;

@end
