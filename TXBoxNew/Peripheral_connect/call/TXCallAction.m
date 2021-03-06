//
//  TXCallAction.m
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXCallAction.h"
#import "NSString+helper.h"
#import "DBHelper.h"

@interface TXCallAction ()

@property (strong, nonatomic) NSString *contactsID;
@end

@implementation TXCallAction
@synthesize startDate,data;

-(id)init
{
    if (self = [super init]) {
        data = [[DBDatas alloc] init];
        startDate = [[NSDate alloc] init];
        _contactsID = [[NSString alloc] init];
    }
    return self;
}

#pragma mark -- 接电话
-(int) callIn:(NSString *)hisnumber
{
    startDate = [NSDate date];
    
    return 0;
}
-(int) callInAction
{
    return 0;
}

#pragma mark -- 拨电话
-(int) callOutFromNumber:(NSString *)myNumber HisNumber:(NSString *)hisNumber contactID:(NSString *)contactid
{
    //获取当前时间，开始拨打
    startDate = [NSDate date];
    
    _contactsID = contactid;//获取联系人id
    
    if (myNumber.length >0) {
        NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
        [dateFormate setDateFormat:@"yyyy/M/d HH:mm"];
        [dateFormate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//中国
        //开始时间
        NSString *strDate = [dateFormate stringFromDate:startDate];
        
        VCLog(@"call out date %@",strDate);
        return 1;

        
    }
    return 0;
}
-(int) callOutAction:(int)sender
{
    if (sender) {
        return 1;
    }
    
    return 0;
}
#pragma mark -- 通话结束

-(int) callEndByMeWithState:(int)state
                  hisNumber:(NSString *)hisNumber
                    hisName:(NSString *)hisName
                 timeLength:(NSString *)times
{
    //保存数据信息
    [self saveDataWithHisNumber:hisNumber hisName:hisName startDate:self.startDate timeLength:times callDirection:[NSString stringWithFormat:@"%d",state]];
    
    return 0;
}
-(int) callEndByHim:(int)state
{
    return 0;
}

#pragma mark -- 保存数据信息
-(void) saveDataWithHisNumber:(NSString *)hisNumber
                      hisName:(NSString *)hisName
                    startDate:(NSDate *)date
                   timeLength:(NSString *)times
                callDirection:(NSString *)direction
{
    //时间格式
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy/M/d HH:mm"];
    [dateFormate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//中国
    //开始时间
    NSString *strDate = [dateFormate stringFromDate:date];//sreDate:如1503261130
    
    //通话时长
    NSString *strCallLength = times;
    //号码
    NSString *strNunmber = [[NSString alloc] init];
    if (hisNumber.length>0) {
        
        strNunmber  =[hisNumber purifyString];
    }else
    {
        strNunmber = @"";
    }
    
    NSString *name = [[NSString alloc] init];
    name = hisName.length>0?hisName:@"";
    //运营商
    NSString *strOperators = [[NSString alloc] init];
    strOperators = [hisNumber isMobileNumberWhoOperation];
    
    //归属地
    NSString *strAddress = [[NSString alloc] init];
    if (hisNumber.length >=7) {
        
        strAddress = [[DBHelper sharedDBHelper] getAreaWithNumber:[hisNumber purifyString]];
        
    }else{
        strAddress = @"";
    }
    if (_contactsID == nil) {
        _contactsID = @"";
    }
    
    //DBDatas *data = [[DBDatas alloc] init];
    //data.tel_id =singleton.telID;//不需要存id，
    data.hisName = name;
    data.hisNumber = strNunmber;
    data.callBeginTime = strDate;
    data.hisOperator = strOperators;
    data.hisHome = strAddress;
    data.callDirection = direction;
    data.callLength = strCallLength;
    data.contactID = _contactsID;
    
    [[DBHelper sharedDBHelper] addDatasToCallRecord:data];
    
}

// 时间转字符串，
-(NSString *) dateTurnStringWithDate:(NSDate *)date dateFormate:(NSString *)formate
{
    //想要的时间格式
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:formate];
    [dateFormate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];//中国
    //
    NSString *string = [dateFormate stringFromDate:date];
    
    return string;
    
}

@end
