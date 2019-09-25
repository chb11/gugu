//
//  DSR_ActionManager.m
//  shiguang
//
//  Created by chun on 2019/4/3.
//  Copyright © 2019年 chun. All rights reserved.
//

#import "CB_MessageManager.h"
#import <JQFMDB/JQFMDB.h>

static CB_MessageManager *_instance = nil;

@interface CB_MessageManager ()



@end

@implementation CB_MessageManager

+(CB_MessageManager *)sharedInstance
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instance = [[CB_MessageManager alloc]init];
    });
    return _instance;
}

+(NSString *)t_tableName{
    NSString *user_id = [UserModel shareInstance].Guid;
    NSString *t_table = [NSString stringWithFormat:@"t_%@",user_id];
    return t_table;
}

+(NSString *)t_AddresstableName{
    NSString *user_id = [UserModel shareInstance].Guid;
    NSString *t_table = [NSString stringWithFormat:@"t_Address_%@",user_id];
    return t_table;
}

+(void)action_initTable{
    JQFMDB *db = [JQFMDB shareDatabase];
    [db jq_createTable:[CB_MessageManager t_tableName] dicOrModel:[CB_MessageModel class]];
    [db jq_createTable:[CB_MessageManager t_AddresstableName] dicOrModel:[CB_MessageModel class]];
}

+(void)action_saveAction:(CB_MessageModel *)model{
    
    if (model.SenderType == 3) {
        return;
    }
    
    // 创建数据库
    JQFMDB *db = [JQFMDB shareDatabase];
    // 向user表中插入一条数据
    
    NSArray *allMessage = [CB_MessageManager action_selectAllAction];
    BOOL isExist = NO;
    for (CB_MessageModel *msgModel in allMessage) {
        if ([model.SendUserId isEqualToString:msgModel.SendUserId]) {
            isExist = YES;
            break;
        }
    }
    if (isExist) {

        [CB_MessageManager action_updateAction:model];
    }else{
        [db jq_insertTable:[CB_MessageManager t_tableName] dicOrModel:model];
    }
}

//修改事件
+(void)action_updateAction:(CB_MessageModel *)model{
    // 创建数据库
    JQFMDB *db = [JQFMDB shareDatabase];
    NSString *str = [NSString stringWithFormat:@"WHERE SendId = '%@'",model.SendId];
    //更新最后一条数据 name=testName , dicOrModel的参数也可以是name为testName的person
    [db jq_updateTable:[CB_MessageManager t_tableName] dicOrModel:model whereFormat:str];
}

//删除事件
+(void)action_deleteAction:(CB_MessageModel *)model{
    JQFMDB *db = [JQFMDB shareDatabase];
    NSString *str = [NSString stringWithFormat:@"WHERE SendId = '%@'",model.SendId];
    [db jq_deleteTable:[CB_MessageManager t_tableName] whereFormat:str];
}

//置顶事件
+(void)action_TopAction:(CB_MessageModel *)model{
    JQFMDB *db = [JQFMDB shareDatabase];
    //把表中所有的name改成godlike
    [db jq_updateTable:[CB_MessageManager t_tableName] dicOrModel:@{@"isToTOP":@(NO)} whereFormat:nil];
    NSString *str = [NSString stringWithFormat:@"WHERE pkid = %@ FROM %@)",model.pkid,[CB_MessageManager t_tableName]];
    //更新最后一条数据 name=testName , dicOrModel的参数也可以是name为testName的person
    [db jq_updateTable:[CB_MessageManager t_tableName] dicOrModel:model whereFormat:str];
}

//保存去过的地址
+(void)action_saveNavi:(CB_MessageModel *)model{
    // 创建数据库
    JQFMDB *db = [JQFMDB shareDatabase];
    // 向user表中插入一条数据
    
    NSArray *allMessage = [CB_MessageManager action_findAllNaviAddress];
    BOOL isExist = NO;
    for (CB_MessageModel *msgModel in allMessage) {
        if ([model.Guid isEqualToString:msgModel.Guid]) {
            isExist = YES;
            break;
        }
    }
    if (isExist) {
        //        model.NoReadNum = 0;
        [CB_MessageManager action_updateAction:model];
    }else{
        [db jq_insertTable:[CB_MessageManager t_AddresstableName] dicOrModel:model];
    }
}

//查询所有去过的地址
+(NSArray *)action_findAllNaviAddress{
    JQFMDB *db = [JQFMDB shareDatabase];
    //查找表中所有数据
    NSArray *personArr = [db jq_lookupTable:[CB_MessageManager t_AddresstableName] dicOrModel:[CB_MessageModel class] whereFormat:nil];
    return personArr;
    
}

//查询所有事件
+(NSArray *)action_selectAllAction{
    JQFMDB *db = [JQFMDB shareDatabase];
    //查找表中所有数据
    NSArray *personArr = [db jq_lookupTable:[CB_MessageManager t_tableName] dicOrModel:[CB_MessageModel class] whereFormat:nil];
    return personArr;
}

+(NSArray *)action_findLastedMessage{
    NSArray *allMessage = [CB_MessageManager action_selectAllAction];
    
    NSMutableArray *sortedAllMessage = [CB_MessageManager sortedArrayWith:allMessage.mutableCopy isDaoxu:YES];
    
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    
    for (CB_MessageModel *model in sortedAllMessage) {
        if (![tmpDict.allKeys containsObject:model.SendId]) {
            [tmpDict setObject:model forKey:model.SendId];
        }
    }
    NSArray *lastedArr = tmpDict.allValues;
    NSMutableArray *m_arr = [CB_MessageManager sortedArrayWith:lastedArr.mutableCopy isDaoxu:YES];
    
    return m_arr;
}

+(NSDateComponents *)dateComponentsFromDateStr:(NSString *)dateStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *eventDate = [formatter dateFromString:dateStr];
    // 2.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type =  NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 3.利用日历对象比较两个时间的差值
    NSDateComponents *comps = [calendar components:type fromDate:eventDate];
    return comps;
}

+(NSMutableArray *)sortedArrayWith:(NSMutableArray<CB_MessageModel *> *)modelArray isDaoxu:(BOOL)isDaoxu{
    if (modelArray.count < 2) {
        return modelArray;
    }
    NSMutableArray *newArray = @[].mutableCopy;
    NSArray *arr = [modelArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CB_MessageModel *model1 = obj1;
        CB_MessageModel *model2 = obj2;
        BOOL result = [AppGeneral compareDate:model1.PostDate andDate:model2.PostDate];
        if (!isDaoxu) {
            if (result) {
                return NSOrderedDescending;
            }else{
                return NSOrderedAscending;
            }
        }else{
            if (result) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }
        
        return NSOrderedAscending;
    }];
    newArray = arr.mutableCopy;
    return newArray;
}

@end
