//
//  TXBLEOperation.m
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXBLEOperation.h"
#import "TXSqliteOperate.h"
#import "TXGeneral+helper.h"

@implementation TXBLEOperation
@synthesize manager;

-(id)init
{
    if (self = [super init]) {
        
        _txSqlite = [[TXSqliteOperate alloc] init];
        _data = [[TXData alloc] init];
    }
    return self;
}

//请求配对设备
-(int) requestBTPair:(NSString *)str
{
    return 0;
}
//请求连接手机
-(int) receiveBTLink:(NSString *)str
{
    return 0;
}
//握手消息
-(int) handShake
{
    return 0;
}


-(void)getMessageFromMuji:(NSString *)hisNumber msgContent:(NSString *)content
{
    //与BLE连接--接收到数据(短信)，
    //获取当前时间
    NSDate *date = [NSDate date];
    //时间格式
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yy/M/d HH:mm"];
    [dateFormate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//中国
    
    NSString *time = [dateFormate stringFromDate:date];
    
    
    //NSString *number = hisNumber;
    //NSString *cont = content;
    
    //保存收到的信息数据->本地sqlite
    [self saveDataWithMsgSender:hisNumber msgTime:time msgContent:content msgAccepter:nil];
    
}

#pragma mark -- 保存信息数据
-(void) saveDataWithMsgSender:(NSString *)sender
                      msgTime:(NSString *)time
                   msgContent:(NSString *)content
                  msgAccepter:(NSString *)accepter
{
    //sender
    NSString *msgSender = [[NSString alloc] init];// 即 hisNumber
    if (sender.length>0) {
        
        msgSender  =sender;
    }else
    {
        msgSender = @"";
    }
    
    //time
    NSString *msgTime = [[NSString alloc] init];
    if (time.length>0) {
        
        msgTime  =time;
    }else
    {
        msgTime = @"";
    }
    //content
    NSString *msgContent = [[NSString alloc] init];
    if (content.length>0) {
        
        msgContent  =content;
    }else
    {
        msgContent = @"";
    }
    //accepter
    NSString *msgAccepter = [[NSString alloc] init];
    if (accepter.length>0) {
        
        msgAccepter  =accepter;
    }else
    {
        msgAccepter = @"";
    }
    
    //data.peopleId =;//不需要存id，
    _data.msgSender = msgSender;
    _data.msgTime = msgTime;
    _data.msgContent = msgContent;
    _data.msgAccepter = msgAccepter;
    //添加到信息表
    [_txSqlite addInfo:_data inTable:MESSAGE_RECEIVE_RECORDS_TABLE_NAME withSql:MESSAGE_RECORDS_ADDINFO_SQL];
    
}


@end
