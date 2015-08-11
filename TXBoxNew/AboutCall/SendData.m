//
//  SendData.m
//  TXBoxNew
//
//  Created by Naron on 15/8/11.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define packgeLength 20
#define packageNumber 0x03
#define contentLength 17

#import "SendData.h"

@interface SendData ()
{
    NSData *sourceData;
    NSInteger len;
    NSInteger loop;
    NSMutableArray *mutDataArray;
}
@end


@implementation SendData

-(id)init{
    self = [super init];
    if (self) {
        //
    }
    return self;
}
+(SendData *)shareInstance{
    
    static dispatch_once_t onceToken;
    static SendData *send;
    dispatch_once(&onceToken, ^{
        send = [[SendData alloc] init];
    });
    return send;
    
}

//发送数据
-(void)sendMsgWithNumber:(NSString *)hisNumber{
    //计算发送内容的数据长度
    sourceData = [hisNumber dataUsingEncoding:NSUTF8StringEncoding];
    len = sourceData.length;
    loop = len/contentLength;
    
    //1.请求透传
    [self requestTransmit];
    //2.开始发送数据 长包中的第01个
    [self startSendData];
    //3.发送01个之后的数据
    [self sendFllowerData];
    //4.设备请求确认，是否需要重传某些包--在接收到的数据中判断
    //    [self is5b05000003];
    //5.app回复，收到了设备的确认
    [self confirm];
    //6.设备确认，数据是否接收完毕
    [self is5a0600ffff];
}

-(void)requestTransmit{
    Byte touchuan[20];
    for (int i=0; i<20; i++) {
        touchuan[i] = 0;
    }
    touchuan[0] = 0x5A;
    
    touchuan[1] = 0x19;//cmd
    touchuan[2] = 0x00;
    touchuan[3] = 0x00;//关键字，[0,0xEF]短,[0xF0,0xFF]长
    
    touchuan[4] = 0x00;//总长度
    touchuan[5] = 0x00;
    touchuan[6] = 0x00;
    touchuan[7] = len;
    
    touchuan[8] = 0x00;//包长度
    touchuan[9] = len;
    
    NSData *myData = [NSData dataWithBytes:&touchuan length:sizeof(touchuan)];
    //[manager writeDatas:myData];
    
    
}

-(void)startSendData{
    Byte data01[20];
    for (int i=0; i<packgeLength; i++) {
        data01[i] = 0x00;
    }
    
    data01[0]  = 0x5A;//发送方
    data01[1]  = 0x05;
    data01[2]  = 0x01;
    
    data01[3]  = 0x00;//包长度
    data01[4]  = len;
    
    data01[5]  = 0x00;//包序号
    data01[6]  = packageNumber;
    
    //data01[7]  = crc_ccitt((Byte*)[sourceData bytes], (int)[sourceData length]);//包CRC
    //data01[8]  = crc_ccitt((Byte*)[sourceData bytes], (int)[sourceData length]);
    
    data01[9]  = 0x19;//cmd
    
    //...0x00
    NSData *myData = [NSData dataWithBytes:&data01 length:sizeof(data01)];
    NSLog(@"5a0501 data:%@",myData);
    //[manager writeDatas:myData];
}

//发送第01个包后续的包
-(void)sendFllowerData{
    NSData *newData = [[NSData alloc] init];
    //拆分将要发送的数据
    if (loop>=1) {//>1个循环
        for (int k=0; k<loop+1; k++) {
            
            if (k==loop) {
                newData =[sourceData subdataWithRange:NSMakeRange(len-len%contentLength, len%contentLength)];
            }else{
                newData =[sourceData subdataWithRange:NSMakeRange(k*contentLength, contentLength)];
            }
            if (newData.length > 0) {
                [mutDataArray addObject:newData];
            }
            
            
        }
    }else{// <1个循环
        
        newData =[sourceData subdataWithRange:NSMakeRange(0, len%contentLength)];
        [mutDataArray addObject:newData];
    }
    
    NSLog(@"mdataArray: %@",mutDataArray);
    
    //发送组装好的数据
    Byte send[20];
    for (int i=0; i<packgeLength; i++) {
        send[i] = 0x00;
    }
    send[0] = 0x5A;
    send[1] = 0x05;
    int a=packgeLength-contentLength;
    for (int i=0; i<mutDataArray.count; i++) {
        send[2] = i+2;
        if (i==mutDataArray.count-1) {
            
            send[2] = 0xFF;
        }
        
        Byte *b=(Byte *)[mutDataArray[i] bytes];
        for (int j=a; j<packgeLength; j++) {
            send[j] = b[j-a];
        }
        NSData *myData = [NSData dataWithBytes:&send length:sizeof(send)];
        
        //NSLog(@"mydata:%@",myData);
        //此处发送长包，
        //[manager writeDatas:myData];
    }
    
    
}

-(void)confirm{
    Byte confirm[20];
    for (int i=0; i<packgeLength; i++) {
        confirm[i] = 0x00;
    }
    
    confirm[0]  = 0x5A;//发送方
    confirm[1]  = 0x05;
    confirm[2]  = 0x00;
    confirm[3]  = 0x00;
    confirm[4]  = packageNumber;
    
    NSData *myData = [NSData dataWithBytes:&confirm length:sizeof(confirm)];
    //[manager writeDatas:myData];
}

/**
 *  设备确认，是否需要重传某些包
 *  @param byte 包序号
 *  @return data
 */
-(NSData *)is5b05000003{
    
    Byte is5b05000003[20];
    for (int i=0; i<kByte_count; i++) {
        is5b05000003[i] = 0;
        
    }
    is5b05000003[0] = 0x5b;
    is5b05000003[1] = 0x05;
    is5b05000003[2] = 0x00;
    
    is5b05000003[3] = 0x00;//包序号
    is5b05000003[4] = packageNumber;
    
    NSData *myData = [NSData dataWithBytes:&is5b05000003 length:sizeof(is5b05000003)];
    return myData;
}

/**
 *  设备确认，数据是否接收全部包
 *  @return data
 */
-(NSData *)is5a0600ffff{
    
    Byte is5a0600ffff[20];
    for (int i=0; i<kByte_count; i++) {
        is5a0600ffff[i] = 0;
        
    }
    is5a0600ffff[0] = 0x5a;
    is5a0600ffff[1] = 0x06;
    is5a0600ffff[2] = 0x00;
    
    is5a0600ffff[3] = 0xff;//包序号，0x0000~0xff00表示成功接收最后一个数据包的序号，0xffff表示由多个数据包组成的全部数据接收完成
    is5a0600ffff[4] = 0xff;
    
    NSData *myData = [NSData dataWithBytes:&is5a0600ffff length:sizeof(is5a0600ffff)];
    return myData;
}

#pragma mark -- 关于CRC校验
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

/**
 *  CRC校验方法
 *  @param q       Byte*
 *  @param lengths data.length
 *  @param loc     crc_table loc
 *  @return crc效验码
 */
-(unsigned short)crc_ccitt:(unsigned char*)data len:(int)lengths{
    unsigned short crc = 0;
    while (lengths-- > 0){
        
        crc = ccitt_table[(crc>> 8 ^ *data++) & 0xff] ^ (crc<< 8);
    }
    return ~crc;
    
}



@end
