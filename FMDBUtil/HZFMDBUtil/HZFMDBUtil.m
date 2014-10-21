//
//  HZFMDBUtil.m
//  FMDBUtil
//
//  Created by Khzliu on 14-10-20.
//  Copyright (c) 2014年 khzliu. All rights reserved.
//

#import "HZFMDBUtil.h"
#import "FMDB.h"

@implementation HZFMDBUtil

static FMDatabaseQueue *_queue;

+ (void)initialize{
    [self loadDatabase];
}

+ (void)loadDatabase{
    // 如果数据库文件不存在，说明表也不存在，则需要执行SQL语句创建表
    if(![[NSFileManager defaultManager] fileExistsAtPath:HZFilePath(SqliteDatabaseName)]){
        _queue = [FMDatabaseQueue databaseQueueWithPath:HZFilePath(SqliteDatabaseName)];
        [self loadDatabaseQueue];
    }
    
    // 创建t_table表
    if(![self tableIsExist:@"t_table"]){
        NSString *sql = @"create table if not exists t_information(id integer primary key autoincrement, info_id integer, catid integer, imageurl text, title text, keywords text, description text, contenturl text, inputtime text, updatetime text, content text);";
        [self createTableWithSQL:sql];
    }
    

}

+ (void)createTableWithSQL:(NSString *)sql{
    [_queue inDatabase:^(FMDatabase *db) {
        NSError * error;
        BOOL isSuccess = [db executeUpdate:sql withErrorAndBindings:&error];
        if (!isSuccess) {
            NSLog(@"执行的建表SQL语句: %@. \n失败原因: %@", sql, [error localizedDescription]);
        }
        [db close];
    }];
}

+ (BOOL)tableIsExist:(NSString *)tableName{
    NSString *sql = [NSString stringWithFormat:@"select count(*) as table_count from sqlite_master t where t.type = 'table' and t.name = '%@'", tableName];
    [self loadDatabaseQueue];
    __block BOOL isExist = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        if([rs next]){
            isExist = [rs intForColumn:@"table_count"];
        }
        [db close];
    }];
    [_queue close];
    return isExist;
}

+ (void)loadDatabaseQueue{
    _queue = [FMDatabaseQueue databaseQueueWithPath:HZFilePath(SqliteDatabaseName)];
}

+ (BOOL)executeUpdate:(NSString *)sql, ...{
    va_list args;
    // 初始化va_list指针变量,即将args指向sql
    va_start(args, sql);
    [self loadDatabaseQueue];
    __block BOOL isSuccess = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:sql withVAList:args];
        [db close];
    }];
    // 清空参数列表,置指针args无效
    va_end(args);
    [_queue close];
    return isSuccess;
}

+ (BOOL)executeUpdate:(NSString *)sql withArgumentsInArray:(NSArray *)argumentsArray{
    [self loadDatabaseQueue];
    __block BOOL isSuccess = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:sql withArgumentsInArray:argumentsArray];
        [db close];
    }];
    [_queue close];
    return isSuccess;
}

+ (HZResultSet *)executeQuery:(NSString *)sql, ...{
    va_list args;
    // 初始化va_list指针变量,即将args指向sql
    va_start(args, sql);
    [self loadDatabaseQueue];
    __block HZResultSet *resultSet = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withVAList:args];
        resultSet = [self convertResultSet:rs];
        [db close];
    }];
    // 清空参数列表,置指针args无效
    va_end(args);
    [_queue close];
    return resultSet;
}

+ (HZResultSet *)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)argumentsArray{
    [self loadDatabaseQueue];
    __block HZResultSet *resultSet = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:argumentsArray];
        resultSet = [self convertResultSet:rs];
        [db close];
    }];
    [_queue close];
    return resultSet;
}

/**
 *  结果转换，将FMResultSet转换为HZResultSet
 *
 *  @param rs FMDB结果集
 *
 *  @return 自定义结果集
 */
+ (HZResultSet *)convertResultSet:(FMResultSet *)rs{
    HZResultSet *resultSet = [[HZResultSet alloc] init];
    [resultSet setColumnNameToIndexMap:rs.columnNameToIndexMap];
    NSMutableArray *resultSetArray = [NSMutableArray array];
    int columnCount = [rs columnCount];
    while ([rs next]) {
        NSMutableDictionary *valuesMap = [NSMutableDictionary dictionary];
        for(int i = 0; i < columnCount; i ++){
            // 以小写key存储
            NSString *columnName = [[rs columnNameForIndex:i] lowercaseString];
            id columnValue = [rs objectForColumnIndex:i];
            [valuesMap setValue:columnValue forKey:columnName];
        }
        [resultSetArray addObject:valuesMap];
    }
    [resultSet setResultSet:[resultSetArray copy]];
    return resultSet;
}

+ (BOOL)executeStatements:(NSString *)sql{
    [self loadDatabaseQueue];
    __block BOOL isSuccess = NO;
    [_queue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeStatements:sql];
        [db close];
    }];
    [_queue close];
    return isSuccess;
}

@end
