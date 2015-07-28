//
//  MsgFrame.h
//  TXBoxNew
//
//  Created by Naron on 15/5/7.
//  Copyright (c) 2015年 playtime. All rights reserved.
//
#define kEdging 20          //距离设备边框
#define kMargin 10          //左间隔
//#define kIconWH 40          //头像宽高
#define kIconWH 00          //头像宽高
//#define kContentW 180       //内容宽度
#define kContentW             //内容宽度

#define kTimeMarginW 15     //时间文本与边框间隔宽度方向
#define kTimeMarginH 10     //时间文本与边框间隔高度方向

#define kContentTop 10      //文本内容与按钮上边缘间隔
#define kContentLeft 15     //文本内容与按钮左边缘间隔
#define kContentBottom 15   //文本内容与按钮下边缘间隔
#define kContentRight 15    //文本内容与按钮右边缘间隔

#define kTimeFont [UIFont systemFontOfSize:12]      //时间字体
#define kContentFont [UIFont systemFontOfSize:16]   //内容字体

#import <UIKit/UIKit.h>

@class Message;

@protocol ChangeRightMarginDelegate <NSObject>

-(CGFloat)changeRightMargin;

@end

@interface MsgFrame : UIView

@property (nonatomic, assign, readonly) CGRect iconF;
@property (nonatomic, assign, readonly) CGRect timeF;
@property (nonatomic, assign, readonly) CGRect contentF;

@property (nonatomic, assign, readonly) CGFloat cellHeight; //cell高度
@property (nonatomic, strong) Message *message;
@property (nonatomic, assign) BOOL showTime;    //显示时间

@property (assign,nonatomic) id<ChangeRightMarginDelegate> delegate;

@end
