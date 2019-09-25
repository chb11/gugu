//
//  NSString+Extends.m
//  MixDemo
//
//  Created by douyinbao on 2018/5/14.
//  Copyright © 2018年 William. All rights reserved.
//

#import "NSString+Extends.h"

@implementation NSString (Extends)

-(CGFloat)textWidthTitleFont:(UIFont *)font
{
    CGSize titleSize = [self sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
    return titleSize.width;
}

//算出高度
-(CGFloat )sizeHeightWithFont:(UIFont * )font width:(CGFloat)width{
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    CGSize   size = rect.size;
    CGFloat heigt=size.height;
    return heigt;
}

-(NSInteger)numLineCount
{
    NSArray * array = [self componentsSeparatedByString:@"\n"];
    return array.count;
}


@end
