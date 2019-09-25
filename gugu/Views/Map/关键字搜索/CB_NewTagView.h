//
//  CB_NewTagView.h
//  VoicePackage
//
//  Created by Mike Chen on 2018/7/27.
//  Copyright © 2018年 王之共力. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CB_NewTagView : UIView

/**
 背景颜色数组
 */
@property (nonatomic,strong) NSArray *itemBackColorArray;

/**
 标题颜色数组
 */
@property (nonatomic,strong) NSArray *itemTitleColorArray;
/**
 边框颜色数组
 */
@property (nonatomic,strong) NSArray *itemBorderColorArray;

/**
 边框宽度
 */
@property (nonatomic,strong) NSArray *itemBorderWidthArray;
@property (nonatomic,assign) NSInteger currIndex;

@property (nonatomic,assign) NSInteger itemFont;

@property (nonatomic,strong) NSArray<NSString *> *types;

@property (nonatomic,assign) CGFloat itemHeight;
@property (nonatomic,assign) CGFloat itemWidth;

@property (nonatomic,assign) CGFloat itemMargin;
@property (nonatomic,assign) CGFloat itemRadio;

@property (nonatomic,assign) NSInteger limitedLine;

@property (nonatomic,copy) void(^block_select)(NSString *title);

+(CGFloat)heightWithTags:(NSArray *)array withFont:(NSInteger)fontSize withitemHeight:(CGFloat)itemHeight withWidth:(CGFloat)width;

@end
