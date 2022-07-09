//
//  AlbumListManager.m
//  iCamSee
//
//  Created by Yang on 2019/6/18.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import "AlbumListManager.h"
#import <AVFoundation/AVFoundation.h>

@interface AlbumListManager()
@end
@implementation AlbumListManager
+ (void)load{
    @synchronized (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];

        if (![fileManager fileExistsAtPath:KAlbumVideoPathInHome]) {
           [fileManager createDirectoryAtPath:KAlbumVideoPathInHome withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileManager fileExistsAtPath:KAlbumVideoFacePathInHome]) {
            [fileManager createDirectoryAtPath:KAlbumVideoFacePathInHome withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileManager fileExistsAtPath:KAlbumPhotoPathInHome]) {
            [fileManager createDirectoryAtPath:KAlbumPhotoPathInHome withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

+(void)saveImage:(NSString*)imageName imageData:(NSData*)imageData{
    NSMutableDictionary *imgDict = [NSMutableDictionary dictionary];
  
}

+(void)saveVideo:(NSString*)videoPath duration:(NSString*)duration imagePath:(NSString*)imagePath{
    NSMutableDictionary *videoDict = [NSMutableDictionary dictionary];
   
}

+(void)saveVideo:(NSString*)videoPath duration:(NSString*)duration imagePath:(NSString*)imagePath date:(NSDate*)date{
   
}

+ (NSArray * _Nullable)getPhotoAlbumImageListArr{
    
   

    return nil;
}

+ (NSArray * _Nullable)getPhotoAlbumVideoListArr{
    
   
    
    return nil;
}

+ (NSDictionary *)getVideo:(NSString *)path{
    return nil;
}
//Sort by time
NSComparisonResult compare(NSDictionary *firstDict, NSDictionary *secondDict, void *context) {
    
    if ([[firstDict objectForKey:@"timestamp"] intValue] < [[secondDict objectForKey:@"timestamp"] intValue])
        
        return NSOrderedDescending;
    
    else if ([[firstDict objectForKey:@"timestamp"] intValue] > [[secondDict objectForKey:@"timestamp"] intValue])
        
        return NSOrderedAscending;
    
    else
        
        return NSOrderedSame;
    
}


+(void)deleteImages:(NSArray*)images{
    // delete the actual file
    NSMutableArray *imagePathArr = [NSMutableArray array];
   
}

+(void)deleteVideos:(NSArray*)videos{
    NSMutableArray *videoPathArr = [NSMutableArray array];
    NSMutableArray *faceImagePathArr = [NSMutableArray array];

}

+ (NSArray *)getPhotoListFromPlist{
    @synchronized (self) {
        NSDictionary *dicAlbumIndexFile = [NSDictionary dictionaryWithContentsOfFile:KAlbumPlistFilePath] ;
        NSArray * arrPhotoList = nil;
        if(dicAlbumIndexFile){
            arrPhotoList =dicAlbumIndexFile[@"image"];
        }
        return arrPhotoList;
    }
}
+ (NSArray *)getVideoListFromPlist{
    @synchronized (self) {
        NSDictionary *photo_album_list = [NSDictionary dictionaryWithContentsOfFile:KAlbumPlistFilePath];
        NSArray *photo_album_video_list = photo_album_list[@"video"];
        return [photo_album_video_list copy];
    }
}


+ (void)removefilsFromSandbox:(NSArray <NSString *> *)pathArr{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < pathArr.count; i++) {
            @autoreleasepool {
                NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:pathArr[i]];
                [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
            }
        }
    });
}

+ (NSString *)genRecordFaceImageName{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSDate *current_date = [NSDate date];
    NSString *current_date_string = [formatter stringFromDate:current_date];
    NSMutableString *strImageFaceName = [NSMutableString string];
    [strImageFaceName appendString:@"face_"];
    [strImageFaceName appendString:current_date_string];
    [strImageFaceName appendString:@".jpg"];
    return [strImageFaceName copy];
}

+ (NSString *)genScreenShotImageName{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSDate *current_date = [NSDate date];
    NSString *current_date_string = [formatter stringFromDate:current_date];
    NSMutableString *screen_shot_image_name = [NSMutableString string];
    [screen_shot_image_name appendString:@"img_"];
    [screen_shot_image_name appendString:current_date_string];
    [screen_shot_image_name appendString:@".jpg"];
    return [screen_shot_image_name copy];
}

