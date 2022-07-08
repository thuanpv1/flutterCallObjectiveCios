//
//  AES128Util.h
//  ASE128Demo
//
//  Created by zhenghaishu on 11/11/13.
//  Copyright (c) 2013 Youku.com inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"
@interface AES128Util : NSObject

+(NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)key;

+(NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)key;

+(NSData *)AES128EncryptFromData:(NSData *)data key:(NSString *)key;

+(NSData *)AES128DecryptFromData:(NSData *)data key:(NSString *)key;

+(NSData *)AES128EncryptFromDataNopadding:(NSData *)data key:(NSString *)key;

+ (NSData*)decryptAES128:(unsigned char*)encryptText length:(int)length key:(NSString*)key iv:(NSString*)iv;

// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;
// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;
//3des解密
+ (NSString*)TripleDES:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString*)key;

//加密
+ (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv data:(NSData*)data;
//解密
+ (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv data:(NSData*)data;
@end
