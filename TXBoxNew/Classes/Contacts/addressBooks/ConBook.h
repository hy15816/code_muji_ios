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


+(ConBook *)sharBook;
/**
 *  组装名字
 *  @return FullName
 */
-(NSString *)AssemblyName;


//==========================================\\
\\                通讯录相关                  \\
\\==========================================//

/**
 *  根据一条联系人记录(recordRef)获取ID
 */
-(ABRecordID)getRecordIDByRef:(ABRecordRef)recordRef;

/**
 *  @method 根据ID和通讯录对象获取一条联系人记录(recordRef)
 *  @pragma recordID    ABRecordID
 *  @return ABRecordRef
 */
-(ABRecordRef)getRecordRefWithID:(ABRecordID)recordID;

/**
 *  获取一个通讯录对象
 */
-(ABAddressBookRef)getAbAddressBookRef:(CFDictionaryRef)option error:(CFErrorRef *)error;

/**
 *  获取组装的名字
 *  @param abRef ABRecordRef
 *  @return name
 */
-(NSString *)getNameWithRef:(ABRecordRef)abRef;

/**
 *  获取组装的名字
 *  @param abid ABRecordID
 *  @return name
 */
-(NSString *)getNameWithAbid:(ABRecordID)abid;

/**
 *  获取联系人第一个号码
 *  @param abid ABRecordID
 *  @return 号码String
 */
-(NSString *)getFirstNumber:(ABRecordID)abid;

/**
 *  获取联系人号码数组
 *  @param abid ABRecordID
 *  @return 号码数组
 */
-(NSMutableArray *)getNumberArray:(ABRecordID)abid;

@end
