//
//  DataBaseManager.m
//  TestSQLite
//
//  Created by luo king on 11-12-17.
//  Copyright 2011 cctv. All rights reserved.
//

#import "DataBaseManager.h"
#import "AppDelegate.h"

@interface DataBaseManager(private)

@end

@implementation DataBaseManager
//Initialize the database
-(id)init{   
    if (self= [super init]) {
        lock = [[NSConditionLock alloc] init];
    }
    return self;
}

-(BOOL)addPTZXPicture:(int)nPTZXID devid:(int)nDevID data:(NSData *)imageData{
    if (nPTZXID<0 || nDevID<0) {
        return NO;
    }
    [lock lock];
    BOOL sucess=[self openDatabase];
    if (sucess) {
        
        char *sql="insert into ptzx_picture(id, dev_id, ptzx_id, image_data) values(null,?,?,?)";
                
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL)==SQLITE_OK){
            sqlite3_bind_int(statement, 1, nDevID);
            sqlite3_bind_int(statement, 2, nPTZXID);
            
            if (imageData) {
                
                if (imageData) {
                    sqlite3_bind_blob(statement, 3, [imageData bytes], (int)[imageData length], NULL);
                }
                
            }
            if(sqlite3_step(statement)!=SQLITE_DONE){
                
                sucess=NO;
            }
            else{
            }
            
            sqlite3_finalize(statement);
        }
    }
    [self closeDatabase];
    
    [lock unlock];
    return sucess;
}
-(BOOL)addPTZXPicture:(PTZXPicture *)ptxPicture{
    if (ptxPicture==nil) {
        return NO;
    }
    [lock lock];
    BOOL sucess=[self openDatabase];
    if (sucess) {
        
        char *sql="insert into ptzx_picture(id, dev_id, ptzx_id, image_data) values(null,?,?,?)";
                
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL)==SQLITE_OK){
            sqlite3_bind_int(statement, 1, [ptxPicture nDevID]);
            sqlite3_bind_int(statement, 2, [ptxPicture nPTZXID]);
            
            if ([ptxPicture imageData]) {
                NSData *imageData = UIImagePNGRepresentation([ptxPicture imageData]);
                if (imageData) {
                    sqlite3_bind_blob(statement, 3, [imageData bytes], (int)[imageData length], NULL);
                }
            }
            if(sqlite3_step(statement)!=SQLITE_DONE){
                sucess=NO;
            }
            
            sqlite3_finalize(statement);
        }
        
    }
    [self closeDatabase];
    
    [lock unlock];
    return sucess;
    
}

-(NSArray *)getPTZXPicByDevID:(int)nDevID{
    NSMutableArray *ptzxPicList=nil;
    [lock lock];
    BOOL sucess=[self openDatabase];
    if (sucess) {
        
        
        NSString *sql= [NSString stringWithFormat: @"select * from ptzx_picture where dev_id=%i and ptzx_id < 100", nDevID];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL)==SQLITE_OK) {
            ptzxPicList=[[NSMutableArray alloc] init];
            
            while (sqlite3_step(statement)==SQLITE_ROW) {
                                
                const int nID = sqlite3_column_int(statement, 0);
                const int nDevID = sqlite3_column_int(statement, 1);
                const int nPTZXID = sqlite3_column_int(statement, 2);
                int bytes = sqlite3_column_bytes(statement, 3);
                const void *pImageData= sqlite3_column_blob(statement, 3);
                                
                PTZXPicture *ptzxPic = [[PTZXPicture alloc] init];
                if (ptzxPic) {
                    [ptzxPic setNID:nID];
                    [ptzxPic setNDevID:nDevID];
                    [ptzxPic setNPTZXID:nPTZXID];
                    if (bytes>0 && pImageData!=NULL) {
                        NSData *imageData = [NSData dataWithBytes:pImageData length:bytes];
                        
                        [ptzxPic setImageData:[UIImage imageWithData:imageData]];
                    }
                    [ptzxPicList addObject:ptzxPic];
                    
                }
            }
            sqlite3_finalize(statement);
        }
        
    }
    [self closeDatabase];
    [lock unlock];
    return ptzxPicList;
    
}

-(NSArray *)getPTZXPicByDevID:(int)nDevID addPTZID:(int)nPTZID{
    NSMutableArray *ptzxPicList=nil;
    [lock lock];
    BOOL sucess=[self openDatabase];
    if (sucess) {
        
        NSString *sql= [NSString stringWithFormat: @"select * from ptzx_picture where dev_id=%i and ptzx_id = %i", nDevID,nPTZID];
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL)==SQLITE_OK) {
            ptzxPicList=[[NSMutableArray alloc] init];
            
            while (sqlite3_step(statement)==SQLITE_ROW) {
                
                const int nID = sqlite3_column_int(statement, 0);
                const int nDevID = sqlite3_column_int(statement, 1);
                const int nPTZXID = sqlite3_column_int(statement, 2);
                int bytes = sqlite3_column_bytes(statement, 3);
                const void *pImageData= sqlite3_column_blob(statement, 3);
                                
                PTZXPicture *ptzxPic = [[PTZXPicture alloc] init];
                if (ptzxPic) {
                    [ptzxPic setNID:nID];
                    [ptzxPic setNDevID:nDevID];
                    [ptzxPic setNPTZXID:nPTZXID];
                    if (bytes>0 && pImageData!=NULL) {
                        NSData *imageData = [NSData dataWithBytes:pImageData length:bytes];
                        
                        [ptzxPic setImageData:[UIImage imageWithData:imageData]];
                    }
                    [ptzxPicList addObject:ptzxPic];
                    
                }
            }
            sqlite3_finalize(statement);
        }
        
    }
    [self closeDatabase];
    [lock unlock];
    return ptzxPicList;
    
}


