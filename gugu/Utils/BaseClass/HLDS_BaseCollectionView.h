//
//  HLDS_BaseCollectionView.h
//  VoicePackage
//
//  Created by douyinbao on 2018/10/11.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLDS_BaseCollectionView : UICollectionView

//是否允许手势向下传播
@property (nonatomic,assign) BOOL shouldRecognize;

@property (nonatomic,assign) __block NSInteger currPage;
@property (nonatomic,strong) NSString *refreshUrl;
@property (nonatomic,strong) NSDictionary *refreshDic;

//获取的数据中需要记录的字段,上啦加载时传递该字段对应的值(不设置，则默认传递参数page)
@property (nonatomic,strong) NSString *loadMoreParaKey;

//是否显示菊花（默认 no）
@property (nonatomic,assign) BOOL isShowActivity;

@property (nonatomic, copy) void(^hlds_block_loadMore)(NSDictionary *result);
@property (nonatomic, copy) void(^hlds_block_refresh)(NSDictionary *result);

//刷新
-(void)hlds_action_refresh;
//加载更多
-(void)hlds_action_loadMore;

-(void)hlds_action_loadMoreWithHeader;

-(void)hlds_action_loadMoreWithUrl:(NSString *)url para:(NSDictionary *)para;
-(void)hlds_action_refreshWithUrl:(NSString *)url para:(NSDictionary *)para;

-(void)getParaWithKey:(NSString *)key fromDict:(NSDictionary *)dict;



@end

NS_ASSUME_NONNULL_END
