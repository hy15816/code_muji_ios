//
//  BLEHelper.m
//  BLETest
//
//  Created by Naron on 15/8/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "BLEHelper.h"

@interface BLEHelper ()


@end

@implementation BLEHelper
@synthesize delegate;

-(id)init{
    self = [super init];
    if (self) {
        //_manager = [BLEmanager sharedInstance];
        //_manager.managerDelegate = self;
        
    }
    return self;
}

+(BLEHelper *)shareHelper{
    BLEHelper *helper;
    if (helper == nil) {
        helper = [[BLEHelper alloc] init];
        
    }

    return helper;
}

-(void)didHappendActionWithData:(NSData*)data{
    ActionType type;
    NSString *aType;
    switch (type) {
        case 0x01:
            aType = @"callIn";
            type = ActionTypeCallIn;
            break;
        case 0x02:
            aType = @"calling";
            type = ActionTypeCalling;
            break;
        case 0x03:
            aType = @"callOut";
            type = ActionTypeCallOut;
            break;
        case 0x04:
            aType = @"answer";
            type = ActionTypeAnswer;
            break;
        case 0x05:
            aType = @"hangUp";
            type = ActionTypeHangUp;
            break;
        case 0x06:
            aType = @"receiveMsg";
            type = ActionTypeReceiveMsg;
            break;
        case 0x07:
            aType = @"sendMsg";
            type = ActionTypeSendMsg;
            break;
        case 0x0D:
            aType = @"changeDate";
            type = ActionTypeChangeDate;
            break;
        case 0x0E:
            aType = @"callrecord";
            type = ActionTypeCallRecord;
            break;
            
        default:
            aType = @"default";
            type = ActionTypeDefault;
            break;
    }
    
    //NSMutableDictionary *dicts= [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",type],@"type",data,@"data", nil];//aType,@"actionType",
    
    NSMutableDictionary *dicts2= [[NSMutableDictionary alloc] initWithObjectsAndKeys:aType,@"type",data,@"data", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEHasReciveData" object:self userInfo:dicts2];//发出一个通知，在AppDelegate中接收
    
}


#pragma mark -- 发送长包(只要是短信都认为是长包)
//请求长包透传
-(void)requestTransmit:(Messages *)message withBLE:(BLEmanager *)manager{
    NSString *number = message.number;
    if (message.number.length%2 != 0) {
        number = [NSString stringWithFormat:@"%@0",message.number];
    }

    NSData *messContentData = [message.content dataUsingEncoding:NSUTF8StringEncoding];
    //len =类型(1) + 内容大小(2) +号码长度(1) + msg.length/2 + content.length
    NSInteger len = number.length/2 + messContentData.length+4;
    
    Byte touchuan[20];
    for (int i=0; i<kByte_count; i++) {
        touchuan[i] = 0;
    }
    touchuan[0] = 0x5A;
    
    touchuan[1] = 0x19;//cmd
    touchuan[2] = 0x00;
    touchuan[3] = 0xFF;//关键字，[0,0xEF]短,[0xF0,0xFF]长
    
    touchuan[4] = 0x00;//总长度,将要发送的数据的总长度
    touchuan[5] = 0x00;
    touchuan[6] = 0x00;
    touchuan[7] = len;
    
    touchuan[8] = 0x00;//包长度,传输过程中,除最后一包外,每个长包的标准长度(若一个产包能发送完，包长度即总长度)
    touchuan[9] = len;
    
    NSData *myData = [NSData dataWithBytes:&touchuan length:sizeof(touchuan)];
    NSLog(@"======datarequest:%@",myData);
    //[manager writeDatas:myData];

}

//<5A 19 00 ff <contentData> >,除去BLE协议头之外的所有内容
-(NSData *)getContentWithMsg:(Messages *)message numberL:(NSInteger)length{
    NSData *messContentData = [message.content dataUsingEncoding:NSUTF8StringEncoding];
    Byte *byteCon = (Byte *)[messContentData bytes];
    //len =类型(1) + 内容大小(2) +号码长度(1) + msg.length/2 + content.length
    NSInteger len = message.number.length/2 + messContentData.length+4;
    NSString *mNumber = message.number ;
    if (message.number.length%2 != 0) {
        mNumber = [NSString stringWithFormat:@"%@0",message.number];
    }
    Byte content[len];//<5a1900ff+content>
    for (int t=0; t<len; t++) {
        content[t] = 0x00;
    }
    content[0] = 0x07;//类型
    content[1] = 0x00;//内容大小 = 号码长度(1) + msg.length/2 + content.length
    content[2] = 0x00;
    content[3] = length;//号码长度
    
    //电话号码
    NSData *data =  [self operationNumber:mNumber];
    Byte * byte = (Byte *)[data bytes];
    for (int n=0; n<data.length; n++) {
            content[n +4] = byte[n];
    }
    //内容
    for (int q=0; q<messContentData.length; q++) {
        content[mNumber.length/2+4+q] = byteCon[q];
    }
    
    NSData *contentData = [NSData dataWithBytes:&content length:sizeof(content)];
    NSLog(@"======contentData:%@",contentData);

    return contentData;
}

//格式化电话号码，
-(NSData *)operationNumber:(NSString *)number{
    if (number.length%2 != 0) {
        number = [NSString stringWithFormat:@"%@0",number];
    }
    //电话号码中的字符转换
    number = [number stringByReplacingOccurrencesOfString:@"+" withString:@"A"];
    number = [number stringByReplacingOccurrencesOfString:@"p" withString:@"B"];
    number = [number stringByReplacingOccurrencesOfString:@"w" withString:@"C"];
    number = [number stringByReplacingOccurrencesOfString:@"#" withString:@"D"];
    number = [number stringByReplacingOccurrencesOfString:@"*" withString:@"E"];
    number = [number stringByReplacingOccurrencesOfString:@"\0" withString:@"F"];
    //号码压缩字节处理，
    Byte num[number.length/2];
    for (int i=0; i<number.length/2; i++) {
        NSString *s = [number substringWithRange:NSMakeRange(i*2, 1)];
        NSString *s2 = [number substringWithRange:NSMakeRange(i*2+1, 1)];
        int ss = [s intValue];
        if ([s isEqualToString:@"A"]) {
            ss =10;
        }else if ([s isEqualToString:@"B"]){
            ss = 11;
        }else if ([s isEqualToString:@"C"]){
            ss = 12;
        }else if ([s isEqualToString:@"D"]){
            ss = 13;
        }else if ([s isEqualToString:@"E"]){
            ss = 14;
        }else if ([s isEqualToString:@"F"]){
            ss = 15;
        }
        
        int a = ss*16 + [s2 intValue];//拼接
        num[i] = a;
    }
    NSData *data = [NSData dataWithBytes:&num length:sizeof(num)];
    return data;
    
}

//开始发送数据
-(void)sendDataWithMessage:(Messages *)message withBLE:(BLEmanager *)manager{
    
    //真实长度
    NSInteger trueLength = message.number.length;
    NSData *contentData = [self getContentWithMsg:message numberL:trueLength];
    //号码，为奇数时添加0
    NSString *mNumber ;
    if (message.number.length%2 != 0) {
        mNumber = [NSString stringWithFormat:@"%@0",message.number];
    }
    //<content <messContent> >
    NSData *messContentData = [message.content dataUsingEncoding:NSUTF8StringEncoding];
    //包长度 = 类型(1) + 内容大小(2) +号码长度(1) + msg.length/2 + content.length
    NSInteger len = mNumber.length/2 + messContentData.length+4;
    
    //第01个子包
    [self willSendFirstPackage:contentData len:len withBLE:manager];
    
    //第02个子包
    NSData *numData = [contentData subdataWithRange:NSMakeRange(0, contentLength)];
    [self willSendSecondPackage:numData withBLE:manager];
    
    //第03个及后续子包，data = 总data-第01个子包填充长度contentLength(17)
    NSData *laterData = [contentData subdataWithRange:NSMakeRange(contentLength, contentData.length-contentLength)];
    [self willSendThirdLaterPackage:laterData withBLE:manager];
    
}

/**
 *@method 发送第01个子包
 *@pragma data 总数据
 *@pragma len 包长度
 *@pragma manager 蓝牙
 */
-(void)willSendFirstPackage:(NSData *)data len:(NSInteger)len withBLE:(BLEmanager *)manager{
    
    Byte data01[20];
    for (int i=0; i<kByte_count; i++){
        data01[i] = 0x00;
    }
    
    data01[0]  = 0x5A;//发送方
    data01[1]  = 0x05;
    data01[2]  = 0x01;
    
    data01[3]  = 0x00;//包长度
    data01[4]  = len;
    
    data01[5]  = 0x00;//包序号
    data01[6]  = packageNumber;
    unsigned short crc= [self crc_ccitt:data ];//包CRC
    data01[7]  = crc/256;//包CRC
    data01[8]  = crc%256;
    
    data01[9]  = 0x19;//cmd
    
    //...0x00
    NSData *myData = [NSData dataWithBytes:&data01 length:sizeof(data01)];
    NSLog(@"======data01:%@",myData);
    //[manager writeDatas:myData];
    
}


-(void)willSendSecondPackage:(NSData *)numData withBLE:(BLEmanager *)manager{
    
    Byte *bt=(Byte *)[numData bytes];
    //5a 05 02 类型 所有内容大小 号码长度 号码
    Byte number[20];
    for (int i=0; i<kByte_count; i++) {
        number[i] = 0x00;
    }
    number[0]  = 0x5A;
    number[1]  = 0x05;
    number[2]  = 0x02;
    for (int j=3; j<kByte_count; j++) {
        number[j]  = bt[j-3];
    }
    
    NSData *myData = [NSData dataWithBytes:&number length:sizeof(number)];
    NSLog(@"======data02:%@",myData);
    //[manager writeDatas:myData];

}

-(void)willSendThirdLaterPackage:(NSData *)data withBLE:(BLEmanager *)manager{
    NSMutableArray *mdataArray = [[NSMutableArray alloc] init];
    NSInteger len = data.length;//data长度
    NSInteger loop = len/contentLength;//分包
    NSData *tempData =[[NSData alloc] init];
    if (loop>=1) {
        //
        for (int k=0; k<loop+1; k++) {
            if (k==loop) {//取出最后一串data，
                tempData =[data subdataWithRange:NSMakeRange(len-len%contentLength, len%contentLength)];
            }else{//k<loop,取出k*contentLength
                tempData =[data subdataWithRange:NSMakeRange(k*contentLength, contentLength)];
            }
            if (tempData.length > 0) {
                [mdataArray addObject:tempData];//data不为空，添加到array
            }
        }
    }else{
        tempData =[data subdataWithRange:NSMakeRange(0, len%contentLength)];
        [mdataArray addObject:tempData];
    }
    
    [self willSendData:mdataArray withBLE:manager];
}

-(void)willSendData:(NSMutableArray *)array withBLE:(BLEmanager *)manager {
    Byte send[20];
    for (int i=0; i<kByte_count; i++) {
        send[i] = 0x00;
    }
    send[0] = 0x5A;
    send[1] = 0x05;
    int a = (int)(kByte_count-contentLength);
    for (int i=0; i<array.count; i++) {
        send[2] = i+3;//序号01，02，03，...
        if (i==array.count-1) {
            
            send[2] = 0xFF;//最一包为0xFF
        }
        
        Byte *b=(Byte *)[array[i] bytes];//array中的data
        for (int j=a; j<kByte_count; j++) {
            send[j] = b[j-a];//send第a个 = array[i]中的data的第j-a个
            //  3       0
            //  4       1
            //  5       2
            // ...     ...
        }
        NSData *myData = [NSData dataWithBytes:&send length:sizeof(send)];
        NSLog(@"======data0%d:%@",i+3,myData);

        //此处发送长包，
        //[manager writeDatas:myData];
    }

    
}
//判断是否接受长包透传
-(BOOL)willAccept:(NSData *)data by:(Byte)meOrHeby{
    
    Byte *byte =(Byte *)[data bytes];
    //判断透传
    if (byte[0] == meOrHeby && byte[1] == 0x19 && byte[2] == 0x00 ) {
        //短包
        if (byte[3]<=0xEF) {
            return YES;
        }
        
        //长包
        if (byte[3]>=0xF0 && byte[3]<=0xFF) {
            if (byte[4] == 0x01) {//=01为接收
                return YES;
            }
            return NO;
        }
        
    }
    
    return NO;
}


/**
 *  设备确认接收透传
 *  @param byte 长包0xff或短包0x00
 *  @return data
 */
-(NSData *)confirmHisTouchuan :(Byte)byte{
    
    Byte is5b190001[20];
    for (int i=0; i<kByte_count; i++) {
        is5b190001[i] = 0;
        
    }
    is5b190001[0] = 0x5b;
    is5b190001[1] = 0x19;
    is5b190001[2] = 0x00;
    is5b190001[3] = byte;//byte;//长包0xff、短包0x00
    is5b190001[4] = 0x01;//1表示接收，0否
    
    NSData *myData = [NSData dataWithBytes:&is5b190001 length:sizeof(is5b190001)];
    NSLog(@"is5b190001 data:%@",myData);
    return myData;
}

-(void)willAcceptConfrimWithBLE:(BLEmanager *)manager{
    Byte confirm[20];
    for (int i=0; i<kByte_count; i++) {
        confirm[i] = 0x00;
    }
    
    confirm[0]  = 0x5A;//发送方
    confirm[1]  = 0x05;
    confirm[2]  = 0x00;
    confirm[3]  = 0x00;
    confirm[4]  = packageNumber;
    
    NSData *myData = [NSData dataWithBytes:&confirm length:sizeof(confirm)];
    [manager writeDatas:myData];
}

#pragma mark -- CRC校验码
/**
 *  获取CRC校验码
 *  @pragma data    数据源
 *  @return CRC校验码
 */
-(unsigned short)crc_ccitt:(NSData *)data {
    
    unsigned short crc = 0;
    Byte *by = (Byte*)[data bytes];
    int lengths = (int)data.length;

    while (lengths-- > 0){
        
        crc = ccitt_table[(crc>> 8 ^ *by++) & 0xff] ^ (crc<< 8);
    }
    return ~crc;
}

static unsigned short ccitt_table[256] = {
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7, 0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD,
    0xE1CE, 0xF1EF, 0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6, 0x9339, 0x8318, 0xB37B, 0xA35A,
    0xD3BD, 0xC39C, 0xF3FF, 0xE3DE, 0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485, 0xA56A, 0xB54B,
    0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D, 0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
    0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC, 0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861,
    0x2802, 0x3823, 0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B, 0x5AF5, 0x4AD4, 0x7AB7, 0x6A96,
    0x1A71, 0x0A50, 0x3A33, 0x2A12, 0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A, 0x6CA6, 0x7C87,
    0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41, 0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
    0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70, 0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A,
    0x9F59, 0x8F78, 0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F, 0x1080, 0x00A1, 0x30C2, 0x20E3,
    0x5004, 0x4025, 0x7046, 0x6067, 0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E, 0x02B1, 0x1290,
    0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256, 0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
    0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405, 0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E,
    0xC71D, 0xD73C, 0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634, 0xD94C, 0xC96D, 0xF90E, 0xE92F,
    0x99C8, 0x89E9, 0xB98A, 0xA9AB, 0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3, 0xCB7D, 0xDB5C,
    0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A, 0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
    0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9, 0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83,
    0x1CE0, 0x0CC1, 0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8, 0x6E17, 0x7E36, 0x4E55, 0x5E74,
    0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
};

#pragma mark -- 发送短包(拨打电话指令/)
-(void)sendShortPackage:(NSString *)content withBLE:(BLEmanager *)manager order:(OrderType)orderType{
    
    NSData *data= [content dataUsingEncoding:NSUTF8StringEncoding];
    Byte *byte = (Byte *)[data bytes];
    //发送数据5A19
    Byte shortPackage[20];
    for (int i=0; i<kByte_count; i++) {
        shortPackage[i] = 0;
    }
    shortPackage[0] = 0x5A;
    shortPackage[1] = 0x19;//cmd
    shortPackage[2] = 0x00;
    shortPackage[3] = 0x00;//关键字，[0,0xEF]短,[0xF0,0xFF]长
    
    //以下是将要发送的“包内容”
    //=================内容中含有号码类型==================
    if (orderType == OrderTypeCallOut ) {
        /*需要发送电话号码的指令,特别处理（认为是短包）
         1.拨打电话指令0x08，
         */
        shortPackage[4] = OrderTypeCallOut;//类型
        shortPackage[5] = 0x00;//数据内容大小:根据号码而定
        shortPackage[6] = content.length/2;
        NSData *numdata = [self operationNumber:content];
        Byte *byt =(Byte *)[numdata bytes];
        for (int t=0; t<content.length/2; t++) {
            shortPackage[t+7] = byt[t];
        }
        
        NSData *myData = [NSData dataWithBytes:&shortPackage length:sizeof(shortPackage)];
        [manager writeDatas:myData];
        return;
    }
    //================普通类型==========================
    shortPackage[4] = orderType;//类型
    shortPackage[5] = 0x00;
    shortPackage[6] = data.length;//数据内容大小:根据内容而定
    
    //数据内容
    for (int j=0; j<dataContentLength; j++) {
        shortPackage[j+7] = byte[j];
    }
    
    NSData *myData = [NSData dataWithBytes:&shortPackage length:sizeof(shortPackage)];
    [manager writeDatas:myData];
    
}

/**
 *获取信息内容
 *@pragma adataArray 收到的长包数据数组(所有)
 *@return Message 内容实体
 */
-(Messages *)MessagesWithReceiveData:(NSMutableArray *)dataArray{
    NSMutableData *mutData = [[NSMutableData alloc] init];
    for (int i=0;i<dataArray.count;i++) {
        NSData *data = dataArray[i];
        Byte *byteI=(Byte*)[data bytes];
        if (byteI[2] == 1) {//第一个包，
            //
        }else{
            [mutData appendData:[data subdataWithRange:NSMakeRange(3, data.length-3)]];//吧数组里的data合并到一个mutData中
        }
    }
    
    Byte *byte = (Byte *)[mutData bytes];
    NSInteger numberLength = byte[3];//(此字节为号码长度)
    if (numberLength <= 0) {//<0
        return nil;
    }
    
    Messages *message = [[Messages alloc] init];
    NSInteger num_length = byte[3];//号码长度
    NSString *number = [[NSString alloc] initWithData:[mutData subdataWithRange:NSMakeRange(4, num_length)] encoding:NSUTF8StringEncoding];//获取号码，4=类型(1)+内容大小(2)+号码长度(1)
    
    //msg内容= mutData - 类型(1)-内容大小(2)-号码长度(1)-号码所占字节(num_length/2)
    NSInteger num_byte = num_length%2==0?num_length/2:(num_length+1)/2;
    NSData *tempData = [mutData subdataWithRange:NSMakeRange(num_byte+4, mutData.length-num_byte-4)];
    NSString *str_content = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
    message.number = number;
    message.content = str_content;
    
    return message;
    
}
/**
 *  发送内容为空的指令 查询设备日期/接听/挂断
 *  @param  order 指令类型
 *  @param  manager 蓝牙
 */
-(void)sendOeder:(OrderType)order withBLE:(BLEmanager *)manager{
    Byte sendType[20];
    for (int i=0; i<kByte_count; i++) {
        sendType[i] = 0;
    }
    sendType[0] = 0x5A;
    sendType[1] = 0x19;//cmd
    sendType[2] = 0x00;
    sendType[3] = 0x00;//关键字，[0,0xEF]短,[0xF0,0xFF]长
    sendType[4] = order;
    NSData *myData = [NSData dataWithBytes:&sendType length:sizeof(sendType)];
    [manager writeDatas:myData];
    
}

/**
 *  更改时间指令
 *  @param date 日期
 */
-(void)changedDate:(NSDate *)date withBLE:(BLEmanager *)manager{
    NSDateFormatter *dft = [[NSDateFormatter alloc] init];
    [dft setDateFormat:@"yyMMddHHmmss"];//150820102000 <- 15/08/20 10:20:00
    NSString *dateString = [dft stringFromDate:date];
    
    Byte changDate[20];
    for (int i=0; i<kByte_count; i++) {
        changDate[i] = 0;
    }
    changDate[0] = 0x5A;
    changDate[1] = 0x19;//cmd
    changDate[2] = 0x00;
    changDate[3] = 0x00;//关键字，[0,0xEF]短,[0xF0,0xFF]长
    changDate[4] = OrderTypeSetDate;//类型
    changDate[5] = 0x00;
    changDate[6] = 0x07;//内容大小=dateString.length/2 ＋1
    changDate[7] = 0x01;//操作0x00查询，0x01设置
    for (int j=0; j<dateString.length/2; j+=2) {
        changDate[j+7] = [[dateString substringWithRange:NSMakeRange(j, 2)] intValue];
    }
    
    NSData *myData = [NSData dataWithBytes:&changDate length:sizeof(changDate)];
    NSLog(@"changeDate:%@",myData);
    [manager writeDatas:myData];
}

/**
 *  设置亲情号码
 *  @param numberArray 号码数组
 */
-(void)setFamilyNumber:(NSArray *)numberArray withBLE:(BLEmanager *)manager{
    NSString *number = [numberArray objectAtIndex:0];
    Byte familyNumber[20];
    for (int i=0; i<kByte_count; i++) {
        familyNumber[i] = 0;
    }
    familyNumber[0] = 0x5A;
    familyNumber[1] = 0x19;//cmd
    familyNumber[2] = 0x00;
    familyNumber[3] = 0x00;//关键字，[0,0xEF]短,[0xF0,0xFF]长
    familyNumber[4] = OrderTypeSetFamilyNumber;
    familyNumber[5] = 0x00;
    familyNumber[6] = number.length/2;//内容大小
    
    NSData *numdata = [self operationNumber:number];
    Byte *byt =(Byte *)[numdata bytes];
    for (int t=0; t<number.length/2; t++) {
        familyNumber[t+7] = byt[t];
    }
    
    NSData *myData = [NSData dataWithBytes:&familyNumber length:sizeof(familyNumber)];
    [manager writeDatas:myData];

    
}

/**
 *  回复事件状态
 *  @param  type 事件执行结果
 *  @param  byte 0x00失败，0x01成功
 */
-(void)replyState:(Byte)state action:(ActionType)type withBLE:(BLEmanager *)manager{
    Byte acState[20];
    for (int i=0; i<kByte_count; i++) {
        acState[i] = 0;
    }
    acState[0] = 0x5A;
    acState[1] = 0x19;//cmd
    acState[2] = 0x00;
    acState[3] = 0x00;//关键字，[0,0xEF]短,[0xF0,0xFF]长
    acState[4] = type;
    acState[5] = 0x00;
    acState[6] = 0x00;
    acState[7] = state;
    NSData *myData = [NSData dataWithBytes:&acState length:sizeof(acState)];
    NSLog(@"replyState:%@",myData);
    [manager writeDatas:myData];
}


//=======================================
/**
 *  事件，(拨入电话/通话中/拨出/接听/挂断/发短信事件)
 *  @return 电话号码
 */
-(NSString *)isActionWithData:(NSData *)data{
    //Byte *byte = (Byte *)[data bytes];
    NSString *numner;
    return numner;
}

/**
 *  拨打电话指令回复，
 *  @return @{number:?,state:?}
 */
-(NSDictionary *)isCallOutOrderWithData:(NSData *)data{
    Byte *byte = (Byte *)[data bytes];
    
    NSString *number;
    NSString *state = [NSString stringWithFormat:@"%d",byte[7]];//状态0失败，1成功
    
    
    NSDictionary *dict = @{@"number":number,@"state":state};
    return dict;
}

/**
 *  指令状态，(接听指令/挂断指令/发送短信指令)
 *  @return @{order:?,state:?}
 */
-(NSDictionary *)isOrderStateWithData:(NSData *)data{
    Byte *byte = (Byte *)[data bytes];
    
    NSString *oeder;
    NSString *state = [NSString stringWithFormat:@"%d",byte[7]];//状态0失败，1成功
    
    NSDictionary *dict = @{@"oeder":oeder,@"state":state};
    return dict;
}



/**
 *  发生错误
 *  @param  string 提示文字
 */
-(void)errorWithMs:(NSString *)string{
    
    [SVProgressHUD showImage:nil status:string];
    
}

@end
