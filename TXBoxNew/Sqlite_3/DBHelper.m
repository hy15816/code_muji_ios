//
//  DBHelper.m
//  TXBoxNew
//
//  Created by Naron on 15/8/19.
//  Copyright (c) 2015年 playtime. All rights reserved.
//
#define CALL_RECORD @"CALL_RECORDS"
#define MSG_RECORD @"MSG_RECORD"

#import "DBHelper.h"
#import "NSString+helper.h"

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
    
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"saveData_8_26.db"];
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
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"sqlite"];
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
 *  使用本地数据库
 */
-(FMDatabase *)createDatabaseWith:(NSString *)path{
    FMDatabase *db = [FMDatabase databaseWithPath:path];
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
    //通话记录
    NSString *callRecord=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (tel_id integer primary key AUTOINCREMENT,hisNumber TEXT,callDirection TEXT,callLength TEXT,callBeginTime TEXT,hisHome TEXT,hisOperator TEXT,contactid,TEXT)",CALL_RECORD];
    
    //信息记录
    NSString *messageRecord=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (peopleId integer primary key AUTOINCREMENT,msgHisNum TEXT,msgTime TEXT,msgContent TEXT,msgState TEXT)",MSG_RECORD ];
    
    NSArray *sqlArray = @[callRecord,messageRecord];
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

#pragma mark -- ===================== CALL_RECORDS
/**
 *  添加数据
 *  @param datas DBDatas
 */
-(void)addDatasToCallRecord:(DBDatas *)datas{
    FMDatabase *db=[self createDatabase];
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@ (hisNumber ,callDirection ,callLength,callBeginTime ,hisHome ,hisOperator,contactid ) values(?,?,?,?,?,?,?)",CALL_RECORD];
    BOOL result = [db executeUpdate:insertSql,datas.hisNumber,datas.callDirection,datas.callLength,datas.callBeginTime,datas.hisHome,datas.hisOperator,datas.contactID];
    if (!result) {
        NSLog(@"保存通话记录失败");
    }
    [db close];
}


/**
 *  获取所有通话记录
 *  @return mutArray(DBDatas,)
 */
-(NSMutableArray *)getAllCallRecords{
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM %@",CALL_RECORD];
    FMDatabase *db=[self createDatabase];
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
        
        DBDatas *datas = [[DBDatas alloc] init];
        datas.tel_id = [rs intForColumn:@"tel_id"];
        datas.hisNumber = [rs stringForColumn:@"hisNumber"];
        datas.callDirection = [rs stringForColumn:@"callDirection"];
        datas.callLength = [rs stringForColumn:@"callLength"];
        datas.callBeginTime = [rs stringForColumn:@"callBeginTime"];
        datas.hisHome = [rs stringForColumn:@"hisHome"];
        datas.hisOperator = [rs stringForColumn:@"hisOperator"];
        datas.contactID = [rs stringForColumn:@"contactid"];
        
        [mutArray addObject:datas];
    }
    [rs close];
    
    return mutArray;
}

/**
 *  删除一条通话记录
 *  @param tel_id 每条记录的id
 */
-(void)deleteACallRecord:(int )tel_id{
    
    FMDatabase *db = [self createDatabase];
    BOOL delete = [db executeUpdate:@"delete from CALL_RECORDS WHERE tel_id = ?",[NSNumber numberWithInt:tel_id]];
    if (!delete) {
        NSLog(@"删除记录失败");
    }
    [db close];
}

#pragma mark -- ===================== MSG_RECORDS

/**
 *  添加信息记录数据
 *  @param datas DBDatas
 */
-(void)addDatasToMsgRecord:(DBDatas *)datas{

    FMDatabase *db=[self createDatabase];
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@(msgHisNum,msgTime,msgContent,msgState) values(?,?,?,?)",MSG_RECORD];
    BOOL result = [db executeUpdate:insertSql,datas.msgHisNum,datas.msgTime,datas.msgContent,datas.msgState];
    if (!result) {
        NSLog(@"保存信息记录失败");
    }
    [db close];
}


/**
 *  获取所有信息记录
 *  @return mutArray(DBDatas,)
 */
-(NSMutableArray *)getAllMessages{

    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT *FROM %@",MSG_RECORD];
    FMDatabase *db=[self createDatabase];
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
        
        DBDatas *datas = [[DBDatas alloc] init];
        datas.peopleId = [rs intForColumn:@"peopleId"];
        datas.msgHisNum = [rs stringForColumn:@"msgHisNum"];
        datas.msgTime = [rs stringForColumn:@"msgTime"];
        datas.msgContent = [rs stringForColumn:@"msgContent"];
        datas.msgState = [rs stringForColumn:@"msgState"];
        
        [mutArray addObject:datas];
    }
    [rs close];

    
    return mutArray;
}

/**
 *  查询一个会话的所有内容
 *  @param  number 号码
 */
