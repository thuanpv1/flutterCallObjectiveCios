/**
 2020.04.27
 1. Add JSON and NSString conversion interface
 2. Add Date and NSString conversion interface
 3. Increase the basic document path acquisition
 
 2020.04.26
 1. Add Hex to UIColor interface
 2. Add UIAlertController simple generation interface
 
 2019.01.09 - Basic tool class
 */
#ifndef __XXocUtils_h
#define __XXocUtils_h

#define XXOC_WS             __weak typeof(self) ws = self;
#define XXOC_SS             __strong typeof(ws) ss = ws;
#define XXOC_SCREEN_WIDTH   ([[UIScreen mainScreen] bounds].size.width)     // screen width
#define XXOC_SCREEN_HEIGHT  ([[UIScreen mainScreen] bounds].size.height)    // screen height

#define XXOC_IS_KINDOF(obj,cls) (nil != obj && [obj isKindOfClass:[cls class]])
#define XXOC_IS_STRING(obj)     XXOC_IS_KINDOF(obj,NSString)
#define XXOC_IS_DICTIONARY(obj) XXOC_IS_KINDOF(obj,NSDictionary)

#define CONST_STRING(name,value) static NSString * const name = @ #value;
#endif

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XXocUtils : NSObject
#pragma mark - <UIViewCotroller>
+ (UIViewController*)viewController:(NSString*)storyboardID;

#pragma mark - <NSLayoutConstraint>
+ (void)view:(UIView*)view size:(CGSize)size;
+ (void)view:(UIView*)view margin:(CGFloat)margin fillAt:(UIView*)fillAt;
+ (void)view:(UIView*)view margin:(CGFloat)margin fillAtVC:(UIViewController*)fillAt;
+ (void)view:(UIView*)view centerAt:(UIView*)centerAt;

+ (void)view:(UIView*)view left:(CGFloat)left centerYAt:(UIView*)centerYAt;
+ (void)view:(UIView*)view right:(CGFloat)right centerYAt:(UIView*)centerYAt;
+ (void)view:(UIView*)view top:(CGFloat)top centerXAt:(UIView*)centerXAt;
+ (void)view:(UIView*)view bottom:(CGFloat)bottom centerXAt:(UIView*)centerXAt;

+ (void)view:(UIView*)view appendLeft:(CGFloat)left centerYAt:(UIView*)centerYAt;
+ (void)view:(UIView*)view appendRight:(CGFloat)left centerYAt:(UIView*)centerYAt;
+ (void)view:(UIView*)view appendTop:(CGFloat)top centerXAt:(UIView*)centerXAt;
+ (void)view:(UIView*)view appendbottom:(CGFloat)bottom centerXAt:(UIView*)centerXAt;

+ (void)view:(UIView*)view adjustFillAtScrollView:(UIScrollView*)scrollView;

#pragma mark - <UIButton>
+ (void)button:(UIButton*)button norImg:(UIImage*)norImg selImg:(UIImage*)selImg;
+ (void)button:(UIButton*)button norImg:(UIImage*)norImg disImg:(UIImage*)disImg;
+ (void)button:(UIButton*)button norImg:(UIImage*)norImg selImg:(UIImage*)selImg disImg:(UIImage*)disImg;
+ (void)button:(UIButton*)button norImg:(UIImage*)norImg selImg:(UIImage*)selImg disNorImg:(UIImage*)disNorImg disSelImg:(UIImage*)disSelImg;

+ (void)button:(UIButton*)button norTxt:(NSString*)norTxt selTxt:(NSString*)selTxt;
+ (void)button:(UIButton*)button norTxt:(NSString*)norTxt disTxt:(NSString*)disTxt;
+ (void)button:(UIButton*)button norTxt:(NSString*)norTxt selTxt:(NSString*)selTxt disTxt:(NSString*)disTxt;
+ (void)button:(UIButton*)button norTxt:(NSString*)norTxt selTxt:(NSString*)selTxt disNorTxt:(NSString*)disNorTxt disSelTxt:(NSString*)disSelTxt;

