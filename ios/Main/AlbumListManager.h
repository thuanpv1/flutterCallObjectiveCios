//
//  AlbumListManager.h
//  iCamSee
//
//  Created by Yang on 2019/6/18.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define KAlbumHomeDire NSHomeDirectory()
#define KAlbumRootPath [@"Documents" stringByAppendingPathComponent: @"Album_Root"]
#define KAlbumRootPathInHome [[KAlbumHomeDire stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent:@"Album_Root"]
#define KAlbumPlistFilePath [KAlbumRootPathInHome stringByAppendingPathComponent:@"Photo_Album_List.plist"]

#define KAlbumPhotoPath [KAlbumRootPath stringByAppendingPathComponent:@"Photo_Album_List_Photo_Dir"]
#define KAlbumVideoPath [KAlbumRootPath stringByAppendingPathComponent:@"Photo_Album_List_Video_Dir"]
#define KAlbumVideoFacePath [KAlbumRootPath stringByAppendingPathComponent:@"Photo_Album_List_Video_Face_Dir"]

#define KAlbumPhotoPathInHome [[[KAlbumHomeDire stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent: @"Album_Root"] stringByAppendingPathComponent:@"Photo_Album_List_Photo_Dir"]
#define KAlbumVideoPathInHome [[[KAlbumHomeDire stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent: @"Album_Root"] stringByAppendingPathComponent:@"Photo_Album_List_Video_Dir"]
#define KAlbumVideoFacePathInHome [[[KAlbumHomeDire stringByAppendingPathComponent: @"Documents"] stringByAppendingPathComponent: @"Album_Root"] stringByAppendingPathComponent:@"Photo_Album_List_Video_Face_Dir"]

#define RECORD_MP4_TYPE_RECORD 0
#define RECORD_MP4_TYPE_DOWNLOAD_TF_CARD 1
#define RECORD_MP4_TYPE_DOWNLOAD_CLOUD 2

@interface AlbumListManager : NSObject

/* Create a sandbox folder for saving pictures and videos, and migrate the index in the previous plist file to the database */
+ (void)load;

/*Get, save the ID of the image and video save*/
+(NSInteger)getImageSaveID;
+(NSInteger)getVideoSaveID;
+(void)saveImageSaveID:(NSInteger)index;
+(void)saveVideoSaveID:(NSInteger)index;

/* Get real-time video thumbnail name */
+(NSString *)genRecordFaceImageName;

/* Get the name of the screenshot image */
+ (NSString *)genScreenShotImageName;

/* Get the video duration from the video path (00:00 format string) */
+(NSString *_Nonnull)getDurationStringOfMp4File:(NSString *_Nonnull)strFilePath;

/* Get the prefix of the video name by the video type (TF card, cloud storage, real-time recording) */
+(NSString *_Nonnull)genRecordVideoNameAsType:(int) nType;

/* Get video duration from video path */
+ (double)getVideoDurationOfMp4File: (NSString *_Nonnull)strMp4FilePath;

/* Get video details by video path */
+(NSDictionary*)getVideo:(NSString *)path;

/* save Picture */
+(void)saveImage:(NSString*)imageName imageData:(NSData*)imageData;

/* save the video */
+(void)saveVideo:(NSString*)videoPath duration:(NSString*)duration imagePath:(NSString*)imagePath;

+(void)saveVideo:(NSString*)videoPath duration:(NSString*)duration imagePath:(NSString*)imagePath date:(NSDate*)date;

/* Read the photo index from the new database */
+ (NSArray * _Nullable)getPhotoAlbumImageListArr;

/* Read video index from new database */
+ (NSArray * _Nullable)getPhotoAlbumVideoListArr;

/* Read image index from old plist file */
+ (NSArray *)getPhotoListFromPlist;

/* Read video index from old plist file */
+ (NSArray *)getVideoListFromPlist;

/* delete image array */
+(void)deleteImages:(NSArray*)images;

/* delete the video array */
+(void)deleteVideos:(NSArray*)videos;

/* When the data in the old plist file is transferred to the new database, delete the plist*/
+(void)deletePlist;
@end

NS_ASSUME_NONNULL_END
