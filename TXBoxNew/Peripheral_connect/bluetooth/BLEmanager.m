//
//  BLEmanager.m
//  TXBoxNew
//
//  Created by Naron on 15/6/18.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define kCBAdvDataServiceUUIDs  @"kCBAdvDataServiceUUIDs"   //key-所有服务
#define kCBAdvDataLocalName     @"kCBAdvDataLocalName"      //key-广播名称
#define kByte_count 20

#import "BLEmanager.h"

@implementation BLEmanager
@synthesize centralManager,managerDelegate;

static BLEmanager *sharedBLEmanger=nil;

-(id)init
{
    self = [super init];
    if (self) {
        if (!peripheralArray) {
            centralManager =[[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
            peripheralArray = [[NSMutableArray alloc] init];
            
            currentWriteChacteristic = [[CBCharacteristic alloc] init];
            currentReadChacteristic = [[CBCharacteristic alloc] init];
            
            chacteristicArray = [[NSMutableArray alloc] init];
            
        }
    }
    return self;
}

+(BLEmanager *)sharedInstance
{
    //@synchronized(self){
        if (sharedBLEmanger == nil) {
            sharedBLEmanger = [[super allocWithZone:nil] init];
        }
    //}
    return sharedBLEmanger;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id) copyWithZone:(NSZone *) zone
{
    return self;
}

#pragma mark -- centralManager
//central蓝牙当前状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    [self isLECapableHaedware];
    [managerDelegate systemBLEState:central.state];
    
    
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
    //[managerDelegate showAlertView];
    
    return false;
}
#pragma mark -- 5.2 查找到外设后，响应函数
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSString *advName=[advertisementData valueForKeyPath:kCBAdvDataLocalName];//广播名称
    //NSArray *serviceArray = [advertisementData valueForKey:kCBAdvDataServiceUUIDs];//所有服务
    NSLog(@"%@,%@,%@,%@,%@",peripheral.name,peripheral.identifier.UUIDString,advName,RSSI,advertisementData);
    
    
    //添加到pArray中
    if (![peripheralArray containsObject:peripheral]) {
        [peripheralArray addObject:peripheral];
        
        //保存到缓存目录
        //[self savePeriphToCaches];
    }
    /*
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array  =[];
    
    if (<#condition#>) {
        <#statements#>
    }
    */
    
    if (peripheralArray.count >0) {
        [managerDelegate searchedPeripheral:peripheralArray];
    }
    
}

-(void)savePeriphToCaches{

    NSArray *pathCaches = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *stringC = [pathCaches objectAtIndex:0];
    
     NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:stringC])  {
        [fileManager createFileAtPath:stringC contents:nil attributes:nil ];
    }
    [peripheralArray writeToURL:[NSURL URLWithString:stringC] atomically:YES];
}

#pragma mark -- 7.2 连接成功后响应此方法
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"connect suc p.name:%@",peripheral.name);
    cPeripheral = peripheral;
    
    //8.1读取外设的所有服务UUID
    cPeripheral.delegate = self;
    [cPeripheral discoverServices:nil];
    
    //代理,连接成功
    [managerDelegate managerConnectedPeripheral:cPeripheral connect:YES];
}

#pragma mark -- 8.2 读取外设的所有服务UUID成功后,响应此方法
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Discover Services error:%@",error.localizedDescription);
        return;
    }
    
    //9.1 读取当前CBService里面的特征值UUID
    NSMutableArray *sArray = [[NSMutableArray alloc] init];
    for (CBService *s in peripheral.services) {
        
        [cPeripheral discoverCharacteristics:nil forService:s];
        [sArray addObject:s];
    }
    NSLog(@"s:%@",sArray);
}

#pragma mark -- 9.2 读取当前CBService里面的特征值UUID成功后,响应此方法（写入数据）
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Discover Chc error:%@",error.localizedDescription);
        return;
    }
    
    for (CBCharacteristic * characteristic in service.characteristics)
    {
        [chacteristicArray addObject:characteristic];
        
    }
    NSLog(@"cArray:%@",chacteristicArray);
    
}