#pragma mark - <UIColor>
+ (UIColor*)autoColor:(id)obj;
+ (UIColor*)colorFromHexString:(NSString*)hexString;
+ (UIColor*)colorFromHexString:(NSString*)hexString alpha:(CGFloat)alpha;

#pragma mark - <UIAlertController>
+ (UIAlertController*)alertWithTitle:(NSString*)title
                                 msg:(NSString*)msg
                             okTitle:(nullable NSString*)okTitle
                                onOK:(nullable void (^)(UIAlertAction *action))onOK
                         cancelTitle:(nullable NSString*)cancelTitle
                            onCancel:(nullable void (^)(UIAlertAction *action))onCancel;

+ (void)alert:(UIAlertController*)alert
      okTitle:(nullable NSString*)okTitle
         onOK:(nullable void (^)(UIAlertAction *action))onOK
  cancelTitle:(nullable NSString*)cancelTitle
     onCancel:(nullable void (^)(UIAlertAction *action))onCancel;

#pragma mark - <JSON>
+ (nullable NSString*)jsonStringWithJson:(id)json pretty:(BOOL)pretty;
+ (nullable id)jsonWithJsonString:(NSString*)jsonString;

#pragma mark - <Date>
+ (void)setDefaultDateFormatter:(NSDateFormatter*)formatter;
+ (NSString*)currentDateString;
+ (NSString*)currentDateStringWithDateFormat:(NSString*)format timeZone:(NSTimeZone*)timeZone;
+ (NSString*)dateStringWithTimestamp:(NSTimeInterval)timestamp;
+ (NSString*)dateStringWithTimestamp:(NSTimeInterval)timestamp dateFormat:(NSString*)format timeZone:(NSTimeZone*)timeZone;

#pragma mark - <Time>
+ (NSString*)timeStringWithSecond:(NSTimeInterval)second timeFormat:(NSString*)format;

#pragma mark - <File System>
/** Returns the sandbox document folder path */
+ (NSString*)documentAbsolutePathString;
+ (NSURL*)documentAbsolutePathUrl;
/** Returns the path consisting of several nodes in the sandbox document */
+ (NSString*)absolutePathStringInDocument:(NSArray*)nodes;
+ (NSURL*)absolutePathUrlInDocument:(NSArray*)nodes;
/** Create a folder under a path consisting of several nodes in the sandbox document */
+ (nullable NSString*)mkdirInDocument:(NSArray*)nodes error:(NSError**)error;

#pragma mark - <TouchID/FaceID>
/**
 Display TouchID/FaceID verification using the specified reason
 @param reason alert message of the pop-up box
 @param reply verification result callback, where error.code refers to the enumeration value of LAError
 @return returns YES if the call is successful, otherwise returns NO
 */
+ (BOOL)evaluatePolicyWithReason:(NSString*)reason reply:(void(^)(BOOL success, NSError * _Nullable error))reply;

#pragma mark - <Thread>
+ (void)mainThreadProcess:(void(^)(void))handler;

#pragma mark - <Bundle>
+ (NSBundle*)bundleNamed:(NSString*)name;

#pragma mark - <Run Time>
+ (void)replaceMethod:(Class)cls src:(SEL)src dest:(SEL)dest;

#pragma mark - <Audio/Video>
+ (NSTimeInterval)audioDuration:(NSURL*)url;

#pragma mark - <Image>
+ (UIImage*)imageFromColor:(UIColor*)color size:(CGSize)size;

#pragma mark - <权限>
+ (BOOL)authorizedCamera;
+ (BOOL)authorizedMicrophone;
+ (void)anthorizedCameraCheckAtViewController:(UIViewController*)viewController message:(NSString*)message succeed:(void(^)(void))succeed;
@end

NS_ASSUME_NONNULL_END
