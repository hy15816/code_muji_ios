//
//  TXGeneral+helper.h
//  TXBoxNew
//
//  Created by Naron on 15/4/20.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXGeneral_helper : NSObject

/****计算时间差*****/
- (NSString *)prettyDateWithReference:(NSDate *)reference;

/****计算2个时间点的时间差****/
- (NSString *)intervalFromLastDate:(NSString *)sDate toTheDate:(NSString *)endDate;





@end
