//
//
//  TXSqliteOperate.m
//  TXBox
//
//  Created by Naron on 15/3/30.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXSqliteOperate.h"
#import "NSString+helper.h"

@implementation TXSqliteOperate//

+(TXSqliteOperate *)shardSql{
    
    static dispatch_once_t once;
    static TXSqliteOperate *_sqliteOP;
    dispatch_once(&once, ^{
        _sqliteOP = [[TXSqliteOperate alloc] init];
    });
    return _sqliteOP;
    
}

#pragma mark --打开数据库
-(BOOL)openDatabase
{
    //文件的路径
    NSString *path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",DB_NAME]];
    
    VCLog(@"sqlite3_path:%@",path);
    //若数据库存在就打开，不存在就创建，
    //[path UTF8String]把字符串转成char。。。SQLITE_OK常量0
    if (sqlite3_open([path UTF8String], &dataBase)==SQLITE_OK) {
        //NSLog(@"is open");
        return YES;
    }
    
    return NO;
}

#pragma mark --建表
-(void)createTable{
    //通话记录
    NSString *callRecordSql =[NSString stringWithFormat:@"create table if not exists %@(tel_id integer primary key AUTOINCREMENT,hisName text,hisNumber text,callDirection text,callLength text,callBeginTime text,hisHome text,hisOperator text)",CALL_RECORDS_TABLE_NAME] ;
    //短息
    NSString *msgRecordSql = [NSString stringWithFormat:@"create table if not exists %@(peopleId integer primary key AUTOINCREMENT,msgSender text,msgTime text,msgContent text,msgAccepter text,msgState text)",MESSAGE_RECEIVE_RECORDS_TABLE_NAME];
    NSArray *sqlArray = @[callRecordSql,msgRecordSql];
    
    if ([self openDatabase]) {
        
        for (NSString *sql in sqlArray) {
            //执行sql语句
            if (sqlite3_exec(dataBase, [sql UTF8String], NULL, NULL, &msg)==SQLITE_OK) {
                VCLog(@"create table success !");
            }else{
                VCLog(@"create table error:%s",msg);
                //清空错误信息
                sqlite3_free(msg);
            }

        }
        
    }else {
        VCLog(@"sqlite ...");
    }
    
    //关闭数据库
    sqlite3_close(dataBase);
    
}
-(void)createTable:(NSString *)tableName withSql:(NSString *)sqlSring;
{
    if ([self openDatabase]) {
        //sql语句AUTOINCREMENT
        NSString *sql = [NSString stringWithFormat:sqlSring,tableName];
        
        //执行sql语句
        if (sqlite3_exec(dataBase, [sql UTF8String], NULL, NULL, &msg)==SQLITE_OK) {
            VCLog(@"create table success !");
        }else{
            VCLog(@"create table error:%s",msg);
            //清空错误信息
            sqlite3_free(msg);
        }

    }else {
        VCLog(@"sqlite ...");
    }
    
    //关闭数据库
    sqlite3_close(dataBase);
    
}

#pragma mark --插入(添加)数据

