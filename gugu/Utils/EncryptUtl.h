//
//  EncryptUtl.h
//  GoogleAdTest
//
//  Created by Mike Chen on 2019/3/19.
//  Copyright © 2019年 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EncryptUtl : NSObject

+(NSString *)makeKey;
+(NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;
+(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
