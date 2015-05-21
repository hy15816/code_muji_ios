//
//  Message.m
//  TXBoxNew
//
//  Created by Naron on 15/5/7.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "Message.h"

@implementation Message

- (void)setData:(TXData *)data{
    
    _data = data;
    
    //self.icon = data[@"icon"];
    self.time = data.msgTime;
    self.content = data.msgContent;
    self.type = [data.msgState intValue];
}

@end
