//
//  DSR_ActionManager.h
//  shiguang
//
//  Created by chun on 2019/4/3.
//  Copyright © 2019年 chun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CB_MessageModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface CB_MessageManager : NSObject

+(CB_MessageManager *)sharedInstance;
+(void)action_initTable;
//添加事件
+(void)action_saveAction:(CB_MessageModel *)model;
//修改事件
+(void)action_updateAction:(CB_MessageModel *)model;
//删除事件
+(void)action_deleteAction:(CB_MessageModel *)model;
//置顶事件
+(void)action_TopAction:(CB_MessageModel *)model;

//保存去过的地址
+(void)action_saveNavi:(CB_MessageModel *)model;
//查询所有去过的地址
+(NSArray *)action_findAllNaviAddress;

//查询最新消息
+(NSArray *)action_findLastedMessage;
//查询所有事件
+(NSArray *)action_selectAllAction;

@end

NS_ASSUME_NONNULL_END
