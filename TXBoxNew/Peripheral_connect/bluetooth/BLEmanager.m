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
@synthesize centralManager,managerDelegate;


//单例
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON

#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

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

+(BLEmanager *)sharedInstance
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
    chcDict = [[NSDictionary alloc] init];
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
    
    VCLog(@"Central manager currentState: %@", currentState);
    UIAlertView *bleAlert=[[UIAlertView alloc] initWithTitle:nil message:currentState delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [bleAlert show];
    return false;
}
#pragma mark -- 5.2 查找到外设后，响应函数
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSString *advName=[advertisementData valueForKeyPath:kCBAdvDataLocalName];//广播名称
    //NSArray *serviceArray = [advertisementData valueForKey:kCBAdvDataServiceUUIDs];//所有服务
    VCLog(@"%@,%@,%@,%@,%@",peripheral.name,peripheral.identifier.UUIDString,advName,RSSI,advertisementData);
    
    //BOOL isExist = [self comparePeripheralisEqual:peripheral RSSI:RSSI];
    //if (!isExist) {
        /*
        BLEPeripheral *perip = [[BLEPeripheral alloc] init];
        perip.peri              = peripheral;
        perip.periIdentifier    = peripheral.identifier.UUIDString;
        perip.periLocaName      = advName;
        perip.periName          = peripheral.name;
        perip.periRSSI          = RSSI;
        perip.periServices      = serviceArray.count;
        */
        
    //}
    
    //添加到pArray中
    if (![peripheralArray containsObject:peripheral]) {
        [peripheralArray addObject:peripheral];
    }
    
    
    [managerDelegate searchedPeripheral:peripheralArray];
}

#pragma mark -- 7.2 连接成功后响应此方法
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    VCLog(@"connect suc p.name:%@",peripheral.name);
    cPeripheral = peripheral;
    
    //8.1读取外设的所有服务UUID
    cPeripheral.delegate = self;
    [cPeripheral discoverServices:nil];
    
    //代理,连接成功
    [managerDelegate managerConnectedPeripheral:YES];
}

#pragma mark -- 8.2 读取外设的所有服务UUID成功后,响应此方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        VCLog(@"Discover Services error:%@",error.localizedDescription);
        return;
    }
    
    //9.1 读取当前CBService里面的特征值UUID
    for (CBService *s in peripheral.services) {
        
        [cPeripheral discoverCharacteristics:nil forService:s];
    }
}

#pragma mark -- 9.2 读取当前CBService里面的特征值UUID成功后,响应此方法（写入数据）
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        VCLog(@"Discover Chc error:%@",error.localizedDescription);
        return;
    }

    //发送数据
    BLEPeripheral *perip = [managerDelegate getPeripheralInfo];
    chcDict = [managerDelegate peripheralChacteristicString];//读取值，特征
    
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:[chcDict valueForKey:keyWriteChc]]])
        {
            //VCLog(@"1-chc.uuid:%@",[characteristic UUID]);
            //给蓝牙发数据
            [cPeripheral writeValue:perip.writeData forCharacteristic:characteristic type:perip.characteristicWriteType];
        }
    }
    
    //是否监听
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        if( [characteristic.UUID isEqual:[CBUUID UUIDWithString:[chcDict valueForKey:keyReadChc]]])
        {
            //VCLog(@"2-chc.uuid:%@",[characteristic UUID]);
            //读取值
            [cPeripheral readValueForCharacteristic:characteristic];
            //监听值
            BOOL value = [managerDelegate managerSetNotifyValue];
            if (value) {
                [cPeripheral setNotifyValue:value forCharacteristic:characteristic];
            }
            
        }
    }
    
}
//发送数据后回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        VCLog(@"writeValue error:%@",error.localizedDescription);
        
        return;
    }else{
        VCLog(@"writeValue suc UUID:%@\n",characteristic.UUID);
        
    }
}

#pragma mark -- 若外设有特征值对象的值更新了，或外设向IOS这边发数据，都会自动回调下面的方法，(接收数据)
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        VCLog(@"readValue error: %@",error.localizedDescription);
        return;
    }
    //VCLog(@"3-chc.uuid:%@",[characteristic UUID]);
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:[chcDict valueForKey:keyReadChc]]]) {
        
        //接收到的值传出去
        NSData *receiveData = characteristic.value;
        [managerDelegate managerReceiveDataPeripheralData:receiveData toHexString:[self hexadecimalString:receiveData] fromCharacteristic:characteristic];
    }
    
    
}

#pragma mark --若使用setNotifyValue:forCharacteristic:方法监听某特征，值改变后响应此方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //VCLog(@"c.value:%@",characteristic.value);
    
    if (error) {
        VCLog(@"readValue error: %@",error.localizedDescription);;
        return;
    }
    
    if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:[chcDict valueForKey:keyReadChc]]]) {
        //接收到的值传出去
        NSData *receiveData = characteristic.value;
        [managerDelegate managerReceiveDataPeripheralData:receiveData toHexString:[self hexadecimalString:receiveData] fromCharacteristic:characteristic];
    }
    
}

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    
    NSString* result;
    static const unsigned char*dataBuffer;
    dataBuffer = (const unsigned char*)[data bytes];
    
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = kByte_count;//[data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx ", (unsigned long)dataBuffer[i]]];
        
    }
    result = [NSString stringWithString:hexString];
    return result;
}

#pragma mark -- 连接上的两个设备突然断开了，会自动回调下面的方法
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //前提是 原已经连接上的
    VCLog(@"conncet error:%@",error.localizedDescription);
    
    if (error) {
        
        [managerDelegate managerConnectedPeripheral:NO];
        //断线重新连接当前外设
        BOOL isdisCon = [managerDelegate managerDisConnectedPeripheral:peripheral];
        if (isdisCon) {
            [centralManager connectPeripheral:cPeripheral options:nil];
        }
        
    }else{
        
    }
    
}

#pragma mark -- 连接的两个设备未能完成连接，
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    VCLog(@"fail to conncet p error:%@",error.localizedDescription);
    
    //代理
    [managerDelegate managerConnectedPeripheral:NO];
    
}
#pragma mark -- [peripheral readRSSI]方法回调
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    VCLog(@"RSSI:%@",RSSI);
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
