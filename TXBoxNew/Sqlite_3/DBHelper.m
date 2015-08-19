//
//  DBHelper.m
//  TXBoxNew
//
//  Created by Naron on 15/8/19.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper


+ (DBHelper *)sharedDBHelper{
    static dispatch_once_t once;
    static DBHelper *_sharedDBHelper;
    dispatch_once(&once, ^{
        _sharedDBHelper = [[DBHelper alloc] init];
    });
    return _sharedDBHelper;
}

/**
 *  获取数据库路径
 *  @return 数据库路径
 */
-(NSString *)dbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"saveData.db"];
    return dbPath;
}

/**
 *  将数据库文件拷贝到Documen目录下
 */
- (void)copyDBFileToDocumentPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *dbPath = [self dbPath];
    if (![fileManager fileExistsAtPath:dbPath])
    {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"PhoneAreas" ofType:@"sqlite"];
        [fileManager copyItemAtPath:resourcePath toPath:dbPath error:&error];
    }
}


/**
 *  获取FMDatabase对象
 *  @return FMDatabase对象
 */
- (FMDatabase *)createDatabase{
    FMDatabase *db = [FMDatabase databaseWithPath:[self dbPath]];
    if (![db open])
    {
        return nil;
    }
    
    return db;
}

/**
 *  创建表
 */
-(void)createTable{
    //
    NSString *ReadState=@"CREATE TABLE IF NOT EXISTS ";
    
    //
    NSString *systemMessage=@"";
    //
    NSString *sessionSQL = @"";
    //
    
    
    NSArray *sqlArray = @[ReadState,sessionSQL,systemMessage];
    for(NSString *sql in sqlArray){
        [self createTableForSql:sql];
    }
}


/**
 *  根据SQL语句创建表
 *  @param sql SQL语句
 */
-(void)createTableForSql:(NSString *)sql{
    FMDatabase *db=[self createDatabase];
    BOOL res = [db executeUpdate:sql];
    if(!res){
        
        NSLog(@"creating table Fail");
    }
    [db close];
}


//获取所有通话记录
-(NSMutableArray *)getAllCallRecords{
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    
    return mutArray;
}
//获取所有信息记录
-(NSMutableArray *)getAllMessages{

    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    
    return mutArray;
}

/**
 *  获取号码归属地
 *  @param number 号码
 */
-(NSString *)getAreaWithNumber:(NSString *)number{

    NSString *area = [[NSString alloc] init];
    
    return area;
}


@end
