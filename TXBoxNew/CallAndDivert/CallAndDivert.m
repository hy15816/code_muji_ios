//
//  CallAndDivert.m
//  TXBoxNew
//
//  Created by Naron on 15/7/1.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "CallAndDivert.h"
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
-(void)isOrNotCallDivert:(FromView)view{
    //1.判断是否登录
    BOOL loginst = [[userDefaults valueForKey:LOGIN_STATE] intValue];
    NSString *lgmessage = @"";
    NSString *cgmessage = @"";
    if (view == 0) {
        lgmessage = @"请到【发现】中【登录】，然后【配置】拇机号码";
        cgmessage = @"请到【发现】中【配置】拇机号码";
    }
    if (view == 3){
        lgmessage = @"请先【登录】，然后【配置】拇机号码";
        cgmessage = @"请先【配置】拇机号码";
    }
    
    if (loginst) {//已登录
        //2.获取配置(拇机)号码
        NSString *number = [userDefaults valueForKey:muji_bind_number];
        if ([[userDefaults valueForKey:CONFIG_STATE] intValue]) {//已配置
            //3.获取呼转状态
            [self getDivertState:number];
            
        }else{//未配置
            UIAlertView *isNoMujiAlert = [[UIAlertView alloc] initWithTitle:@"想要呼转到拇机？" message:cgmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
            isNoMujiAlert.tag =1900;
            [isNoMujiAlert show];
        }
        
    }else{//未登录
        UIAlertView *isNoLoginAlert = [[UIAlertView alloc] initWithTitle:@"想要呼转到拇机？" message:lgmessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
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
        UIAlertView *aliert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"取消呼转到 %@?",number] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
        aliert.delegate = self;
        aliert.tag =1902;
        [aliert show];
        
        
    }else{//未呼转
        
        //提示，手机呼转到拇机123456789321？
        UIAlertView *aliert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"呼转到 %@?",number] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"不OK", nil];
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
            if (buttonIndex == 0) {//未配置
                [divertDelegate hasNotConfig];
            }
        }
            
            break;
        case 1901:
        {
            if (buttonIndex == 0) {
                [divertDelegate hasNotLogin];
            }
        }
            break;
        case 1902:
            if (buttonIndex == 0) {
                [userDefaults setValue:@"0" forKey:CALL_ANOTHER_STATE];
                [divertDelegate openOrCloseCallDivertState:CloseDivert number:[self setCancelCallFrowardingWithNumber:mujiNumber]];//确认取消
                [self getCallDivertTimeLengthWithCurrTime:time];//计算时长
                
            }
            break;
        case 1903:
            if (buttonIndex == 0) {
                [userDefaults setValue:@"1" forKey:CALL_ANOTHER_STATE];
                [divertDelegate openOrCloseCallDivertState:OpenDivert number:[self setCallForwardingWithNumber:mujiNumber]];//确认呼转
                [userDefaults setValue:time forKey:CallForwardStartTime];;//保存开始呼转的时间
            }
            break;
        default:
            break;
    }
}


/**
 *  计算呼转时长
 *  @pragma currentTime 当前时间
 */
-(void)getCallDivertTimeLengthWithCurrTime:(NSString *)currentTime{
    
    int durningTime =0;
    int start = [[userDefaults valueForKey:CallForwardStartTime] intValue];
    int end   = [currentTime intValue];
    
    durningTime = end - start;
    VCLog(@"CallDivertTimeLength:%d s(秒)",durningTime);
    
    int totalTime = durningTime + [[userDefaults valueForKey:TotalTime] intValue];//总时长=单次市场+上次记录的总时长
    [userDefaults setValue:[NSString stringWithFormat:@"%d",totalTime] forKey:TotalTime];
    
    //单次时长上传至服务器
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
        
        str = [[NSMutableString alloc] initWithFormat:@"**21*tel://%@#",string];
    }
    //unicom
    if ([[self getCarrier] isEqualToString:China_Unicom]) {
        NSString *s = @"**21*";
        NSString *s2 = @"*11#";
        NSString *encodedValue = [s stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedValue2 = [s2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        str = [[NSMutableString alloc] initWithFormat:@"tel://%@%@%@",encodedValue,string,encodedValue2];
    }
    //telecom
    if ([[self getCarrier] isEqualToString:China_Telecom]) {
        str = [[NSMutableString alloc] initWithFormat:@"*72tel://%@",string];
    }
    
    return str;
}

//设置取消呼转短号
-(NSMutableString *)setCancelCallFrowardingWithNumber:(NSString *)string
{
    NSMutableString *str;
    //cmcc
    if ([[self getCarrier] isEqualToString:China_Mobile]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://##21#"];
    }
    //unicom
    if ([[self getCarrier] isEqualToString:China_Unicom]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://##21#"];
    }
    //telecom
    if ([[self getCarrier] isEqualToString:China_Telecom]) {
        str = [[NSMutableString alloc] initWithFormat:@"tel://*720"];
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
