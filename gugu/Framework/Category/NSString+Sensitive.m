//
//  NSString+Sensitive.m
//  HappyChat
//
//  Created by douyinbao on 16/3/14.
//  Copyright © 2016年 douyinbao. All rights reserved.
//

#import "NSString+Sensitive.h"

@implementation NSString (Sensitive)

-(NSString *)clearAndLower
{
    NSString * text = [self lowercaseString];
    text =  [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    text =  [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return text;
}
//包含制定关键字不允许发送的
-(NSString *)canntSendSensitiveAndWords:(NSArray *)array
{
    NSString * text = [self clearAndLower];
    for (NSString * obj in array) {
        if (obj.length) {
            if ([text rangeOfString:obj].location!=NSNotFound) {
                return obj;
            }
        }
    }
    return @"";
}


//包含制定关键字允许发送的
-(NSString *)canSendSensitiveWordsAndWords:(NSArray *)array
{
    NSString * text = [self clearAndLower];
    for (NSString * obj in array) {
        if (obj.length) {
            if ([text rangeOfString:obj].location!=NSNotFound) {
                return obj;
            }
        }
    }
    return @"";
}

-(BOOL)isViolation{
   NSString * rule =  @"[\\s\\S]*?[a-zA-Z0123456789一二三四五六七八九零壹贰叁肆伍陆柒捌玖\\s]{6,}[\\s\\S]*?";
    NSPredicate *iphonePredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule];
    return [iphonePredicate evaluateWithObject:self];

}

//包含制定正则 不允许发送的
-(NSString *)isCaontainsSregularAndWords:(NSArray *)array
{
    BOOL isCantain = NO;
    NSString * text = [self clearAndLower];
    for (NSString * obj in array) {
        if (obj.length) {
            @try {
                NSPredicate *iphonePredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",obj];
                isCantain = isCantain||[iphonePredicate evaluateWithObject:text];
                if (isCantain) {
                    return obj;
                }
            } @catch (NSException *exception) {
                NSLog(@"失败 = %@ andarray = %@",obj,array);
                NSLog(@"classtype = %@", [obj class]);
                NSLog(@"NSException_name =%@",exception.name);
                NSLog(@"NSException_reasion =%@",exception.reason);
                NSLog(@"NSException_info =%@",exception.userInfo);
            } @finally {
                
            }
        }
    }
    return @"";
    
}

-(NSString *)stringClearWhiteAndEnter
{
    NSString * str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([str hasPrefix:@"\n"]||[str hasPrefix:@"\r"]) {
        str = [str substringToIndex:str.length-1];
    }
    
    if ([str hasSuffix:@"\n"]||[str hasSuffix:@"\r"]) {
        str = [str substringFromIndex:0];
    }
    
    
    return str;

}

-(NSString*)clearSensitiveWords
{
    __block NSString * content = self==nil?@"":self;
    NSArray * array = [[[NSUserDefaults standardUserDefaults] objectForKey:SENSITIVE_WORDS_CONTENT] objectForKey:@"items"];
    if (array) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            content = [content stringByReplacingOccurrencesOfString:obj withString:@"**"];
        }];
    }
    return content;
}

@end