//设置是否监听
-(void)isOrNotSetNotify:(BOOL)setNotify
{
    if (setNotify == YES) {

        [cPeripheral setNotifyValue:YES forCharacteristic:currentReadChacteristic];
    }else{
        [cPeripheral setNotifyValue:NO forCharacteristic:currentReadChacteristic];
    }
}

//写数据
-(void)writeDatas:(NSData *)data{
    
    NSLog(@"write data:%@",data);
    if (currentWriteChacteristic.UUID.UUIDString != nil) {
    [cPeripheral writeValue:data forCharacteristic:currentWriteChacteristic type:CBCharacteristicWriteWithResponse];
    }else{
        for (CBCharacteristic *chc in chacteristicArray) {
            [cPeripheral writeValue:data forCharacteristic:chc type:CBCharacteristicWriteWithResponse];//循环写入，找到真正的写特征
            [cPeripheral setNotifyValue:YES forCharacteristic:chc];//设置所有特征监听为YES，有数据返回的读特征
            
        }
    }
    //监听

    [cPeripheral setNotifyValue:YES forCharacteristic:currentReadChacteristic];

}

//发送数据后回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"writeValue error:%@",error.localizedDescription);
        
        return;
    }else{
        currentWriteChacteristic = characteristic;
        NSLog(@"writeValue suc currentWriteChacteristic:%@",currentWriteChacteristic.UUID.UUIDString);
        //return;
        
    }
}

#pragma mark -- 若外设有特征值对象的值更新了，或外设向IOS这边发数据，都会自动回调下面的方法，(接收数据)
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"readValue error: %@",error.localizedDescription);
        return;
    }
    
    if (characteristic.value != nil) {
        currentReadChacteristic = characteristic;
        NSLog(@"currentReadChacteristic:%@",currentReadChacteristic.UUID.UUIDString);
        
        //接收到的值传出去
        NSData *receiveData = characteristic.value;
        [managerDelegate managerReceiveDataPeripheralData:receiveData toHexString:[self hexadecimalString:receiveData] fromCharacteristic:characteristic];
        return;
    }
    //把不是读特征的监听置为NO
    if (!currentWriteChacteristic) {
        [cPeripheral setNotifyValue:NO forCharacteristic:characteristic];
    }
    
    //接收到的事件，
    //[self reciveActionWithData:characteristic.value];
    
    
}



-(NSData *)is5b190001:(Byte)byte{
    
    Byte is5b190001[20];
    for (int i=0; i<kByte_count; i++) {
        is5b190001[i] = 0;
        
    }
    is5b190001[0] = 0x5b;
    is5b190001[1] = 0x19;
    is5b190001[2] = 0x00;
    is5b190001[3] = byte;//长包0xff、短包0x00
    is5b190001[4] = 0x01;//1表示接收，0否
    
    NSData *myData = [NSData dataWithBytes:&is5b190001 length:sizeof(is5b190001)];
    NSLog(@"is5b190001 data:%@",myData);
    return myData;
}

#pragma mark --若使用setNotifyValue:forCharacteristic:方法监听某特征，值改变后响应此方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //VCLog(@"c.value:%@",characteristic.value);
    
    if (error) {
        NSLog(@"notifyValue error: %@",error.localizedDescription);;
        return;
    }
    /*
     if (characteristic.value != nil) {
     currentRedeChacteristic = characteristic;
     //接收到的值传出去
     NSData *receiveData = characteristic.value;
     [managerDelegate managerReceiveDataPeripheralData:receiveData toHexString:[self hexadecimalString:receiveData] fromCharacteristic:characteristic];
     return;
     }

    */
}

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    
    NSString* result;
    static const unsigned char*dataBuffer;
    dataBuffer = (const unsigned char*)[data bytes];
    
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];//kByte_count;
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
    NSLog(@"conncet error:%@",error.localizedDescription);
    
    if (error) {
        
        [managerDelegate managerConnectedPeripheral:cPeripheral connect:NO];
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
    NSLog(@"fail to conncet p error:%@",error.localizedDescription);
    
    //代理
    [managerDelegate managerConnectedPeripheral:nil connect:NO];
    
}
#pragma mark -- [peripheral readRSSI]方法回调
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"RSSI:%@",RSSI);
}

@end
