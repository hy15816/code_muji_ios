//
//  BLEHelper.h
//  BLETest
//
//  Created by Naron on 15/8/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "BLEmanager.h"
#import "Messages.h"

static NSInteger packageNumber      = 0x03;     //包序号
static NSInteger contentLength      = 17;       //包内容长度
static NSInteger dataContentLength  = 13;       //实际发送的数据内容长度

//包类型
typedef NS_ENUM(UInt8, PackageType) {
    PackageTypeShort            = 0x00,     //短包
    PackageTypeLong             = 0xFF,     //长包
    
};



//事件
typedef NS_ENUM(UInt8, ActionType) {
    ActionTypeDefault           = 0x00,
    ActionTypeCallIn            = 0x01,     //拨入电话事件
    ActionTypeCalling           = 0x02,     //通话中
    ActionTypeCallOut           = 0x03,     //拨出
    ActionTypeAnswer            = 0x04,     //接听电话
    ActionTypeHangUp            = 0x05,     //挂断
    ActionTypeReceiveMsg        = 0x06,     //收短信
    ActionTypeSendMsg           = 0x07,     //发短信
    ActionTypeChangeDate        = 0x0D,     //更改时间日期
    ActionTypeCallRecord        = 0x0E,     //如有通话记录，需通知App
    
};

//指令
typedef NS_ENUM(UInt8, OrderType) {
    OrderTypeDefault            = 0x00,
    OrderTypeCallOut            = 0x08,     //拨打
    OrderTypeAnswer             = 0x09,     //接听
    OrderTypeHangUp             = 0x0A,     //挂断
    OrderTypeSendMsg            = 0x0B,     //发短信
    OrderTypeSetDate            = 0x0C,     //更改时间日期
    OrderTypeSetSwitch          = 0x0F,     //开关控制
    OrderTypeSetFamilyNumber    = 0x10,     //设置亲情号码
};
@protocol BLEHelperDelegate <NSObject>


@end

@interface BLEHelper : NSObject

@property (assign,nonatomic) id<BLEHelperDelegate> delegate;

+(BLEHelper *)shareHelper;

/**
 *@method 判断发生了那个事件action
 *@pragma type enum type
 */
-(void)didHappendActionWithData:(NSData*)data;


//================================================================
/**
 *@method 0请求长包透传
 *@pragma sendData 将要发送的数据
 *@pragma 将要发送数据的BLE
 */
-(void)requestTransmit:(Messages *)message withBLE:(BLEmanager *)manager;

/**
 *  设备确认接收透传
 *  @param byte 长包0xff或短包0x00
 *  @return data
 */
-(NSData *)confirmHisTouchuan:(Byte)byte;

/**
 *@method 1判断是否接受透传长包
 *@pragma data 将要判断的数据
 *@[ragma meOrHe me,5B   He,5A
 *@return YES为接受，NO为否
 */
-(BOOL)willAccept:(NSData *)data by:(Byte)meOrHe;

/**
 *@method 发送数据
 *@pragma message 消息实体
 *@pragma manager 蓝牙
 */
-(void)sendDataWithMessage:(Messages *)message withBLE:(BLEmanager *)manager;

/**
 *app确认，收到了设备的确认
 */
-(void)willAcceptConfrimWithBLE:(BLEmanager *)manager;;

/**
 *获取信息内容
 *@pragma adataArray 收到的长包数据数组(所有)
 *@return Message 内容实体 
 */
-(Messages *)MessagesWithReceiveData:(NSMutableArray *)dataArray;


//==============================================================
/**
 *@method 发送数据-短包透传
 *@pragma data 将要发送的数据
 *@pragma manager 将要发送数据的BLE
 *@pragma orderType 指令类型
 */
-(void)sendShortPackage:(NSString *)content withBLE:(BLEmanager *)manager order:(OrderType)orderType;

/**
 *@method 发送内容为nil的指令，查询设备日期/接听/挂断
 *@pragma order 指令类型
 *@pragma manager 蓝牙
 */
-(void)sendOeder:(OrderType)order withBLE:(BLEmanager *)manager;


/**
 *  更改时间指令
 *  @param date 日期
 */
-(void)changedDate:(NSDate *)date withBLE:(BLEmanager *)manager;

/**
 *  设置亲情号码(暂时只支持一个)
 *  @param numberArray 号码数组
 */
-(void)setFamilyNumber:(NSArray *)numberArray withBLE:(BLEmanager *)manager;

/**
 *  回复事件状态(收短信事件/通话记录事件)
 *  @param  type 事件执行结果
 *  @param  byte 0x00失败，0x01成功
 */
-(void)replyState:(Byte)state action:(ActionType)type withBLE:(BLEmanager *)manager;

/**
 *  发生错误
 *  @param  string 提示文字
 */
-(void)errorWithMs:(NSString *)string;

//======================设备回复(发送)============================
/**
 *  事件，(拨入电话/通话中/拨出/接听/挂断/发短信事件)
 *  @return 电话号码
 */
-(NSString *)isActionWithData:(NSData *)data;

/**
 *  拨打电话指令回复，
 *  @return @{number:?,state:?}
 */
-(NSDictionary *)isCallOutOrderWithData:(NSData *)data;

/**
 *  指令状态，(接听指令/挂断指令/发送短信指令)
 *  @return @{order:?,state:?}
 */
-(NSDictionary *)isOrderStateWithData:(NSData *)data;

@end