-(void)addInfo:(TXData *)data inTable:(NSString *)table withSql:(NSString *)sqlSring;
{
    VCLog(@"******** sender:%@,T:%@,cont:%@,accp:%@,state:%@",data.msgSender,data.msgTime,data.msgContent,data.msgAccepter,data.msgStates);
    if ([self openDatabase]) {

        //NSString *insertSql = [NSString stringWithFormat:@"insert into tels(tel_number) values(?)"];
        NSString *insertSql = [NSString stringWithFormat:sqlSring,table];
        
        if (sqlite3_prepare_v2(dataBase, [insertSql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            VCLog(@"insert prepare ok");
        }else{
            VCLog(@"insert prepare error:%s",msg);
            //清空错误信息
            sqlite3_free(msg);
        }
        //通话记录
        if ([sqlSring isEqualToString:CALL_RECORDS_ADDINFO_SQL]) {
            //sqlite3_bind_int(stmt,1, data.tel_id);
            sqlite3_bind_text(stmt, 1, [data.hisName UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [data.hisNumber UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [data.callDirection UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [data.callLength UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 5, [data.callBeginTime UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 6, [data.hisHome UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 7, [data.hisOperator UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 8, [data.contactID UTF8String], -1, NULL);
        }
        //添加收信记录
        if ([sqlSring isEqualToString:MESSAGE_RECORDS_ADDINFO_SQL]) {
            
            //sqlite3_bind_int(stmt,1, data.tel_id);
            sqlite3_bind_text(stmt, 1, [data.msgSender UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 2, [data.msgTime UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [data.msgContent UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 4, [data.msgAccepter UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 5, [data.msgStates UTF8String], -1, NULL);
        }
        
        
        if (sqlite3_step(stmt) == SQLITE_DONE) {
            //清空错误信息
            sqlite3_free(msg);
            VCLog(@"insert success");
            
        }else
        {
            VCLog(@"insert msg:%s",msg);
        }
        
        sqlite3_reset(stmt);
        //关闭
        sqlite3_close(dataBase);
    }else{
        VCLog(@"sqlite ...");
    }
    
    
    
}

#pragma mark --查询

-(NSMutableArray *)searchInfoFromTable:(NSString *)table
{
     NSMutableArray *mutArray = [[NSMutableArray alloc] init];//所有信息
    
    if ([self openDatabase]) {
        
        NSString *selectSql = [NSString stringWithFormat:SELECT_ALL_SQL,table];
        
        if (sqlite3_prepare_v2(dataBase, [selectSql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
            VCLog(@"select prepare ok!");
        }
        
        //============所有通话记录===================
        if ([table isEqualToString:CALL_RECORDS_TABLE_NAME]) {
            //循环遍历，sqlite3_step处理一行结果
            while (sqlite3_step(stmt)==SQLITE_ROW) {
                
                int tid=sqlite3_column_int(stmt, 0);
                
                NSString *name = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
                NSString *number=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
                NSString *direction=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
                NSString *length=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
                NSString *beginTime=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5) encoding:NSUTF8StringEncoding];
                NSString *home=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 6) encoding:NSUTF8StringEncoding];
                NSString *operator=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 7) encoding:NSUTF8StringEncoding];
                NSString *contactid=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 8) encoding:NSUTF8StringEncoding];
                
                //VCLog(@"id = %d,date = %@",tid,date);
                
                TXData *data=[[TXData alloc] init];
                data.tel_id = tid;
                data.hisName=name;
                data.hisNumber=number;
                data.callDirection=direction;
                data.callLength = length;
                data.callBeginTime=beginTime;
                data.hisHome = home;
                data.hisOperator = operator;
                data.contactID = contactid;
                /*
                 [mutArray addObject:[NSString stringWithFormat:@"%d",tid]];
                 [mutArray addObject:number];
                 [mutArray addObject:date];
                 [mutArray addObject:operators];
                 [mutArray addObject:address];
                 [mutArray addObject:name];
                 */
                
                [mutArray addObject:data];//
            }
        }
        
        //====================所有接收的信息=============
        if ([table isEqualToString:MESSAGE_RECEIVE_RECORDS_TABLE_NAME]) {
            //循环遍历，sqlite3_step处理一行结果
            while (sqlite3_step(stmt)==SQLITE_ROW) {
                
                int tid=sqlite3_column_int(stmt, 0);
                
                NSString *sender = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
                NSString *beginTime=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
                NSString *content=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
                NSString *accepter=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
                NSString *state = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5) encoding:NSUTF8StringEncoding];
                //VCLog(@"id = %d,date = %@",tid,date);
                
                TXData *data=[[TXData alloc] init];
                data.peopleId = tid;
                data.msgSender=sender;
                data.msgTime=beginTime;
                data.msgContent = content;
                data.msgAccepter = accepter;
                data.msgStates = state;
                [mutArray addObject:data];//
                
            }
        }
        
        //删除预备语句
        sqlite3_finalize(stmt);
        //关闭
        sqlite3_close(dataBase);
        
        VCLog(@" mutArr=%@",mutArray);
        return mutArray;
    }
    
    
    return nil;
}



#pragma mark --删除-->根据联系人号码

-(void)deleteContacterWithNumber:(NSString *)hisNumber formTable:(NSString *)table peopleId:(NSString *)pId withSql:(NSString *)sqlSring
{
    if ([self openDatabase]) {
        
        NSString *deleteSql;
        //删除一条通话记录
        if ([sqlSring isEqualToString:DELETE_CALL_RECORD_SQL]) {
            deleteSql=[NSString stringWithFormat:sqlSring,table,hisNumber];
        }
        
        //删除单条短信记录，根据id和sender
        if ([sqlSring isEqualToString:DELETE_MESSAGE_RECORD_SQL]) {
            deleteSql = [NSString stringWithFormat:sqlSring,table,hisNumber,pId];
        }
        
        //删除整个短信会话
        if ([sqlSring isEqualToString:DELETE_MESSAGE_RECORD_CONVERSATION_SQL]) {
            deleteSql = [NSString stringWithFormat:sqlSring,table,hisNumber,hisNumber];
        }
        
        
        //执行语句
        if (sqlite3_exec(dataBase, [deleteSql UTF8String], nil, nil, &msg)==SQLITE_OK) {
            VCLog(@"delete number = %@ ok",hisNumber);
        }else{
            VCLog(@"error:%s",msg);
            sqlite3_free(msg);
        }
        
        sqlite3_close(dataBase);
        
    }else{
        VCLog(@"sqlite  。。。");
    }
    
}

#pragma mark --删除一张表
-(void)deleteTableWithName:(NSString *)table{
    
    if ([self openDatabase]) {
        
        NSString *deleteSql =[NSString stringWithFormat:@"drop table %@",table];
        
        
        if (sqlite3_exec(dataBase, [deleteSql UTF8String], nil, nil, &msg)==SQLITE_OK) {
            VCLog(@"delete table = %@ ok",table);
        }else{
            VCLog(@"error:%s",msg);
            sqlite3_free(msg);
        }
        
        sqlite3_close(dataBase);
        
    }else{
        VCLog(@"sqlite  。。。");
    }
}


#pragma mark -- 根据hisName查询某一次会话所有内容
-(NSMutableArray *)searchARecordWithNumber:(NSString *)hisNumber fromTable:(NSString *)table withSql:(NSString *)sqlString
{
    NSMutableArray *recordsArray = [[NSMutableArray alloc] init];//会话中的每条信息
    
    if ([self openDatabase]) {
        
        //修改sql语句
        NSString *selectSql = [NSString stringWithFormat:sqlString,table,hisNumber,hisNumber];
        
        if (sqlite3_prepare_v2(dataBase, [selectSql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
            VCLog(@"select prepare ok!");
        }
        
        //循环遍历，sqlite3_step处理一行结果
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            int tid=sqlite3_column_int(stmt, 0);
            
            NSString *sender = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            NSString *beginTime=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            NSString *content=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
            NSString *accepter=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
            NSString *state=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5) encoding:NSUTF8StringEncoding];
            //VCLog(@"id = %d,date = %@",tid,date);
            
            TXData *data=[[TXData alloc] init];
            data.peopleId = tid;
            data.msgSender=sender;
            data.msgTime=beginTime;
            data.msgContent = content;
            data.msgAccepter = accepter;
            data.msgStates = state;
            [recordsArray addObject:data];//
            VCLog(@"id:%d, sd:%@, st:%@, sc:%@, sa:%@, ss:%@",tid,sender,beginTime,content,accepter,state);
        }
        
        
        
        //删除预备语句
        sqlite3_finalize(stmt);
        //关闭
        sqlite3_close(dataBase);
        VCLog(@"msg records array :%@",recordsArray);
        return recordsArray;

    }
    
    return nil;
}

#pragma mark -- 根据hisName查某个会话
-(TXData *)searchConversationFromtable:(NSString *)table hisNumber:(NSString *)number wihtSqlString:(NSString *)sqlString
{
    //查某个会话
    NSMutableArray *conversationArray = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]) {
        
        //sql语句
        NSString *selectSql = [NSString stringWithFormat:sqlString,table,number,number];
        
        if (sqlite3_prepare_v2(dataBase, [selectSql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
            VCLog(@"select prepare ok!");
        }
        TXData *data=[[TXData alloc] init];
        //循环遍历，sqlite3_step处理一行结果
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            int tid=sqlite3_column_int(stmt, 0);
            
            NSString *sender = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            NSString *beginTime=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            NSString *content=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
            NSString *accepter=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
            
            //VCLog(@"id = %d,date = %@",tid,date);
            data.peopleId = tid;
            data.msgSender=sender;
            data.msgTime=beginTime;
            data.msgContent = content;
            data.msgAccepter = accepter;
        }
        [conversationArray addObject:data];//只取最后一个
        
        //删除预备语句
        sqlite3_finalize(stmt);
        //关闭
        sqlite3_close(dataBase);
        VCLog(@"a conversation array :%@",[conversationArray objectAtIndex:0]);
        return [conversationArray objectAtIndex:0];
        
    }
    
    return nil;
}

#pragma mark -- 查询所有与输入匹配的短信内容
-(NSMutableArray *)searchContentWithInputText:(NSString *)text fromTable:(NSString *)table withSql:(NSString *)sqlString{
    
    NSMutableArray *allContent = [[NSMutableArray alloc] init];
    if ([self openDatabase]) {
        
        
        //sql语句
        NSString *selectSql = [NSString stringWithFormat:sqlString,table,text,text,text];
        
        if (sqlite3_prepare_v2(dataBase, [selectSql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
            VCLog(@"select prepare ok!");
        }
        
        //循环遍历，sqlite3_step处理一行结果
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            TXData *data=[[TXData alloc] init];
            int tid=sqlite3_column_int(stmt, 0);
            
            NSString *sender = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            NSString *beginTime=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            NSString *content=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
            NSString *accepter=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
            
            //VCLog(@"id = %d,date = %@",tid,date);
            
            data.peopleId = tid;
            data.msgSender=sender;
            data.msgTime=beginTime;
            data.msgContent = content;
            data.msgAccepter = accepter;
            
            if (![allContent containsObject:data]) {
                [allContent addObject:data];
            }
        }
        
        
        //删除预备语句
        sqlite3_finalize(stmt);
        //关闭
        sqlite3_close(dataBase);
        VCLog(@"allContent :%@",allContent);
        
        return allContent;
    }
    
    return nil;
}


///////===============================================================================

-(BOOL)openPhoneArearDatabase
{
    //文件的路径
    //NSString *path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",DB_PHONE_AREAR_NAME]];
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"PhoneAreas" ofType:@"sqlite"];
    //VCLog(@"dbPath:%@",dbPath);
    //若数据库存在就打开，不存在就创建，
    //[path UTF8String]把字符串转成char。。。SQLITE_OK常量0
    if (sqlite3_open([dbPath UTF8String], &dataBase)==SQLITE_OK) {
        NSLog(@"is open");
        return YES;
    }
    
    
    return NO;
}

//
-(NSString *)searchAreacodeFromPhoneDB:(NSString *)hisNumber
{
    NSString *areacode;
    
    NSString *selectSql = [NSString stringWithFormat:@"select * from numarea where number = %@ ",hisNumber];
    
    if (sqlite3_prepare_v2(dataBase, [selectSql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
        VCLog(@"select prepare ok!");
    }
    
    //循环遍历，sqlite3_step处理一行结果
    while (sqlite3_step(stmt)==SQLITE_ROW) {
        
        // 0 number
        // 1 areacode
        areacode = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
        
        
    }
    
    //删除预备语句
    sqlite3_finalize(stmt);
    //关闭
    //sqlite3_close(dataBase);
    
    VCLog(@" areacode=%@",areacode);
    return areacode;
    

}

-(NSString *)searchAreaWithHisNumber:(NSString *)hisNumber
{
    if ([self openPhoneArearDatabase]) {
        NSString *acode = [self searchAreacodeFromPhoneDB:hisNumber];
        NSString *area;
        NSString *selectSql = [NSString stringWithFormat:@"select * from areas where areacode = %@  ",acode];
        
        if (sqlite3_prepare_v2(dataBase, [selectSql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
            VCLog(@"select prepare ok!");
        }
        
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            // 0 areacode   区号
            // 1 area       地区
            // 2 postCode   邮编
                
                
            area = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
                
                
        }
            
        //删除预备语句
        sqlite3_finalize(stmt);
        //关闭
        sqlite3_close(dataBase);
        
        VCLog(@" area=%@",area);
        if (area.length>0) {
            NSString *sarea = [area purifyString];
            return [sarea substringWithRange:NSMakeRange(1, sarea.length-2)];
        }else{
            return @" ";
        }
        
        
        
    }
    
    
    
    return nil;
}
///////===============================================================================




-(NSMutableArray *)searchAcontacterInfoFrom:(NSString *)table hisName:(NSString *)string withSqlString:(NSString *)sqlString
{
    NSMutableArray *numberArray =[[NSMutableArray alloc] init];
    if ([self openDatabase]) {
        
        
        
        
        
        
        return numberArray;
    }
    
    return nil;
}

-(NSMutableArray *)searchAcontacterInfoFrom:(NSString *)table hisNumber:(NSString *)string withSqlString:(NSString *)sqlString
{
    NSMutableArray *nameArray =[[NSMutableArray alloc] init];
    
    return nameArray;
    
}
@end
