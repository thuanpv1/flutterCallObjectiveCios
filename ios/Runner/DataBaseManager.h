//
//  DataBaseManager.h
//  TestSQLite
//
//  Created by luo king on 11-12-17.
//  Copyright 2011 cctv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "PTZXPicture.h"
@interface DataBaseManager : NSObject {
	sqlite3* database;
    NSConditionLock *lock;
}

-(BOOL)addPTZXPicture:(PTZXPicture *)ptxPicture;
-(BOOL)addPTZXPicture:(int)nPTZXID devid:(int)nDevID data:(NSData *)imageData;
-(BOOL)updatePTZXPic:(int)nPTZXID devid:(int)nDevID data:(NSData *)imageData;
-(BOOL)removePTZXPic:(int)nPTZXID devid:(int)nDevID;
-(NSArray *)getPTZXPicByDevID:(int)nDevID;
-(NSArray *)getPTZXPicByDevID:(int)nDevID addPTZID:(int)nPTZID;
-(BOOL) isPTZXPicExist:(int)nDevID ID:(int) nPTZXID;
-(BOOL)cleanPTZXPic;

@end
