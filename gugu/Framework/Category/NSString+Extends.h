//
//  NSString+Extends.h
//  MixDemo
//
//  Created by douyinbao on 2018/5/14.
//  Copyright © 2018年 William. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Extends)
//算出宽度
-(CGFloat)textWidthTitleFont:(UIFont *)font;
//算出高度
-(CGFloat )sizeHeightWithFont:(UIFont *)font width:(CGFloat)width;

//文本行数
-(NSInteger)numLineCount;
@end
