//
//  HLDS_BaseListView.m
//  TimeMemory
//
//  Created by Mike on 2018/1/4.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import "HLDS_BaseListView.h"

@interface HLDS_BaseListView()

@end

@implementation HLDS_BaseListView

-(NSString *)refreshUrl{
    if (!_refreshUrl) {
        _refreshUrl = @"";
    }
    return _refreshUrl;
}

-(NSDictionary *)refreshDic{
    if (!_refreshDic) {
        _refreshDic = @{};
    }
    return _refreshDic;
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self  = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.estimatedRowHeight = 0;
        self.currPage = 0;
        self.isShowActivity = NO;
        self.animationTime = 1;
        
#ifdef __IPHONE_11_0
        if ([self respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
        self.shouldRecognize = YES;
        
        __weak typeof(self) weakSelf = self;
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            if (self.isShowActivity) {
                [HYActivityIndicator startActivityAnimation:[UIApplication sharedApplication].keyWindow];
            }
            
            [weakSelf hlds_action_refreshWithUrl:weakSelf.refreshUrl para:self.refreshDic];

//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakSelf.mj_header endRefreshing];
//
//            });
        }];
        
        self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            
            if (self.isShowActivity) {
                [HYActivityIndicator startActivityAnimation:[UIApplication sharedApplication].keyWindow];
            }
            
            
            
            [weakSelf hlds_action_loadMoreWithUrl:weakSelf.refreshUrl para:self.refreshDic];
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//                [weakSelf.mj_footer endRefreshing];
//            });
        }];
        self.mj_footer.automaticallyHidden = YES;
    }
    return self;
}

-(void)hlds_action_refreshWithUrl:(NSString *)url para:(NSDictionary *)para{
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mj_header endRefreshing];
        
    });
    
    self.currPage = 0;
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *m_dict = self.refreshDic.mutableCopy;
    NSString *keyStr= [NSString stringWithFormat:@"last_%@",self.loadMoreParaKey];
    if ([m_dict.allKeys containsObject:keyStr]) {
        [m_dict removeObjectForKey:keyStr];
         para = m_dict.copy;
    }
    
//    [HYActivityIndicator startActivityAnimation:self.window];
    [[NetWorkConnect manager] postDataWith:para withUrl:url withResult:^(NSInteger resultCode,id responseObject, NSError *error) {
       
        NSDictionary * resultDic = responseObject;
        if (resultCode==1) {
            
            [HYActivityIndicator stopActivityAnimation];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                [weakSelf getParaWithKey:weakSelf.loadMoreParaKey fromDict:resultDic];
                
            });
            if (self.hlds_block_refresh) {
                self.hlds_block_refresh(resultDic);
            }
        }else{
            if (self.hlds_block_refresh) {
                self.hlds_block_refresh(@{});
            }
        }
        [weakSelf.mj_header endRefreshing];
        [weakSelf.mj_footer endRefreshing];
    }];
}

-(void)hlds_action_loadMoreWithUrl:(NSString *)url para:(NSDictionary *)para{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mj_footer endRefreshing];
        [self.mj_header endRefreshing];
    });
    
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *m_dict = para.mutableCopy;
    
    if (self.loadMoreParaKey) {
        NSString *keyStr= [NSString stringWithFormat:@"last_%@",self.loadMoreParaKey];
        NSString *valueStr = [AppGeneral getSafeValueWith:m_dict[keyStr]];
        [m_dict setValue:valueStr forKey:keyStr];
    }else{

        if (self.isNormalPage) {
            [m_dict setValue:@(self.currPage +1) forKey:@"page"];
        }else{
            [m_dict setValue:@((self.currPage +1)*10) forKey:@"from"];
            [m_dict setValue:@((self.currPage +1)*10+9) forKey:@"to"];
        }
    }
    
    [[NetWorkConnect manager] postDataWith:m_dict.copy withUrl:url withResult:^(NSInteger resultCode,id responseObject, NSError *error) {
        
        [HYActivityIndicator stopActivityAnimation];
        
        NSDictionary * resultDic = responseObject;
        if (resultCode==1) {
            
            NSArray *items = resultDic[@"list"];
            
            //下一页数据为空，currPage 不变
            if (!(items.count>0)) {
                
            }else{
                self.currPage +=1;
                //下一页数据数据不为空，择
                [weakSelf getParaWithKey:weakSelf.loadMoreParaKey fromDict:resultDic];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.hlds_block_loadMore) {
                    weakSelf.hlds_block_loadMore(resultDic);
                }
            });
            
        }else{
            
        }
        [weakSelf.mj_header endRefreshing];
        
        if ([resultDic.allKeys containsObject:@"list"]) {
            NSArray *items = resultDic[@"list"];
            if (items.count==0) {
                [weakSelf.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
        }
        [weakSelf.mj_footer endRefreshing];
    }];
}

-(void)hlds_action_refresh{
    [self.mj_header beginRefreshing];
}

-(void)hlds_action_loadMore{
    
    [self.mj_footer beginRefreshing];
}

-(void)hlds_action_loadMoreWithHeader{
    
    [self hlds_action_loadMoreWithUrl:self.refreshUrl para:self.refreshDic];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mj_header endRefreshing];
    });
}

-(void)getParaWithKey:(NSString *)key fromDict:(NSDictionary *)dict{
    
    if (!self.loadMoreParaKey) {
        return;
    }
    
    if ([dict.allKeys containsObject:@"list"]) {
        NSArray *items = dict[@"list"];
        
        NSInteger last_id = 100000000000;
        for (NSDictionary *dd in items) {
            if ([dd.allKeys containsObject:self.loadMoreParaKey]) {
                
                if (last_id>[dd[self.loadMoreParaKey] integerValue]) {
                    last_id = [dd[self.loadMoreParaKey] integerValue];
                }
            }
        }
        NSMutableDictionary *m_dict = self.refreshDic.mutableCopy;
        
        NSString *keyStr= [NSString stringWithFormat:@"last_%@",self.loadMoreParaKey];
        NSString *valueStr = [AppGeneral getSafeValueWith:@(last_id)];
        [m_dict setValue:valueStr forKey:keyStr];

        self.refreshDic = m_dict.copy;
    }
}

/*
 * Simultaneously:同时地;
 * 是否允许多个手势识别器共同识别，一个控件的手势识别后是否阻断手势识别继续向下传播，默认返回NO；如果为YES，响应者链上层对象触发手势识别后，如果下层对象也添加了手势并成功识别也会继续执行，否则上层对象识别后则不再继续传播
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return self.shouldRecognize;
//    return YES;
}

@end
