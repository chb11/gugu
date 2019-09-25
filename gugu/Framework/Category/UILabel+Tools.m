//
//  UILabel+Tools.m
//  TimeMemory
//
//  Created by Glenn on 2017/12/21.
//  Copyright © 2017年 douyinbao. All rights reserved.
//

#import "UILabel+Tools.h"

@implementation UILabel (Tools)
//计算文字宽度
+ (CGFloat)calculateRowWidth:(NSString *)string andFontSize:(NSInteger)size{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};  //指定字号
    CGRect rect = [string boundingRectWithSize:CGSizeMake(0, 30)/*计算宽度时要确定高度*/ options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.width;
}
@end
