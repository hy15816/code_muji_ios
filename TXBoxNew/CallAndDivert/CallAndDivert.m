//
//  CallAndDivert.m
//  TXBoxNew
//
//  Created by Naron on 15/7/1.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallAndDivert.h"
#import <AVOSCloud/AVOSCloud.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface CallAndDivert ()<UIAlertViewDelegate>
{
    AVObject *userInfoObj;
}

@end

@implementation CallAndDivert
@synthesize divertDelegate;

-(id)init{
   self =   [super init];
    if (self) {
        //保存用户使用信息~时长
        userInfoObj =[AVObject objectWithClassName: USER_SPORT_INFO];
    }
    return self;
}

/**
 *  是否呼转
 */
-(void)isOrNotCallDivert{
    //1.判断是否登录
    BOOL loginst = [[userDefaults valueForKey:LOGIN_STATE] intValue];
    
    if (loginst) {//已登录
        //2.获取配置(拇机)号码
        NSString *number = [userDefaults valueForKey:muji_bind_number];
        if ([[userDefaults valueForKey:muji_bind_number] length] > 0) {//已配置
            //3.获取呼转状态
            [self getDivertState:number];
            
        }else{//未配置
            UIAlertView *isNoMujiAlert = [[UIAlertView alloc] initWithTitle:@"想要呼转到拇机？" message:@"请先【配置】拇机号码" delegate:self cancelButtonTitle:@"不OK" otherButtonTitles:@"OK", nil];
            isNoMujiAlert.tag =1900;
            [isNoMujiAlert show];
        }
        
    }else{//未登录
        UIAlertView *isNoLoginAlert = [[UIAlertView alloc] initWithTitle:@"想要呼转到拇机？" message:@"请先【登录】,然后【配置】拇机号码" delegate:self cancelButtonTitle:@"不OK" otherButtonTitles:@"OK", nil];
        isNoLoginAlert.tag =1901;
        [isNoLoginAlert show];
    }
    
    
}

/**
 *  获取呼转状态
 *  @param number 拇机号码
 */
-(void)getDivertState:(NSString *)number{
    
    if ([[userDefaults valueForKey:CALL_ANOTHER_STATE] intValue]) {//已呼转
        
        //提示，到拇机123456789321的呼转取消？
        UIAlertView *aliert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alerts", nil) message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Cancel_Call_Forwarding", nil),number] delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        aliert.delegate = self;
        aliert.tag =1902;
        [aliert show];
        
        
    }else{//未呼转
        
        //提示，手机呼转到拇机123456789321？
        UIAlertView *aliert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alerts", nil) message:[NSString stringWithFormat:@"%@ %@?",NSLocalizedString(@"Call_Forwarding", nil),number] delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        aliert.delegate = self;
        aliert.tag =1903;
        [aliert show];
        
    }
    
}

#pragma mark -- alertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //时间
    NSDate *date = [NSDate date];
    NSDateFormatter *dfmt = [[NSDateFormatter alloc] init];
    dfmt.dateFormat = @"MMddHHmmss";
    NSString *time = [dfmt stringFromDate:date];
    
    NSString *mujiNumber = [userDefaults valueForKey:muji_bind_number];
    
    switch (alertView.tag) {
        case 1900:
        {
            if (buttonIndex == 1) {//未配置
                [divertDelegate hasNotConfig];
            }
        }
            
            break;
        case 1901:
        {
            if (buttonIndex == 1) {
                [divertDelegate hasNotLogin];
            }
        }
            break;
        case 1902:
            if (buttonIndex == 1) {
                [userDefaults setValue:@"0" forKey:CALL_ANOTHER_STATE];
                [divertDelegate openOrCloseCallDivertState:CloseDivert number:[self setCancelCallFrowardingWithNumber:mujiNumber]];//确认取消
                [self getCallDivertTimeLengthWithCurrTime:time];//计算时长
            }
            break;
        case 1903:
            if (buttonIndex == 1) {
                [userDefaults setValue:@"1" forKey:CALL_ANOTHER_STATE];
                [divertDelegate openOrCloseCallDivertState:OpenDivert number:[self setCallForwardingWithNumber:mujiNumber]];//确认呼转
                [userDefaults setValue:time forKey:CallForwardStartTime];;//保存开始呼转的时间
            }
            break;
        default:
            break;
    }
}


#pragma mark -- 计算呼转时长
-(void)getCallDivertTimeLengthWithCurrTime:(NSString *)currentTime{
    
    int durningTime =0;
    int start = [[userDefaults valueForKey:CallForwardStartTime] intValue];
    int end   = [currentTime intValue];
    
    durningTime = end - start;
    
    VCLog(@"CallDivertTimeLength:%d s(秒)",durningTime);
    
    //上传至服务器
    NSNumber *number = [NSNumber numberWithInt:durningTime];
    [userInfoObj setObject:[userDefaults valueForKey:CurrentUser] forKey:table_username];//username
    [userInfoObj setObject:number forKey:table_total_duration_call_transfer];//佩戴时长
    [userInfoObj saveInBackgroundWithBlock:^(BOOL isSuc,NSError *error){
        if (error) {
            NSLog(@"add info error:%@",error);
        }else
        {
            NSLog(@"save succ");
            
        }
    }];
    
}

//设置开通呼转短号
-(NSMutableString *)setCallForwardingWithNumber:(NSString *)string
{
    NSMutableString *str;
    //cmcc
    if ([[self getCarrier] isEqualToString:China_Mobile]) {
        str = [[NSMutableString alloc] initWithFormat:@"\*\*21\*tel://%@\#",string];
    }
    //unicom
    if ([[self getCarrier] isEqualToString:China_Unicom]) {
        str = [[NSMutableString alloc] initWithFormat:@"\\*\\*21\\*tel://%@*11#",string];
    }
    //telecom
    if ([[self getCarrier] isEqualToString:China_Telecom]) {
        str = [[NSMutableString alloc] initWithFormat:@"\\*72tel://%@",string];
    }
    
    return str;
}

//设置取消呼转短号
-(NSMutableString *)setCancelCallFrowardingWithNumber:(NSString *)string
{
    NSMutableString *str;
    //cmcc
    if ([[self getCarrier] isEqualToString:China_Mobile]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://\\#\\#21\\#"];
    }
    //unicom
    if ([[self getCarrier] isEqualToString:China_Unicom]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://\\#\\#21\\#"];
    }
    //telecom
    if ([[self getCarrier] isEqualToString:China_Telecom]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://\\*720"];
    }
    
    
    return str;
}
/**
 *  获取本机运营商
 *  @return NSString 运营商
 */
- (NSString*)getCarrier
{
    //获取本机运营商
    CTTelephonyNetworkInfo *tInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [tInfo subscriberCellularProvider];
    NSString * mcc = [carrier mobileCountryCode];//国家码406
    NSString * mnc = [carrier mobileNetworkCode];//网络码
    if (mnc == nil || mnc.length <1 || [mnc isEqualToString:@"SIM Not Inserted"] ) {
        return @"Unknown";
    }else {
        if ([mcc isEqualToString:@"460"]) {
            NSInteger MNC = [mnc intValue];
            switch (MNC) {
                case 00:
                case 02:
                case 07:
                    return China_Mobile;
                    break;
                case 01:
                case 06:
                    return China_Unicom;
                    break;
                case 03:
                case 05:
                    return China_Telecom;
                    break;
                case 20:
                    return China_TieTong;
                    break;
                default:
                    break;
            }
        }
    }
    
    return @"Unknown";
}



@end