

/**
 
String handling
 
 */

#import "NSString+Formatter.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Formatter)


// Convert to MD5 string
- (NSString *)md5String {
    
    //To perform UTF8 transcoding
    const char* input = [self UTF8String];
    
    //NSAssert(input != NULL, @"NSString (Formatter) ==> md5String function encountered NULL pointer!");
    if(input == NULL) return nil;
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
    
}

// remove all spaces from the string
- (NSString *)noneSpaceString {
    
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}


// encode base64 string
- (NSString *)base64Encode {

    if (self.length == 0) {

        return @"";
    }

    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

// decode base64 string
- (NSString *)base64Decode {

    if (self.length == 0) {

        return @"";
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

//urlEncode encoding
-(NSString *)urlEncodeStr {
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *upSign = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return upSign;
}
//urlEncode decoding
-(NSString *)decoderUrlEncodeStr {
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,[outputStr length])];
    return [outputStr stringByRemovingPercentEncoding];
}

// convert bytes to string
+ (instancetype)stringWithBytes:(int)bytes {
    
    static const int kBytesPerKB = 1024;
    static const int kBytesPerMB = 1048576;
    
    int MB = bytes / kBytesPerMB;
    int KB = bytes % kBytesPerMB / kBytesPerKB;
    
    NSString *string;
    
    if (MB > 0) {
        
        string = [NSString stringWithFormat:@"%d M", MB];
        
    } else if (KB > 0) {
        
        string = [NSString stringWithFormat:@"%d K", KB];
        
    } else {
        
        string = @"1 K";
    }
    
    return string;
}

//Get the height of the string in the specified Size (automatic wrapping)
-(CGFloat) stringHeightWithFont:(UIFont *)font containSize:(CGSize)size{
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:self attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:style}];
    
    CGSize lableSize =  [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;

    CGFloat height = ceil(lableSize.height) + 1;

    return height;
}

//Get the width of the string in the specified Size (automatic wrapping)
-(CGFloat) stringWidthWithFont:(UIFont *)font containSize:(CGSize)size{
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:self attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:style}];
    
    CGSize lableSize =  [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    CGFloat width = ceil(lableSize.width) + 1;
    
    return width;
}
@end
