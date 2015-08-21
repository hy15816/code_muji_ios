//
//  MsgDetailCell.h
//  TXBoxNew
//
//  Created by Naron on 15/5/7.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@class MsgFrame;

@interface MsgDetailCell : UITableViewCell
{
    UIButton     *timeBtn;
    UIImageView *iconView;
    UIButton    *contentBtn;
}
@property (strong,nonatomic) UIButton *contentBtn;
@property (strong,nonatomic) MsgFrame *msgFrame;

@property (strong,nonatomic) Message *message;

@end
