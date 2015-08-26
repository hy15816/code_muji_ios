//
//  DBHelper.h
//  TXBoxNew
//
//  Created by Naron on 15/8/19.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "DBDatas.h"

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
 *  使用本地数据库
 */
-(FMDatabase *)createDatabaseWith:(NSString *)path;

/**
 *  创建表
 */
-(void)createTable;

/**
 *  根据SQL语句创建表
 *  @param sql SQL语句
 */
-(void)createTableForSql:(NSString *)sql;

#pragma mark -- CALL RECORDS
/**
 *  添加通话记录数据
 *  @param datas DBDatas
 */
-(void)addDatasToCallRecord:(DBDatas *)datas;

/**
 *  获取所有通话记录
 *  @return mutArray(DBDatas,)
 */
-(NSMutableArray *)getAllCallRecords;

/**
 *  删除一条通话记录
 *  @param tel_id 每条记录的id
 */
-(void)deleteACallRecord:(int)tel_id;


#pragma mark -- MSG RECORDS
//==================================================================

/**
 *  添加信息记录数据
 *  @param datas DBDatas
 */
-(void)addDatasToMsgRecord:(DBDatas *)datas;

/**
 *  获取所有信息记录
 *  @return mutArray(DBDatas,)
 */
-(NSMutableArray *)getAllMessages;

/**
 *  查询一个会话的所有内容 
 *  @param  number 号码
 */
-(NSMutableArray *)getAConversation:(NSString *)number;

/**
 *  删除一个信息会话
 *  @param number 对方号码
 */
-(void)deleteAConversation:(NSString *)number;

/**
 *  删除一个信息会话里的一条
 *  @param propleid id
 */
-(void)deleteAMsgRecord:(int)peopleid;

/**
 *  查询一个会话的最后一条记录
 *  @param hisNumber 对方号码
 */
-(DBDatas *)getLastMsgRecord:(NSString *)hisNumber;

/**
 *  查询所有与输入相匹配的信息内容，
 *  @param string 输入
 *  @return mutArray(会话)
 */
-(NSMutableArray *)getAllMsgFromInput:(NSString *)string;


#pragma mark -- NUMBER AREAS
/**
 *  获取号码归属地
 *  @param number 号码
 */
-(NSString *)getAreaWithNumber:(NSString *)number;

@end
