//
//  RecordVideoDownloader.h
//  NVSDK
//
//  Created by caffe on 2019/2/22.
//  certified by caffe on 20190325
//  Copyright © 2019 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LoginHandle.h"
#import "RecordVideoInfo.h"


#define DOWNLOAD_PROC_DOWNLOADING 10
#define DOWNLOAD_PROC_FINISH 11
#define DOWNLOAD_PROC_CONNECTING 12
#define DOWNLOAD_PROC_CLOSE -10
#define DOWNLOAD_PROC_NET_ERR -11
#define DOWNLOAD_PROC_BREAK 1

NS_ASSUME_NONNULL_BEGIN

@protocol RecordVideoDownloadDelegate <NSObject>
//-(void)onProcessChange:(int)nTotalCount size:(int)nRecv result:(int) nResult;//搜索录像文件接收函数
-(void)onDownloadProcess:(id)downloader flag:(int)nFlag process:(int) nProcess;//
@end

@interface RecordVideoDownloader : NSObject
@property (assign) int nTag;
@property (weak) id<RecordVideoDownloadDelegate> downloadDelegate;

- (BOOL)startDownloadRecordVideo:(NSString *)strSavePath handle:(LoginHandle *)deviceParam rec:(RecordVideoInfo *)recFile;

-(BOOL)stopDownLoadVideo;
-(void)deleteTempVideoInSandBox;
@end

NS_ASSUME_NONNULL_END
