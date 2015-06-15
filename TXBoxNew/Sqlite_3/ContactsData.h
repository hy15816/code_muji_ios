//
//  ContactsData.h
//  TXBoxNew
//
//  Created by Naron on 15/6/15.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsData : NSObject

@property (assign, nonatomic) int contacterId;
@property (strong, nonatomic) NSString *contactName;      //name
@property (strong, nonatomic) NSString *contactNumber;    //号码
@end
