//
//  CB_Database.m
//  VoicePackage
//
//  Created by douyinbao on 2018/10/12.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import "CB_Database.h"
#import <FMDB.h>
#import "EncryptUtl.h"

static CB_Database *_DBCtl = nil;
static NSString *desKey = @"gugu";

@interface CB_Database()<NSCopying,NSMutableCopying>{
    FMDatabase  *_db;
}
@end

@implementation CB_Database

+(instancetype)sharedDataBase{
    //线程锁
    @synchronized (self) {
        if (_DBCtl == nil) {
            _DBCtl = [[CB_Database alloc] init];
            [_DBCtl initDataBase];
        }
    }
    return _DBCtl;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (_DBCtl == nil) {
        _DBCtl = [super allocWithZone:zone];
    }
    return _DBCtl;
}

-(id)copy{
    return self;
}

-(id)mutableCopy{
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return self;
}

-(void)initDataBase{
    // 获得Documents目录路径
    
    //判断是否创建过数据库文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"model" ofType:@"sqlite"];
    if(path != NULL){
        return;
    }
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"model.sqlite"];
    
    // 实例化FMDataBase对象
    _db = [FMDatabase databaseWithPath:filePath];
    
    [_db open];
    
    // 初始化数据表
    NSString *message = @"CREATE TABLE 't_message' ( 'id' INTEGER, 'GroupName' VARCHAR(255), 'SendName' VARCHAR(255), 'Message' VARCHAR(255), 'Collect' VARCHAR(255), 'SendPhotoUrl' VARCHAR(255), 'SendId' VARCHAR(255),'CollectName' VARCHAR(255),'SenderType' VARCHAR(255),'Duration' VARCHAR(255),'GroupHeadPhoto' VARCHAR(255),'Guid' VARCHAR(255),'SendUserUrl' VARCHAR(255),'ReadState' VARCHAR(255),'Type' VARCHAR(255),'FileUrl' VARCHAR(255),'IsGroup' VARCHAR(255),'SendPhone' VARCHAR(255),'CreatDate' VARCHAR(255),'PostDate' VARCHAR(255),'MessageType' VARCHAR(255),'SendUserId' VARCHAR(255),'CurrentUserId' VARCHAR(255),PRIMARY KEY (Guid))";
    [_db executeUpdate:message];

    [_db close];
}

#pragma mark - 语音包

-(void)action_saveMessage:(CB_MessageModel *)model{
    

    [_db open];
    [_db executeUpdate:@"INSERT OR REPLACE INTO t_message(GroupName,SendName,Message,SendId,Guid,PostDate,Type,SendUserUrl,CurrentUserId)VALUES(?,?,?,?,?,?,?,?,?)",
      model.GroupName,
      model.SendName,
      model.Message,
      model.SendId,
      model.Guid,
      model.PostDate,
      model.Type,
      model.SendUserUrl,
    [UserModel shareInstance].Guid];
    
    
//    [_db executeUpdate:@"INSERT OR REPLACE INTO t_message(GroupName,SendName,Message,Collect,SendPhotoUrl,SendId,SenderType,Duration,GroupHeadPhoto,Guid,SendUserUrl,ReadState,Type,IsGroup,SendPhone,CreatDate,PostDate,MessageType,SendUserId)VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
//     [EncryptUtl encryptUseDES:model.GroupName key:desKey],
//     [EncryptUtl encryptUseDES:model.SendName key:desKey],
//     [EncryptUtl encryptUseDES:model.Message key:desKey],
////     model.Collect,
//     [EncryptUtl encryptUseDES:model.SendPhotoUrl key:desKey] ,
//     model.SendId,
//     [EncryptUtl encryptUseDES:model.CollectName key:desKey],
//     [NSString stringWithFormat:@"%ld",(long)model.SenderType],
//     [NSString stringWithFormat:@"%ld",(long)model.Duration],
//     [EncryptUtl encryptUseDES:model.GroupHeadPhoto key:desKey],
//     model.Guid,
//     [EncryptUtl encryptUseDES:model.SendUserUrl key:desKey],
//     model.ReadState,
//     model.Type,
//     model.IsGroup,
//     model.SendPhone,
//     model.CreatDate,
//     model.PostDate,
//     [NSString stringWithFormat:@"%ld",model.MessageType],
//     model.SendUserId];
    [_db close];
    
    
}

