//
//  HZDBMacro.h
//  FMDBUtil
//
//  Created by Khzliu on 14-10-20.
//  Copyright (c) 2014年 khzliu. All rights reserved.
//

#ifndef FMDBUtil_HZDBMacro_h
#define FMDBUtil_HZDBMacro_h

//数据名称
#define SqliteDatabaseName @"data.sqlite"
// 文件或者文件夹路径
#define HZFilePath(fileName) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:(fileName)]


#endif
