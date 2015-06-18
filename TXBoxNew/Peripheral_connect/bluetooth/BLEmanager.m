//
//  BLEmanager.m
//  TXBoxNew
//
//  Created by Naron on 15/6/18.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define kCBAdvDataServiceUUIDs  @"kCBAdvDataServiceUUIDs"   //key-所有服务
#define kCBAdvDataLocalName     @"kCBAdvDataLocalName"      //key-广播名称

#import "BLEmanager.h"
#import "BLEPeripheral.h"

@implementation BLEmanager
@synthesize centralManager,currentPeripheral,peripheralArray,managerDelegate,CharacteristicUUIDString,writeData,type;

static BLEmanager *sharedBLEmanger=nil;

-(id)init
{
    self = [super init];
    if (self) {
        if (!peripheralArray) {
            centralManager =[[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
            peripheralArray = [[NSMutableArray alloc] init];
            
        }
    }
    return self;
}

+(BLEmanager *)shareInstance
{
    @synchronized(self){
        if (sharedBLEmanger == nil) {
            sharedBLEmanger = [[self alloc]init];
        }
    }
    return sharedBLEmanger;
}
//初始化central
-(void)initCentralManager
{
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

#pragma mark -- centralManager
//central蓝牙当前状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    [self isLECapableHaedware];
    
}

-(BOOL)isLECapableHaedware{
    NSString *currentState = nil;
    switch (centralManager.state)
    {
        case CBCentralManagerStateUnsupported:
            currentState = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            currentState = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            currentState = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            currentState = @"work";//可用
            return true;
        case CBCentralManagerStateUnknown:
        default:
            return false;
    }
    
    NSLog(@"Central manager currentState: %@", currentState);
    UIAlertView *bleAlert=[[UIAlertView alloc] initWithTitle:nil message:currentState delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [bleAlert show];
    return false;
}
#pragma mark -- 5.2 查找到外设后，响应函数
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSString *advName=[advertisementData valueForKeyPath:kCBAdvDataLocalName];//广播名称
    NSArray *serviceArray = [advertisementData valueForKey:kCBAdvDataServiceUUIDs];//所有服务
    NSLog(@"%@,%@,%@,%@,%@",peripheral.name,peripheral.identifier.UUIDString,advName,RSSI,advertisementData);
    
    BOOL isExist = [self comparePeripheralisEqual:peripheral RSSI:RSSI];
    
    if (!isExist) {
        BLEPeripheral *perip = [[BLEPeripheral alloc] init];
        perip.peri              = peripheral;
        perip.periIdentifier    = peripheral.identifier.UUIDString;
        perip.periLocaName      = advName;
        perip.periName          = peripheral.name;
        perip.periRSSI          = RSSI;
        perip.periServices      = serviceArray.count;
        
        //添加到pArray中
        if (![peripheralArray containsObject:perip]) {
            [peripheralArray addObject:perip];
        }
    }
    
}

#pragma mark -- 7.2 连接成功后响应此方法
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"connect suc");
    //停止扫描
    [centralManager stopScan];
    //代理
    currentPeripheral.delegate = self;
    //8.1读取外设的所有服务UUID
    [currentPeripheral discoverServices:nil];
    
    //代理
    [managerDelegate managerConnectedPeripheral:YES];
}

#pragma mark -- 8.2 读取外设的所有服务UUID成功后,响应此方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Discover Services error:%@",error.localizedDescription);
        return;
    }
    //9.1 读取当前CBService里面的特征值UUID
    for (CBService *s in currentPeripheral.services) {
        //NSLog(@"service:%@",s);
        [currentPeripheral discoverCharacteristics:nil forService:s];
    }
    
}

#pragma mark -- 9.2 读取当前CBService里面的特征值UUID成功后,响应此方法（写入数据）
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Discover Chc error:%@",error.localizedDescription);
        return;
    }
    NSMutableArray *cArray = [[NSMutableArray alloc] init];
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        [cArray addObject:characteristic];
        //NSLog(@"characteristic:%@",characteristic);
        
        if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:CharacteristicUUIDString]])
        {
            //特征是什么属性
            //NSLog(@"characteristic-properties:%lu",(unsigned long)characteristic.properties);
            
            //给蓝牙发数据
            //[currentPeripheral writeValue: forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            
            
            
            
        }
    }
    
    //NSLog(@"cArray:%@",cArray);
    
    
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        [cArray addObject:characteristic];
        //NSLog(@"characteristic:%@",characteristic);
        
        if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:CharacteristicUUIDString]])
        {
            //读取值
            [peripheral readValueForCharacteristic:characteristic];
            //监听值
            //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
}


#pragma mark -- 连接上的两个设备突然断开了，会自动回调下面的方法
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSLog(@"conncet error:%@",error.localizedDescription);
    
    if (error == nil) {
        //
    }else{
        //断线重新连接当前外设
        [centralManager connectPeripheral:currentPeripheral options:nil];
    }
    
    
}
#pragma mark -- 连接的两个设备未能完成连接，
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"fail to conncet p error:%@",error.localizedDescription);
    
    //代理
    [managerDelegate mangerDisConnectedPeripheral:peripheral];
    
}
#pragma mark -- [peripheral readRSSI]方法回调
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"RSSI:%@",RSSI);
}

-(BOOL) comparePeripheralisEqual :(CBPeripheral *)disCoverPeripheral RSSI:(NSNumber *)RSSI
{
    if ([peripheralArray count]>0) {
        for (int i=0;i<[peripheralArray count];i++) {
            BLEPeripheral *mperi = [peripheralArray objectAtIndex:i];
            if ([disCoverPeripheral isEqual:mperi.peri]) {
                mperi.periRSSI = RSSI;
                return YES;
            }
        }
    }
    return NO;
}

@end
