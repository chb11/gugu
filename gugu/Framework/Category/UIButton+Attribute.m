//
//  UIButton+Attribute.m
//  HappyChat
//
//  Created by douyinbao on 16/3/16.
//  Copyright © 2016年 douyinbao. All rights reserved.
//

#import "UIButton+Attribute.h"

@implementation UIButton (Attribute)
-(NSString *)title
{
    return self.titleLabel.text;
}

-(void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

-(UIColor *)colorSelect
{
    return [self titleColorForState:UIControlStateSelected];
}

-(void)setColorSelect:(UIColor *)colorSelect
{
    return [self setTitleColor:colorSelect forState:UIControlStateSelected];
}

-(UIColor *)colorNormal
{
    return [self titleColorForState:UIControlStateNormal];
}


-(void)setColorNormal:(UIColor *)colorNormal
{
    return [self setTitleColor:colorNormal forState:UIControlStateNormal];
}

-(void)setImageInsets
{
    CGFloat bilu =  SCREEN_WIDTH>330?2:2.3;
    UIImage * imageHouse = [self imageForState:UIControlStateNormal];
    CGFloat leftPadding = fabs((CGRectGetWidth(self.frame)-imageHouse.size.width/bilu)/2.0);
    CGFloat topPadding =  fabs((CGRectGetHeight(self.frame)-imageHouse.size.height/bilu)/2.0);
    self.imageEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding, topPadding, leftPadding);
}


-(void)setImageInsetsWithHeight:(CGFloat)height andOldPadding:(CGFloat)padding
{
    CGFloat bilu = SCREEN_WIDTH>330?2:2.3;
    UIImage * imageHouse = [self imageForState:UIControlStateNormal];
    CGFloat leftPadding = fabs((CGRectGetWidth(self.frame)-imageHouse.size.width/bilu)/2.0);
    CGFloat topPadding =  fabs((height-imageHouse.size.height/bilu)/2.0);
    self.imageEdgeInsets = UIEdgeInsetsMake(topPadding, leftPadding, topPadding+padding, leftPadding);
}

@end
