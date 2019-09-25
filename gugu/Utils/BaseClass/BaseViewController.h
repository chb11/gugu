//
//  BaseViewController.h
//  MakeProfilePicture
//
//  Created by douyinbao on 2018/3/28.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, strong) UIImageView *bgView;

//设置左右按钮
- (void)addItemWithTitle:(NSString *)itemTitle imageName:(NSString *)imageName selector:(SEL)selector left:(BOOL)isLeft;

- (void)addImageItemWithTitle:(NSString *)itemTitle imageName:(NSString *)imageName selector:(SEL)selector left:(BOOL)isLeft;

@end
