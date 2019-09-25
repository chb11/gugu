//
//  UILabel+Tools.h
//  TimeMemory
//
//  Created by Glenn on 2017/12/21.
//  Copyright © 2017年 douyinbao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Tools)
//计算文字宽度
+ (CGFloat)calculateRowWidth:(NSString *)string andFontSize:(NSInteger)size;
@end