-(NSMutableArray *)getAConversation:(NSString *)number{
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    number = [number purifyString];
    DBDatas *datas = [[DBDatas alloc] init];
    
    FMDatabase *db=[self createDatabase];
    FMResultSet *rs=[db executeQuery:@"SELECT *FROM MSG_RECORD  where msgHisNum=? ",number];
    while ([rs next]) {
        datas.peopleId = [rs intForColumn:@"peopleId"];
        datas.msgHisNum = [rs stringForColumn:@"msgHisNum"];
        datas.msgTime = [rs stringForColumn:@"msgTime"];
        datas.msgContent = [rs stringForColumn:@"msgContent"];
        datas.msgState = [rs stringForColumn:@"msgState"];
        [mutArray addObject:datas];
    }
    
    return mutArray;
}


/**
 *  删除一个信息会话
 *  @param number 对方号码
 */
-(void)deleteAConversation:(NSString *)number{
    number = [number purifyString];//去除特殊符号等
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE msgHisNum= %@",MSG_RECORD,number];
    FMDatabase *db=[self createDatabase];
    BOOL delete = [db executeUpdate:deleteSql];
    if (!delete) {
        NSLog(@"删除会话失败");
    }
    [db close];
    
}

/**
 *  删除一个信息会话里的一条
 *  @param propleid id
 */
-(void)deleteAMsgRecord:(int)peopleid{
    
    FMDatabase *db=[self createDatabase];
    BOOL delete = [db executeUpdate:@"DELETE FROM MSG_RECORD WHERE peopleId = ?",[NSNumber numberWithInt:peopleid]];
    if (!delete) {
        NSLog(@"删除单条信息失败");
    }
    [db close];
}

/**
 *  查询一个会话的最后一条记录
 *  @param hisNumber 对方号码
 */
-(DBDatas *)getLastMsgRecord:(NSString *)hisNumber{
    hisNumber = [hisNumber purifyString];
    DBDatas *datas = [[DBDatas alloc] init];

    FMDatabase *db=[self createDatabase];
    FMResultSet *rs=[db executeQuery:@"SELECT *FROM MSG_RECORD  where msgHisNum=? order by peopleId desc limit 1",hisNumber];
    while ([rs next]) {
        datas.peopleId = [rs intForColumn:@"peopleId"];
        datas.msgHisNum = [rs stringForColumn:@"msgHisNum"];
        datas.msgTime = [rs stringForColumn:@"msgTime"];
        datas.msgContent = [rs stringForColumn:@"msgContent"];
        datas.msgState = [rs stringForColumn:@"msgState"];
    }
    
    return datas;
}

/**
 *  查询所有与输入相匹配的信息内容，
 *  @param string 输入
 *  @return mutArray(会话)
 */
-(NSMutableArray *)getAllMsgFromInput:(NSString *)string{
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    FMDatabase *db=[self createDatabase];
    NSString *selectSql = [NSString stringWithFormat:@"SELECT *FROM %@ WHERE  msgHisNum LIKE '%@' OR msgContent LIKE '%@' ",MSG_RECORD,string,string];
    FMResultSet *rs=[db executeQuery:selectSql];
    while ([rs next]) {
        DBDatas *datas = [[DBDatas alloc] init];
        datas.peopleId = [rs intForColumn:@"peopleId"];
        datas.msgHisNum = [rs stringForColumn:@"msgHisNum"];
        datas.msgTime = [rs stringForColumn:@"msgTime"];
        datas.msgContent = [rs stringForColumn:@"msgContent"];
        datas.msgState = [rs stringForColumn:@"msgState"];
        [mutArray addObject:datas];
    }
    
    return mutArray;
}

#pragma mark -- ===================== NUMBER_AREA

/**
 *  获取号码归属地
 *  @param number 号码
 */
-(NSString *)getAreaWithNumber:(NSString *)number{
    number = [number purifyString];
    if ([[number substringToIndex:3] isEqualToString:@"+86"]) {
        number = [number substringFromIndex:3];
    }
    if (number.length >=7) {
        number = [number substringToIndex:7];//获取号码钱7位即可查询
    }
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"PhoneArea" ofType:@"db"];
    FMDatabase *db = [self createDatabaseWith:dbPath];
    NSString *area = [[NSString alloc] init];
    NSString *areaCode ;
    NSString *selectSql = [NSString stringWithFormat:@"select * from numarea where number = %@",number];
    FMResultSet *rs = [db executeQuery:selectSql];//查询地区码，
    while ([rs next]) {
        //NSString *number = [rs stringForColumn:@"number"];
        areaCode = [rs stringForColumn:@"areacode"];
    }
    NSString *selectAreaSql = [NSString stringWithFormat:@"select *from areas where areacode = %@",areaCode];
    FMResultSet *rsa = [db executeQuery:selectAreaSql];//根据地区码查询归属地，
    while ([rsa next]) {
        area = [rsa stringForColumn:@"area"];
        area = [area purifyString];
        area = [area substringFromIndex:1];
        area = [area substringToIndex:area.length -1];
    }
    
    return area.length>0?area:@"未知地区";
}


@end
