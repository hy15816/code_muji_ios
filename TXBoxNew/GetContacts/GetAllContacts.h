//
//  GetAllContacts.h
//  TXBoxNew
//
//  Created by Naron on 15/6/17.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol GetContactsDelegate <NSObject>

-(void)AllPeople:(NSMutableArray *)array;

@end
@interface GetAllContacts : NSObject
-(void)gets;
@property(assign,nonatomic) id<GetContactsDelegate> getContactsDelegate;
@end
