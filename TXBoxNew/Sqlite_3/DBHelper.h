//
//  DBHelper.h
//  TXBoxNew
//
//  Created by Naron on 15/8/19.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBHelper : NSObject

+ (DBHelper *)sharedDBHelper;


#pragma mark 数据库公用方法
//==================================================================
/**
 *  获取数据库路径
 *  @return 数据库路径
 */
-(NSString *)dbPath;

/**
 *  将数据库文件拷贝到Documen目录下
 */
- (void)copyDBFileToDocumentPath;

/**
 *  获取FMDatabase对象
 *  @return FMDatabase对象
 */
- (FMDatabase *)createDatabase;

/**
 *  创建表
 */
-(void)createTable;


/**
 *  根据SQL语句创建表
 *  @param sql SQL语句
 */
-(void)createTableForSql:(NSString *)sql;

#pragma mark 基本数据查询
//==================================================================
//获取所有通话记录
-(NSMutableArray *)getAllCallRecords;
//获取所有信息记录
-(NSMutableArray *)getAllMessages;

/**
 *  获取号码归属地
 *  @param number 号码
 */
-(NSString *)getAreaWithNumber:(NSString *)number;

@end
