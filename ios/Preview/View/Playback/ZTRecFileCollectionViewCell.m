//
//  ZTRecFileCollectionViewCell.m
//  iCamSee
//
//  Created by hs_mac on 2018/3/8.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "ZTRecFileCollectionViewCell.h"
#import "RecordVideoInfo.h"
#import "RecordVideoDownloader.h"
@interface ZTRecFileCollectionViewCell()

// Starting time
@property(nonatomic, strong) UILabel *startTimeLbl;
// duration
@property(nonatomic, strong) UILabel *durationTimeLbl;
// download progress
@property(nonatomic, strong) UILabel *dowmloadProgressLbl;
// File size
@property(nonatomic, strong) UILabel *fileSizeLbl;
// Background picture
@property(nonatomic, strong) UIImageView *imageView;
@end

@implementation ZTRecFileCollectionViewCell



-(instancetype)initWithFrame:(CGRect)frame{
    
    if(self = [super initWithFrame:frame]){
        
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        //Background picture
        _imageView = [[UIImageView alloc]init];
        _imageView.image = [UIImage imageNamed:@"icon_autovideo"];//modify by weibin 20180914 Play back the background icon of the cell weibin 20180913
        [self addSubview:_imageView];
        //Starting time
        _startTimeLbl = [[UILabel alloc] init];
        _startTimeLbl.font = [UIFont systemFontOfSize:14.0];
        _startTimeLbl.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self addSubview:_startTimeLbl];
        //end time (or file duration)
        _durationTimeLbl = [[UILabel alloc] init];
        _durationTimeLbl.font = [UIFont systemFontOfSize:14.0];
        _durationTimeLbl.textAlignment = NSTextAlignmentRight;
        _durationTimeLbl.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [self addSubview:_durationTimeLbl];
        // download progress
        _dowmloadProgressLbl = [[UILabel alloc] init];
        _dowmloadProgressLbl.font = [UIFont systemFontOfSize:14.0];
        _dowmloadProgressLbl.textColor = [UIColor orangeColor];
        _dowmloadProgressLbl.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_dowmloadProgressLbl];
         _dowmloadProgressLbl.hidden = YES;
        //File size
        _fileSizeLbl = [[UILabel alloc] init];
        _fileSizeLbl.font = [UIFont systemFontOfSize:14.0];
        _fileSizeLbl.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _fileSizeLbl.textAlignment = NSTextAlignmentRight;
        [self addSubview:_fileSizeLbl];
        
        
        
    }
    
    return self;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    CGRect frame = self.frame;
    
    frame = _imageView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = self.frame.size.width;
    frame.size.height = self.frame.size.height;
    _imageView.frame = frame;
    
    frame = _startTimeLbl.frame;
    frame.origin.x = 2;
    frame.origin.y = 2;
    frame.size.width = self.frame.size.width * 0.6;
    frame.size.height = 20;
    _startTimeLbl.frame = frame;
    
    frame = _dowmloadProgressLbl.frame;
    frame.origin.x = 2;
    frame.origin.y = self.frame.size.height - 20 -2;
    frame.size.width = self.frame.size.width * 0.6;
    frame.size.height = 20;
    _dowmloadProgressLbl.frame = frame;
    
    frame = _durationTimeLbl.frame;
    frame.size.width = 60;
    frame.origin.x = self.frame.size.width - frame.size.width - 2;
    frame.size.height = 20;
    frame.origin.y = 2;
    _durationTimeLbl.frame = frame;
   
    
    frame = _fileSizeLbl.frame;
    frame.size.width = 80;
    frame.origin.x = self.frame.size.width - frame.size.width - 2;
    frame.size.height = 20;
    frame.origin.y = self.frame.size.height - 20 -2;
    _fileSizeLbl.frame = frame;
    
}

-(void)setFileModel:(RecordVideoInfo *)fileModel{
    
    _fileModel = fileModel;
    
    //add by weibin 20180914
    if (_fileModel.nfileType == FILE_TYPE_ALARM) {
        self.imageView.image = [UIImage imageNamed:@"icon_alarmvideo"];
        //        NSLog(@"20180914 =============== icon_alarmvideo");
    }else{
        self.imageView.image = [UIImage imageNamed:@"icon_autovideo"];
        //        NSLog(@"20180914 =============== icon_autovideo");
    }
    //add end by weibin 20180914
    
    //    NSLog(@"id=%d  startTime:%d ",fileModel.nFileID,fileModel.nStartTime);
    if(fileModel.nStartTime > 0 && fileModel.nEndTime != 0 && fileModel.nStartTime != 0){
        _fileSizeLbl.hidden = YES;
        // Convert to hours, minutes and seconds according to the timestamp
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:fileModel.nStartTime];
        //    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:fileModel.nEndTime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [dateFormatter setTimeZone:GTMzone];
        
        NSString *startTime = [dateFormatter stringFromDate:startDate];
        //    NSString *endTime = [dateFormatter stringFromDate:endDate];
        
        _startTimeLbl.text = startTime;
        _durationTimeLbl.text = [self timeFormatted:fileModel.nEndTime-fileModel.nStartTime];
    }else{
        //old
        _fileSizeLbl.hidden = NO;
        
        _fileSizeLbl.text = [NSString stringWithFormat:@"%@",[NSString stringWithBytes:fileModel.nFileSize]];
        
        NSString *strStart = nil;
        strStart = [NSString stringWithFormat:@"%02d:%02d:%02d",[fileModel nStartHour], [fileModel nStartMin], [fileModel nStartSec]];
        _startTimeLbl.text = strStart;
        
        float nFileTime = [fileModel nFileTimeLen];  //total duration
        //        nFileTime += [fileModel nStartHour] * 60 * 60 + [fileModel nStartMin] * 60 + [fileModel nStartSec];
        _durationTimeLbl.text = [self timeFormatted:nFileTime];
        
    }
    
    if(fileModel.nDownloadStatus == DOWNLOAD_PROC_CONNECTING ){
        // connecting
        _dowmloadProgressLbl.hidden = NO;
        _dowmloadProgressLbl.text = NSLocalizedString(@"connecting", nil);
        
    } else if(fileModel.nDownloadStatus == DOWNLOAD_PROC_FINISH){
        // Download completed
        _dowmloadProgressLbl.hidden = NO;
        _dowmloadProgressLbl.text = @"Downloaded";
    }else if(fileModel.nDownloadStatus == DOWNLOAD_PROC_DOWNLOADING){
        // downloading
        _dowmloadProgressLbl.hidden = NO;
        _dowmloadProgressLbl.text = [NSString stringWithFormat:@"%.f%%",fileModel.nDownloadProcess * 100];
    }else{
        // other
        _dowmloadProgressLbl.hidden = YES;
        
    }
    
}



- (NSString *)timeFormatted:(int)totalSeconds{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours>0) {
        return [NSString stringWithFormat:@"%02d'%02d'%02d''",hours, minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02d'%02d''", minutes, seconds];

}

@end
