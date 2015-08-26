//
//  Message.m
//  TXBoxNew
//
//  Created by Naron on 15/5/7.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "Message.h"

@implementation Message

- (void)setData:(DBDatas *)ddata{
    
    _data = ddata;
    
    //self.icon = ddata.icon;
    self.time = ddata.msgTime;
    self.content = ddata.msgContent;
    self.type = [ddata.msgState intValue];
}


@end
