//
//  PhotoAlbumView.h
//  PPLiaoMei
//
//  Created by 岩 陈 on 2018/4/25.
//  Copyright © 2018年 岩 陈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAlbumView : UIView
@property (assign, nonatomic) BOOL isDazzing;
@property (strong, nonatomic) NSString * imgType;
@property (nonatomic, assign) NSInteger limitCount;
@property (nonatomic, copy)  DisMissCallBack resetFraCallBack;
@property (nonatomic, strong) UIImage *addIcon;
@property (nonatomic, assign) BOOL haveImage;
- (id)initBaseArray:(NSArray *)array WeakCtrl:(BaseViewController *)weakCtrl CompleteBlock:(AppendClickedBlock)clicked;
-(void)setUpDataArray:(NSArray *)array;
-(void)getAllImage;
-(void)resetFrame;

//添加选中图片
-(void)appendVideFinish:(AppendVideoBlock)finish;
-(void)setImageArray:(NSArray *)imgArray andAssetArray:(NSArray *)array;

-(void)removeObjWithIndex:(NSInteger)index;

@end
