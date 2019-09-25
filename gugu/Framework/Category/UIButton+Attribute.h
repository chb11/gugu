//
//  UIButton+Attribute.h
//  HappyChat
//
//  Created by douyinbao on 16/3/16.
//  Copyright © 2016年 douyinbao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Attribute)
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)UIColor *colorSelect;
@property(nonatomic, strong)UIColor *colorNormal;

-(void)setImageInsets;

-(void)setImageInsetsWithHeight:(CGFloat)height andOldPadding:(CGFloat)padding;
@end
