//
//  EDDataBase.m
//  FaceSDKDemo
//
//  Created by edie.young on 2018/4/7.
//  Copyright © 2018年 Yang Yunxing. All rights reserved.
//

#import "EDDataBase.h"

static EDDataBase *db;    //全局静态实例变量
@implementation EDDataBase
//获取实例
+ (EDDataBase *)defaultDB
{
    if (!db)
    {
        db = [[EDDataBase alloc]init];
    }
    return db;
}


//打开数据库
- (BOOL)openDB:(NSString *)sqlName
{
    //获取本地数据库保存路径
    NSString *sqlPath = @"/Users/edieyoung/ADtest.db";
    int result = sqlite3_open([sqlPath UTF8String], &sqlite);
    if (result == SQLITE_OK) {
        return YES;    //获取成功返回YES，不过测试发现，如果该路径下没有数据库文件则会自动创建一个数据库
    }
    
    return NO;
}
//关闭数据库
- (BOOL)closeDB
{
    int result = sqlite3_close(sqlite);
    if (result == SQLITE_OK) {
        return YES;
    }
    return NO;
}
//创建表语法:   CREATE TABLE 表名 (列名),
- (BOOL)createTable:(NSString *)tableName
{
    char *err;
    
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"create table %@(page,type,message,create_time)",tableName];
    
    NSLog(@"[Create SQL] : %@",sql);
    
    int result = sqlite3_exec(sqlite, [sql UTF8String], NULL, NULL, &err);
    
    if (result == SQLITE_OK) {
        NSLog(@"[Create SQL] : %@",sql);
        return YES;
    }else {
        NSLog(@"[Create SQL] : Fail");
        NSLog(@"error = %s",err);
    }
    
    return NO;
}
//创建列语法:   alter table tableName（表名） add columnName（列名)
- (BOOL)createColumn:(NSString *)column tableName:(NSString *)tableName
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add %@",tableName,column];
    NSLog(@"[Create SQL] : %@",sql);
    
    int result = sqlite3_exec(sqlite, [sql UTF8String], NULL, NULL, &err);
    
    if (result == SQLITE_OK) {
        NSLog(@"[Create SQL] : OK");
        return YES;
    }else {
        NSLog(@"[Create SQL] : Fail");
        NSLog(@"error = %s",err);
    }
    
    return NO;
}
//增加数据语法 insert into 表名 (列) values(值)   ,这里要注意的是，值必须用 '' 包含，如 values('page','type','message','createtime')，方法里面没写是因为调用时传入的string已经写好
- (BOOL)insertSQLWithColumnName:(NSString *)columnName columnValue:(NSString *)columnValue tableName:(NSString *)tableName
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ values(%@)",tableName,columnValue];
    NSLog(@"[Insert SQL] : %@",sql);
    
    int result = sqlite3_exec(sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        NSLog(@"[DB Insert] : OK");
        return YES;
    }else {
        NSLog(@"[DB Insert] : Fail");
        NSLog(@"error = %s",err);
    }
    
    return NO;
}
//删除数据语法: delete from 表名 where 条件，条件写法为 列='值'，如 page='1'，或者page='1' and message='内容'。当然条件写法有很多种，这里只是介绍其中一种。
- (BOOL)deleteSQLWithWhereStr:(NSString *)whereStr tableName:(NSString *)tableName
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@",tableName,whereStr];
    NSLog(@"[Delete SQL] : %@",sql);
    
    int result = sqlite3_exec(sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        NSLog(@"[DB Delete] : OK");
        return YES;
    }else {
        NSLog(@"[DB Delete] : Fail");
        NSLog(@"error = %s",err);
    }
    
    return NO;
}
//更改数据语法:update 表名 set 新数据 where 旧数据，这里的写法也有很多，如 set page='1' where page='2'
- (BOOL)updateSQLWithNewColumnsKeyAndValue:(NSString *)newColumnsKeyAndValue whereStr:(NSString *)whereStr tableName:(NSString *)tableName
{
    char *err;
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@",tableName,newColumnsKeyAndValue,whereStr];
    NSLog(@"[Update SQL] : %@",sql);
    
    int result = sqlite3_exec(sqlite, [sql UTF8String], NULL, NULL, &err);
    if (result == SQLITE_OK) {
        NSLog(@"[DB Update] : OK");
        return YES;
    }else {
        NSLog(@"[DB Update] : Fail");
        NSLog(@"error = %s",err);
    }
    
    return NO;
}
//查找数据语法:select 列名 from  表名
//关于查找数据的语法就相对复杂一些，下面也只是列举了一部分而已
//简单说一下吧。order by 根据指定的列对查询到的数据进行排序，默认升序，如果要降序则order by 列名 DESC；
//limit 是指获取多少条数据，小于0获取全部，大于0获取limit条
// * 代表所有列。属于将全部列写进去的快捷方法
//where=1，因为where代表条件语句，=1说明绝对为真，属于无约束查询


@end
