//
//  EDDataBase.h
//  FaceSDKDemo
//
//  Created by edie.young on 2018/4/7.
//  Copyright © 2018年 Yang Yunxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<sqlite3.h>

@interface EDDataBase : NSObject

{
    sqlite3 *sqlite; //创建全局sqlite对象
}
    //获取实例
    + (EDDataBase *)defaultDB;
    //打开数据库
    - (BOOL)openDB:(NSString *)sqlName;
    //关闭数据库
    - (BOOL)closeDB;
    //创建表
    - (BOOL)createTable:(NSString *)tableName;
    //创建列
    - (BOOL)createColumn:(NSString *)column tableName:(NSString *)tableName;
    //增加数据
    - (BOOL)insertSQLWithColumnName:(NSString *)columnName columnValue:(NSString *)columnValue tableName:(NSString *)tableName;
    //删除数据
    - (BOOL)deleteSQLWithWhereStr:(NSString *)whereStr tableName:(NSString *)tableName;
    //更改数据
    - (BOOL)updateSQLWithNewColumnsKeyAndValue:(NSString *)newColumnsKeyAndValue whereStr:(NSString *)whereStr tableName:(NSString *)tableName;


@end

