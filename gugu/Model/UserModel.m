//
//  UserModel.m
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "UserModel.h"

static UserModel *_instance = nil;
@interface UserModel ()


@end

@implementation UserModel

+ (UserModel *)shareInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}
//+ (instancetype)allocWithZone:(struct _NSZone *)zone
//{
//    return [self shareInstance];
//}
//
//- (id)copyWithZone:(NSZone *)zone
//{
//    return self;
//}
//
//- (id)mutableCopyWithZone:(NSZone *)zone
//{
//    return self;
//}

-(void)reloadModelWith:(UserModel *)model{
    [UserModel shareInstance].Guid = model.Guid;
    [UserModel shareInstance].Password = model.Password;
    [UserModel shareInstance].Email = model.Email;
    [UserModel shareInstance].Phone = model.Phone;
    [UserModel shareInstance].GuNum = model.GuNum;
    [UserModel shareInstance].UserName = model.UserName;
    [UserModel shareInstance].HeadPhoto = model.HeadPhoto;
    [UserModel shareInstance].OnlineId = model.OnlineId;
}

+(instancetype)newModelWithDict:(NSDictionary *)dict{
    
    UserModel *newModel = [[UserModel alloc] init];
    BOOL result = [newModel modelSetWithJSON:dict];
    if (!result) {
        return nil;
    }
    return newModel;
}

- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *m_dict = @{}.mutableCopy;
    [m_dict setValue:[UserModel shareInstance].Guid forKey:@"Guid"];
    [m_dict setValue:[UserModel shareInstance].Password forKey:@"Password"];
    [m_dict setValue:[UserModel shareInstance].Email forKey:@"Email"];
    [m_dict setValue:[UserModel shareInstance].Phone forKey:@"Phone"];
    [m_dict setValue:[UserModel shareInstance].GuNum forKey:@"GuNum"];
    [m_dict setValue:[UserModel shareInstance].UserName forKey:@"UserName"];
    [m_dict setValue:[UserModel shareInstance].HeadPhoto forKey:@"HeadPhoto"];
    [m_dict setValue:[UserModel shareInstance].OnlineId forKey:@"OnlineId"];
    return m_dict;
}

-(NSString *)HeadPhotoURL{
    NSString *url = self.HeadPhoto;
    if (![self.HeadPhoto containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.HeadPhoto];
    }
    return url;
}

@end
