//
//  UIView+AddLayer.m
//  HappyChat
//
//  Created by douyinbao on 15/12/17.
//  Copyright © 2015年 douyinbao. All rights reserved.
//

#import "UIView+AddLayer.h"

@implementation UIView (AddLayer)
-(void)addlayerRadius:(CGFloat)radius
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = radius;
}

-(void)addborderColor:(UIColor *)color borderWith:(CGFloat) width layerRadius:(CGFloat)radius;
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    [self addlayerRadius:radius];
    
}


-(void)addBottomRadii:(CGFloat)radii
{
    UIBezierPath* maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(radii, radii)];
    
    // 创建形状图层,设置它的路径
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    // 新创建的形状图层设置为图像视图层的面具
    self.layer.mask = maskLayer;
    [self.layer setMasksToBounds:YES];
}

-(void)addCornerRadius:(CGFloat)radius cithCorners:(UIRectCorner)corners{
    UIBezierPath* maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                     byRoundingCorners:corners
                                           cornerRadii:CGSizeMake(radius, radius)];
    
    // 创建形状图层,设置它的路径
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    // 新创建的形状图层设置为图像视图层的面具
    self.layer.mask = maskLayer;
//    [self.layer setMasksToBounds:YES];
    
    
}

@end
