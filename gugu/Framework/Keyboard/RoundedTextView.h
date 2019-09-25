//
//  RoundedTextView.h
//  七彩重师
//
//  Created by imac on 14-11-14.
//  Copyright (c) 2014年 xuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZYKeyboardUtil;
@interface RoundedTextView : UITextView<UITextViewDelegate>
///为了把检测之后的结果显示到view上 需要传入self && 为了弹起视图，需要传入一个Controller
@property (strong, nonatomic) UIViewController *mview;
@property(nonatomic, retain) UILabel *placeHolderLabel;
@property(nonatomic, retain) NSString *placeholder;
@property(nonatomic, retain) UIColor *placeholderColor;
-(void)setBorderColor:(UIColor*)color;
///第三方键盘弹出弹起视图
@property (strong, nonatomic) ZYKeyboardUtil *keyboardUtil;
///限制label
@property (nonatomic,strong) UILabel * countNumLabel;
///限制输入字数
@property (nonatomic,assign) long limitNum;
///打开字数限制
@property BOOL isShowXZ;
///block回调处理
@property (nonatomic, copy) void(^blockXZ)(int);

@end
