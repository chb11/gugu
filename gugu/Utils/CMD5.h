//
//  CMD5.h
//  HappyChat
//
//  Created by douyinbao on 15/12/7.
//  Copyright © 2015年 douyinbao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMD5 : NSObject
//把字符串加密成32位小写md5字符串
+ (NSString*)md532BitLower:(NSString *)inPutText;

//把字符串加密成32位大写md5字符串
+ (NSString*)md532BitUpper:(NSString*)inPutText;

@end
