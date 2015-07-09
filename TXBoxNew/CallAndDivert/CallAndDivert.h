//
//  CallAndDivert.h
//  TXBoxNew
//
//  Created by Naron on 15/7/1.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, CallDivertState) {
    //
    OpenDivert = 0,
    CloseDivert = 1,
};

typedef NS_ENUM(NSInteger, FromView) {
    //
    PhoneView       = 0,
    MessageView     = 1,
    ContactsView    = 2,
    DiscoveryView   = 3,
};

@protocol CallAndDivertDelegate <NSObject>
@optional
-(void)hasNotLogin;//未登录
-(void)hasNotConfig;//为配置

/**
 *  是否呼转
 *  @param state  呼转开关 1开  0关
 *  @param number 拇机号码
 */
-(void)openOrCloseCallDivertState:(CallDivertState )state number:(NSString *)number;

@end

@interface CallAndDivert : NSObject

@property(assign,nonatomic) id<CallAndDivertDelegate> divertDelegate;
-(void)isOrNotCallDivert:(FromView)view;

@end
