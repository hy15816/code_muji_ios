//
//  MyAddressBooks.h
//  BLETest
//
//  Created by Naron on 15/7/29.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>
#import "ConBook.h"

typedef CF_ENUM(NSInteger, MyBooksNotifity) {
    kMyBooksNotifityStatusNoBody = 0,
    kMyBooksNotifityStatusNoAuthority,
    kMyBooksNotifityStatusLoading
};

@protocol MyAddressBooksDelegate <NSObject>
@optional
/**
 *  发送通知
 *  0没有联系人  1无权限
 */
-(void)sendNotify:(MyBooksNotifity)noti;
-(void)noAuthority:(CFErrorRef)error;
-(void)abAddressBooks:(ABAddressBookRef)bookRef allRefArray:(NSMutableArray *)array;
-(void)sortArray:(NSArray *)sort secDic:(NSMutableDictionary *)secDict;
@end

@interface MyAddressBooks : NSObject

+(MyAddressBooks *)sharedAddBooks;

@property (assign,nonatomic) ABAddressBookRef abAddressBookRef;
@property (assign,nonatomic) id<MyAddressBooksDelegate> delegate;

-(void)CreateAddressBooks;
-(void)getAllABRecordRefs;
-(void)refReshContacts;
-(NSArray *)getSortArray;
-(NSMutableDictionary *)getSecDicts;
-(void)outToTimes;
@end
