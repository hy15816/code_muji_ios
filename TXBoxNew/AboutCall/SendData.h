//
//  SendData.h
//  TXBoxNew
//
//  Created by Naron on 15/8/11.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendData : NSObject

+(SendData *)shareInstance;

/**
 *  设备确认，是否需要重传某些包
 *  @param byte 包序号
 *  @return data
 */
-(NSData *)is5b05000003;

/**
 *  设备确认，数据是否接收全部包
 *  @return data
 */
-(NSData *)is5a0600ffff;

/**
 *  获取CRC校验码
 *  @pragma data    数据源(Byte*)
 *  @pragma lengths 数据源的length
 *  @return CRC校验码
 */
-(unsigned short)crc_ccitt:(unsigned char*)data len:(int)lengths;

@end