-(NSArray *)lastedMessageFromLocal{
    
    NSMutableArray *m_arr = @[].mutableCopy;
    
    [_db open];
    NSString *searchString =  [NSString stringWithFormat:@"%%%@%%", [UserModel shareInstance].Guid];
//    NSString *sql = [NSString stringWithFormat:@"select * from t_message CurrentUserId like ? order by PostDate desc",searchString];
    FMResultSet *res = [_db executeQuery:@"select * from t_message where CurrentUserId like ? order by PostDate desc;",searchString];
        while ([res next]) {
            
            NSString *sendId = [res stringForColumn:@"SendId"];
            
            BOOL isContain = NO;
            for (NSDictionary *temp_dict in m_arr) {
                CB_MessageModel *tempModel = [CB_MessageModel modelWithDictionary:temp_dict];
                if ([tempModel.SendId isEqualToString:sendId]) {
                    isContain = YES;
                }
            }
            
            if (!isContain) {
                CB_MessageModel *model = [[CB_MessageModel alloc] init];
                model.GroupName = [res stringForColumn:@"GroupName"];
                model.SendName= [res stringForColumn:@"SendName"];
                model.Message= [res stringForColumn:@"Message"];
                model.Collect= [[res stringForColumn:@"Collect"] boolValue];
                model.SendPhotoUrl= [res stringForColumn:@"SendPhotoUrl"];
                model.SendId= sendId;
                model.CollectName=[res stringForColumn:@"CollectName"];
                model.SenderType= [[res stringForColumn:@"SenderType"] integerValue];
                model.Duration= [[res stringForColumn:@"Duration"] integerValue];
                model.GroupHeadPhoto=[res stringForColumn:@"GroupHeadPhoto"];
                model.Guid= [res stringForColumn:@"Guid"];
                model.SendUserUrl= [res stringForColumn:@"SendUserUrl"];
                model.ReadState= [[res stringForColumn:@"ReadState"] boolValue];
                model.Type= [res stringForColumn:@"Type"];
//                model.FileUrl= [res stringForColumn:@"FileUrl"];
                model.IsGroup= [[res stringForColumn:@"IsGroup"] boolValue];
                model.SendPhone= [res stringForColumn:@"SendPhone"];
                model.CreatDate= [res stringForColumn:@"CreatDate"];
                model.PostDate= [res stringForColumn:@"PostDate"];
                model.MessageType= [[res stringForColumn:@"MessageType"] integerValue];
                model.SendUserId= [res stringForColumn:@"SendUserId"];
                [m_arr addObject:[model dictionaryRepresentation]];
            }

        }
    [_db close];
    return m_arr;
}

/*
 更新语音包收藏状态
 */
//-(void)updatePackageCollectedState:(BOOL)iscollected packageId:(NSString *)pagkageId{
//    NSArray *items = [self searchWithPackageId:pagkageId];
//    [_db open];
//    if (items.count>0) {
//        [_db executeUpdate:@"UPDATE t_package SET isCollect = ? WHERE package_id = ? and operatino_user_id = ?;", @(iscollected), pagkageId,[UserModel sharedInstance].userID];
//    }else{
//        [_db executeUpdate:@"INSERT OR REPLACE INTO t_package(package_id,operatino_user_id,isCollect)VALUES(?,?,?)",pagkageId,[UserModel sharedInstance].userID,@(iscollected)];
//    }
//    [_db close];
//}
///*
// 更新语音包点赞状态
// */
//-(void)updatePackagePraisedState:(BOOL)isPraised packageId:(NSString *)pagkageId{
//    NSArray *items = [self searchWithPackageId:pagkageId];
//    [_db open];
//    if (items.count>0) {
//        [_db executeUpdate:@"UPDATE t_package SET isPraise = ? WHERE package_id = ? and operatino_user_id = ?;", @(isPraised), pagkageId,[UserModel sharedInstance].userID];
//    }else{
//        [_db executeUpdate:@"INSERT OR REPLACE INTO t_package(package_id,operatino_user_id,isPraise)VALUES(?,?,?)",pagkageId,[UserModel sharedInstance].userID,@(isPraised)];
//    }
//    [_db close];
//}
//
///*
// 更新语音包分享状态
// */
//-(void)updatePackageSharedState:(BOOL)isShared packageId:(NSString *)pagkageId{
//
//    NSArray *items = [self searchWithPackageId:pagkageId];
//    [_db open];
//    if (items.count>0) {
//        [_db executeUpdate:@"UPDATE t_package SET isShared = ? WHERE package_id = ? and operatino_user_id = ?;", @(isShared), pagkageId,@"";
//    }else{
//        [_db executeUpdate:@"INSERT OR REPLACE INTO t_package(package_id,operatino_user_id,isShared)VALUES(?,?,?)",pagkageId,[UserModel sharedInstance].userID,@(isShared)];
//    }
//    [_db close];
//}
//
//
//
//
//
//
//#pragma mark - 加关注
///**
// 更新评论状态
// */
//-(void)updateFanUserState:(NSString *)userID isLike:(BOOL)isLike{
//
//    NSArray *items = [self searchWithFansUserId:userID];
//    [_db open];
//    if (items.count>0) {
//        [_db executeUpdate:@"UPDATE fans_user SET isFans = ? WHERE user_id = ? and operatino_user_id = ?", @(isLike), userID,[UserModel sharedInstance].userID];
//    }else{
//        [_db executeUpdate:@"INSERT OR REPLACE INTO fans_user(user_id,operatino_user_id,isFans)VALUES(?,?,?)",userID,[UserModel sharedInstance].userID,@(isLike)];
//    }
//
//    [_db close];
//
//}
///**
// 是否点赞评论
// */
//-(BOOL)isFansUserWithUserId:(NSString *)userID{
//    NSArray *carArray = [self searchWithFansUserId:userID];
//    if (carArray.count == 1) {
//        RemarkLocalModel *article = carArray[0];
//        if (article.isPraised == 1) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//-(NSArray *)searchWithFansUserId:(NSString *)userID{
//    [_db open];
//    NSMutableArray  *carArray = [[NSMutableArray alloc] init];
//    FMResultSet *res = [_db executeQuery:[NSString stringWithFormat:@"SELECT * FROM fans_user WHERE user_id = %@  and operatino_user_id = %@",userID,[UserModel sharedInstance].userID]];
//    while ([res next]) {
//        RemarkLocalModel *package = [[RemarkLocalModel alloc] init];
//        package.remarkId = userID;
//        package.isPraised = [[res stringForColumn:@"isFans"] integerValue];
//        [carArray addObject:package];
//    }
//    [_db close];
//    return carArray.copy;
//}

@end
