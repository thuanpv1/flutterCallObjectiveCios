/**
 
 String handling
 
 */

#import <Foundation/Foundation.h>

@interface NSString (Formatter)

/** Convert to MD5 string */
- (NSString *)md5String;

/** encode base64 string */
- (NSString *)base64Encode;

/** decode base64 string */
- (NSString *)base64Decode;

//urlEncode encoding
-(NSString *)urlEncodeStr;

//urlEncode decoding
-(NSString *)decoderUrlEncodeStr;

/** Convert bytes to string */
+ (instancetype)stringWithBytes:(int)bytes;
/** Get the height of the text, default wordlinebreak*/
-(CGFloat) stringHeightWithFont:(UIFont *)font containSize:(CGSize)size;
/**Get the width of the string in the specified Size (automatic wrapping)*/
-(CGFloat) stringWidthWithFont:(UIFont *)font containSize:(CGSize)size;

@end