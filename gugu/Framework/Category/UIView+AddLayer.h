//
//  UIView+AddLayer.h
//  HappyChat
//
//  Created by douyinbao on 15/12/17.
//  Copyright © 2015年 douyinbao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AddLayer)
-(void)addlayerRadius:(CGFloat)radius;

-(void)addborderColor:(UIColor *)color borderWith:(CGFloat) width layerRadius:(CGFloat)radius;

-(void)addBottomRadii:(CGFloat)radii;

-(void)addCornerRadius:(CGFloat)radius cithCorners:(UIRectCorner)corners;

@end