+ (NSString *)getDateString{
    @synchronized (self) {
        NSDate *date = [NSDate date];
        NSDateFormatter *date_format = [[NSDateFormatter alloc]init];
        date_format.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        date_format.dateFormat = @"yyyy-MM-dd";
        date_format.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        return [[date_format stringFromDate:date] copy];
    }
}

+ (NSString*)getDateStringWithDate:(NSDate*)date{
    @synchronized (self) {
        NSDateFormatter *date_format = [[NSDateFormatter alloc]init];
        date_format.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        date_format.dateFormat = @"yyyy-MM-dd";
        date_format.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        return [[date_format stringFromDate:date] copy];
    }
}

+ (NSString *)getTimeString{
    @synchronized (self) {
        NSDate *date = [NSDate date];
        NSDateFormatter *date_format = [[NSDateFormatter alloc]init];
        date_format.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        date_format.dateFormat = @"HH:mm:ss";
        return [[date_format stringFromDate:date] copy];
    }
}

+ (NSString *)getTimeStringWithDate:(NSDate*)date{
    @synchronized (self) {
        NSDateFormatter *date_format = [[NSDateFormatter alloc]init];
        date_format.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        date_format.dateFormat = @"HH:mm:ss";
        return [[date_format stringFromDate:date] copy];
    }
}

+ (NSString *_Nonnull)getDurationStringOfMp4File:(NSString *_Nonnull)strFilePath{

    double duration = [AlbumListManager getVideoDurationOfMp4File:strFilePath];
    
    NSString *durationString = [AlbumListManager timeStringFromInt:duration];
    return [durationString copy];
}

+ (double)getVideoDurationOfMp4File: (NSString *_Nonnull)strMp4FilePath{
    NSURL *url = [NSURL fileURLWithPath:strMp4FilePath];
    AVAsset *asset = [AVURLAsset assetWithURL:url];
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (nil == track) {
        return 0;
    }
    return track.timeRange.duration.value/track.timeRange.duration.timescale;
}

+ (NSString *)timeStringFromInt: (uint32_t)duration{
    if (duration > 60*60*60) {
        int h = 0, m = 0, s = 0;
        h = duration / 60 / 60;
        m = (duration - h*60*60) / 60;
        s = duration - h*60*60 - m*60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    } else {
        int m = 0, s = 0;
        m = duration / 60;
        s = duration - m*60;
        return [NSString stringWithFormat:@"%02d:%02d", m, s];
    }
    return nil;
}

+(NSNumber*)getTimeStamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",[AlbumListManager getDateString],[AlbumListManager getTimeString]]];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return @(timeSp);
}

+(NSNumber*)getTimeStampWithDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setTimeZone:timeZone];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return @(timeSp);
}

+ (NSString *_Nonnull)genRecordVideoNameAsType:(int) nType{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *strDate = [formatter stringFromDate: [NSDate date]];
    NSMutableString *strVideoName = [NSMutableString string];
    switch (nType) {
        case RECORD_MP4_TYPE_RECORD:
            [strVideoName appendString:@"video_"];
            break;
        case RECORD_MP4_TYPE_DOWNLOAD_TF_CARD:
            [strVideoName appendString:@"rec_"];
            break;
        default:
            [strVideoName appendString:@"cloud_"];
            break;
    }
    
    [strVideoName appendString:strDate];
    [strVideoName appendString:@".mp4"];
    return [strVideoName copy];
}

+(NSInteger)getImageSaveID{
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSInteger index = [userdefaults integerForKey:@"ALBUMIMAGESAVEINDEX"];
//    if (index == 0) {
//        index = 1;
//    }
    return index;
}
+(NSInteger)getVideoSaveID{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSInteger index = [userdefaults integerForKey:@"ALBUMVIDEOSAVEINDEX"];
//    if (index == 0) {
//        index = 1;
//    }
    return index;
}

+(void)saveImageSaveID:(NSInteger)index{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setInteger:index forKey:@"ALBUMIMAGESAVEINDEX"];
    [userdefaults synchronize];
}

+(void)saveVideoSaveID:(NSInteger)index{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setInteger:index forKey:@"ALBUMVIDEOSAVEINDEX"];
    [userdefaults synchronize];
}


+(NSNumber*)timeStamp:(NSString*)time specificTime:(NSString*)specificTime{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@",time,specificTime]];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return @(timeSp);
}

+(void)deletePlist{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    
    NSString *path = KAlbumPlistFilePath;
    if ([fileManage fileExistsAtPath:path]) {
        BOOL isSuccess = [fileManage removeItemAtPath:path error:nil];
    }else{
    }
}


@end
