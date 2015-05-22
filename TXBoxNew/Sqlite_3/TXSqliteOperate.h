//
//  TXSqliteOperate.h
//  TXBox
//
//  Created by Naron on 15/3/30.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXData.h"
#import <sqlite3.h>
#import "Common.h"
//#import "/usr/include/sqlite3.h"

@interface TXSqliteOperate : NSObject

{
    NSFileManager *fileManager; //文件管理器
    sqlite3 *dataBase;
    sqlite3_stmt *stmt;
    char *msg;
    NSMutableArray *mutArray;//所有信息
    NSMutableArray *recordsArray;  //会话中的每条信息
    NSMutableArray *conversationArray;  //会话
}

//============共用===============
-(BOOL)openDatabase;    //打开数据库
-(void)createTable:(NSString *)tableName withSql:(NSString *)sqlSring;     //创建表
-(void)addInfo:(TXData *)tel inTable:(NSString *)table withSql:(NSString *)sqlSring; ;//添加

//
-(NSMutableArray *)searchInfoFromTable:(NSString *)table ;//查找记录
-(void)deleteContacterWithNumber:(NSString *)hisNumber formTable:(NSString *)table msgTime:(NSString *)time withSql:(NSString *)sqlSring; ;//删除

-(void)deleteTableWithName:(NSString *)table;//删除整张表

-(NSMutableArray *)searchARecordWithNumber:(NSString *)hisNumber fromTable:(NSString *)table withSql:(NSString *)sqlString;//查询某一次整个会话


-(NSMutableArray *)searchConversationFromtable:(NSString *)table hisNumber:(NSString *)number wihtSqlString:(NSString *)sqlString; //查询某一次会话的最后一条
;

@end
