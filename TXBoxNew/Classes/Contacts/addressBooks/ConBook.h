//
//  ConBook.h
//  TXBoxNew
//
//  Created by Naron on 15/8/11.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConBook : NSObject

@property (strong,nonatomic) NSString *recordID;    //ABRecordID

@property (strong,nonatomic) NSString *firstName;   //名
@property (strong,nonatomic) NSString *lastName;    //姓
@property (strong,nonatomic) NSString *middleName;  //中间名
@property (strong,nonatomic) NSString *prefixName;  //前缀
@property (strong,nonatomic) NSString *suffixName;  //后缀

@property (strong,nonatomic) NSString *fullName;    //全名

@property (strong,nonatomic) NSMutableArray *phoneNumberArray;  //号码
@property (strong,nonatomic) NSMutableArray *emailArray;

/**
 *  组装名字
 *  @return FullName
 */
-(NSString *)AssemblyName;

@end