-(BOOL)updatePTZXPic:(int)nPTZXID devid:(int)nDevID data:(NSData *)imageData{
    if (nPTZXID<0 || nDevID<=0 || imageData==nil || [imageData length]<=0) { //modify by zhantian
        return NO;
    }
    
    [lock lock];
    BOOL sucess=[self openDatabase];
    if (sucess) {
        NSString *sql =[NSString stringWithFormat:@"update ptzx_picture set image_data=? where dev_id=%d and ptzx_id=%d", nDevID, nPTZXID] ;
        sqlite3_stmt * statement;
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL)==SQLITE_OK){
            sqlite3_bind_blob(statement, 1, [imageData bytes], (int)[imageData length], NULL);
            int result=sqlite3_step(statement);
            if (result!=SQLITE_DONE) {
                sucess=NO;
            }
        }
        sqlite3_finalize(statement);
        
    }
    [self closeDatabase];
    [lock unlock];
    return sucess;
}
-(BOOL)removePTZXPic:(int)nPTZXID devid:(int)nDevID{
    [lock lock];
    BOOL sucess=[self openDatabase];
    if (sucess) {
        NSString *sql =[NSString stringWithFormat:@"delete from ptzx_picture where dev_id=%d and ptzx_id=%d", nDevID, nPTZXID] ;
        sqlite3_stmt * statement;

        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL)==SQLITE_OK){
            int result=sqlite3_step(statement);
            if (result!=SQLITE_DONE) {
                sucess=NO;
            }
        }
        sqlite3_finalize(statement);
    }
    [self closeDatabase];
    [lock unlock];
    return sucess;
}

-(BOOL) isPTZXPicExist:(int)nDevID ID:(int) nPTZXID{
    if (nPTZXID<0 || nDevID<0) {
        return NO;
    }
    BOOL bIsExist=NO;
    [lock lock];
    BOOL sucess=[self openDatabase];
    if (sucess) {
        
        NSString *sql= [NSString stringWithFormat: @"select id from ptzx_picture where dev_id=%d and ptzx_id=%d", nDevID, nPTZXID];
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL)==SQLITE_OK) {
            
            if (sqlite3_step(statement)==SQLITE_ROW) {
                
                int nID = sqlite3_column_int(statement, 0);
                
                if (nID>0) {
                    bIsExist=YES;
                }
                
            }
            sqlite3_finalize(statement);
        }
        
    }
    [self closeDatabase];
    [lock unlock];
    return bIsExist;
}

-(BOOL)cleanPTZXPic{
    [lock lock];
    BOOL sucess=[self openDatabase];
    if (sucess) {
        
        char *sql="delete from ptzx_picture";
        if(sqlite3_exec(database, sql,NULL,NULL,NULL)!=SQLITE_OK){//Whether the deletion is successful
            sucess=NO;
        }
        
    }
    [self closeDatabase];
    [lock unlock];
    return sucess;
}

// Determine whether to create a database according to whether the database already exists
-(void)createDatabaseIfNeeded:(NSString *)filename{
    NSFileManager *filemanage=[NSFileManager defaultManager];
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory=[paths objectAtIndex:0];
    
    NSString *writableDBPath=[documentsDirectory stringByAppendingPathComponent:filename];
    
    
    BOOL sucess=[filemanage fileExistsAtPath:writableDBPath];
    if (sucess) {
        return;
    }
    
    NSString *defaultDBPath=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    NSError *error;
    sucess=[filemanage copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!sucess) {
    }
}
//Get the database file path
-(NSString *)dataFilePath{  
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"demo_database.sqlite"];
    return documentPath;
}

//open database
-(BOOL)openDatabase{    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"demo_database.sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL find = [fileManager fileExistsAtPath:path];
//find the database file database.sqlite
    if (find) {
        if(sqlite3_open([path UTF8String], &database) != SQLITE_OK) {
            sqlite3_close(database);
            return NO;
        }
        return YES;
    }
    if(sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        
        return YES;
        
    } else {
        
        sqlite3_close(database);
        return NO;
        
    }
    return NO;
}

//close the database
-(void)closeDatabase{
    if (database) {
        if (sqlite3_close(database)!=SQLITE_OK) {
            //        DLog(@"close Database error:%@",sqlite3_errmsg(database));
        }
        database = NULL;
    }
}

@end
