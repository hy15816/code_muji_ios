//
//  TXGeneral+helper.m
//  TXBoxNew
//
//  Created by Naron on 15/4/20.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "TXGeneral+helper.h"
#import "NSString+helper.h"

@implementation TXGeneral_helper

#pragma mark -- 计算时间差
- (NSString *)prettyDateWithReference:(NSDate *)reference {
    NSString *suffix = @"ago";
    
    //float different = [reference timeIntervalSinceDate:self];
    
    float different = [reference timeIntervalSinceNow];
    
    if (different < 0) {
        different = -different;
        //suffix = @"from now";
    }
    
    // days = different / (24 * 60 * 60),==86400
    float dayDifferent = floor(different / (24*60*60));
    
    int days   = (int)dayDifferent;
    int weeks  = (int)ceil(dayDifferent / 7);
    int months = (int)ceil(dayDifferent / 30);
    int years  = (int)ceil(dayDifferent / 365);
    
    // 到现在为止
    if (dayDifferent <= 0) {
        // ++60s
        if (different < 60) {
            return @"just now";
        }
        
        // 60s<time<120s
        if (different < 120) {
            return [NSString stringWithFormat:@"1 minute %@", suffix];
        }
        
        //  time < 60min
        if (different < 660 * 60) {
            return [NSString stringWithFormat:@"%d minutes %@", (int)floor(different / 60), suffix];
        }
        
        // 60min < time < 60*2min
        if (different < 7200) {
            return [NSString stringWithFormat:@"1 hour %@", suffix];
        }
        
        // time < 60 * 24 * 60
        if (different < 86400) {
            return [NSString stringWithFormat:@"%d hours %@", (int)floor(different / 3600), suffix];
        }
    }
    // lower than one week
    else if (days < 7) {
        return [NSString stringWithFormat:@"%d day%@ %@", days, days == 1 ? @"" : @"s", suffix];
    }
    // lager than one week but lower than a month
    else if (weeks < 4) {
        
        return [NSString stringWithFormat:@"%d week%@ %@", weeks, weeks == 1 ? @"" : @"s", suffix];
    }
    // lager than a month and lower than a year
    else if (months < 12) {
        return [NSString stringWithFormat:@"%d month%@ %@", months, months == 1 ? @"" : @"s", suffix];
    }
    // lager than a year
    else {
        return [NSString stringWithFormat:@"%d year%@ %@", years, years == 1 ? @"" : @"s", suffix];
    }
    
    return self.description;
}

#pragma mark --计算2个时间点的时间差

- (NSString *)intervalFromLastDate:(NSString *)sDate toTheDate:(NSString *)endDate
{
    /*
     * 传入时间格式为:HHmmss
     */
    
    //获取2个时间点
    int startTime =[sDate intValue];
    int endTime = [endDate intValue];
    
    //时间差
    int duringTime = endTime - startTime;
    
    NSString *timeString = [[NSString alloc] init];
    
    int hours  =duringTime/3600;
    int minutes = duringTime/60;
    int seconds = duringTime%60;
    
    // < 1min
    if (duringTime <60) {
        
        timeString =[NSString stringWithFormat:@"00:%d",seconds];
        
    }// 1min~1hour
    else if (duringTime>=60 && duringTime <600){
        
        timeString =[NSString stringWithFormat:@"%d:%d",minutes,seconds];
    }// > 1hour
    else{
        
        timeString = [NSString stringWithFormat:@"%d:%d:%d",hours,minutes,seconds];
    }
    
    
    return timeString;
}



@end
