//
//  NSData+AES128.h
//  HappyChat
//
//  Created by douyinbao on 15/12/28.
//  Copyright © 2015年 douyinbao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES128)
-(NSData *)AES128EncryptWithKey:(NSString *)key;
-(NSData *)AES128DecryptWithKey:(NSString *)key ;
@end
