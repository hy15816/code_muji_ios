//
//  GetAllContacts.h
//  TXBoxNew
//
//  Created by Naron on 15/6/17.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol GetContactsDelegate <NSObject>
@optional
/**
 *  返回获取的联系人
 *  @param array phoneArray
 *  @param sDict sectionDict
 *  @param pDict phoneDict
 */
-(void)getAllPhoneArray:(NSMutableArray *)array SectionDict:(NSMutableDictionary *)sDict PhoneDict:(NSMutableDictionary *)pDict;

@end
@interface GetAllContacts : NSObject
+(GetAllContacts *)shardGet;
-(void)getContacts;//获取所有联系人
-(void)reloadContacts;
@property(assign,nonatomic) id<GetContactsDelegate> getContactsDelegate;

@end
