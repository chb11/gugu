//
//  EncryptUtl.m
//  GoogleAdTest
//
//  Created by Mike Chen on 2019/3/19.
//  Copyright © 2019年 Mike Chen. All rights reserved.
//

#import "EncryptUtl.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

@implementation EncryptUtl

#pragma mark- 产生密钥
+(NSString *)makeKey{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
    
    
    NSDate *date = [NSDate date];
    
    
    NSString *firstDate = [dateFormatter stringFromDate:date];

    
    return firstDate;
}
#pragma mark- 加密算法
const Byte iv[] = {1,2,3,4,5,6,7,8};
+(NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key
{
    NSString *ciphertext = nil;
    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    //    unsigned char buffer[1024];
    size_t bufferSize = dataLength + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    
    
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [textData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    NSLog(@"cryptStatus=%d",cryptStatus);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        ciphertext = [GTMBase64 stringByEncodingData:data];
    }
    return ciphertext;
}
+(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key
{
    NSString *plaintext = nil;
    NSData *cipherdata = [GTMBase64 decodeString:cipherText];
    //    unsigned char buffer[102400];
    NSUInteger dataLength = [cipherdata length];
    size_t bufferSize = dataLength + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [cipherdata bytes], [cipherdata length],
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if(cryptStatus == kCCSuccess) {
        NSData *plaindata = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plaintext = [[NSString alloc]initWithData:plaindata encoding:NSUTF8StringEncoding];
    }
    return plaintext;
}



@end
