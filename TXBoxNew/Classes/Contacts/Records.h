//
//  Records.h
//  VideoCall
//
//  Created by mac on 14-12-4.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface Records : NSObject
@property (strong, nonatomic) NSString *personTel;
@property (strong, nonatomic) NSString *personName;

@property (strong, nonatomic) NSString *personTelNum;
@property (strong, nonatomic) NSString *personNameNum;

@property (strong,nonatomic) NSString  *recordRef;

@end
