//
//  TXBLEOperation.h
//  TXBox
//
//  Created by Naron on 15/4/9.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DBDatas.h"

@interface TXBLEOperation : NSObject
{
    CBCentralManager *manager;
    
}
@property (nonatomic,strong) CBCentralManager *manager;
@property (nonatomic,strong) DBDatas *data;

-(int) requestBTPair:(NSString *)str;
-(int) receiveBTLink:(NSString *)str;
-(int) handShake;

-(void)getMessageFromMuji:(NSString *)hisNumber msgContent:(NSString *)content contactID:(NSString *)contactId;

/**
 *  保存已发送的信息
 *
 *  @param sender   发送者
 *  @param time     时间
 *  @param content  内容
 *  @param accepter 接收者
 */
-(void) saveDataWithMsgSender:(NSString *)sender
                      msgTime:(NSString *)time
                   msgContent:(NSString *)content
                  contactID:(NSString *)contactID;
@end
