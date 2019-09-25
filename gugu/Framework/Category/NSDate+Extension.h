//
//  NSDate+Extension.h
//  TraficPaiker
//
//  Created by Glenn on 2017/5/10.
//  Copyright © 2017年 zhejiangchelianwangluo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)


/**
 避免负数

 @return 不懂
 */
+ (NSCalendar *) currentCalendar;

/**
 设置时间

 @param datestr 时间参数
 @param format 时间格式
 @return date值
 */
+ (NSDate *)date:(NSString *)datestr WithFormat:(NSString *)format;


@property (readonly) NSInteger year;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;

@end
