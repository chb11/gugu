//
//  NSString+Sensitive.h
//  HappyChat
//
//  Created by douyinbao on 16/3/14.
//  Copyright © 2016年 douyinbao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Sensitive)
//包含制定关键字不允许发送的
-(NSString *)canntSendSensitiveAndWords:(NSArray *)array;
//包含制定关键字允许发送的
-(NSString*)canSendSensitiveWordsAndWords:(NSArray *)array;
//包含制定正则 不允许发送的
-(NSString*)isCaontainsSregularAndWords:(NSArray *)array;

//清除空白符 和首尾的回车
-(NSString *)stringClearWhiteAndEnter;

-(BOOL)isViolation;

-(NSString*)clearSensitiveWords;


@end
