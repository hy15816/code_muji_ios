//
//  DBDatas.h
//  TXBoxNew
//
//  Created by Naron on 15/8/20.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBDatas : NSObject

//==============通话记录
@property (assign, nonatomic) int tel_id;
@property (strong, nonatomic) NSString *hisName;//对方在通讯录中的名字，没有存则不显示
@property (strong, nonatomic) NSString *hisNumber;//对方号码
@property (strong, nonatomic) NSString *callDirection;//电话的方向:0-callIn, 1-callOut, 2-callMissed
@property (strong, nonatomic) NSString *callLength;//通话时长
@property (strong, nonatomic) NSString *callBeginTime;//通话开始时间
@property (strong, nonatomic) NSString *hisHome;//对方归属地
@property (strong, nonatomic) NSString *hisOperator;//对方的归属运营商


//===============短信
@property (assign, nonatomic) int peopleId;
//@property (strong, nonatomic) NSString *msgHisName;         //对方名字
@property (strong, nonatomic) NSString *msgHisNum;         //对方号码
@property (strong, nonatomic) NSString *msgTime;        //信息时间
@property (strong, nonatomic) NSString *msgContent;     //短信内容
@property (strong, nonatomic) NSString *msgState;       //状态，发送还是接收


//=================
@property (strong, nonatomic) NSString *contactID;//联系人在addressbook中的ABRecordID

@end
