//
//  CB_MessageModel.m
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_MessageModel.h"

@implementation CB_MessageModel

-(NSString *)loginUserId{
    return [UserModel shareInstance].Guid;
}

-(NSString *)loginUserName{
    return [UserModel shareInstance].UserName;
}

-(NSString *)FileUrlURL{
    NSString *url = self.FileUrl;
    if (![self.FileUrl containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.FileUrl];
    }
    return url;
}

-(NSString *)SendPhotoUrlURL{
    NSString *url = self.SendPhotoUrl;
    if (![self.SendPhotoUrl containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.SendPhotoUrl];
    }
    return url;
}
-(NSString *)GroupHeadPhotoURL{
    NSString *url = self.GroupHeadPhoto;
    if (![self.GroupHeadPhoto containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.GroupHeadPhoto];
    }
    return url;
}
-(NSString *)SendUserUrlURL{
    NSString *url = self.SendUserUrl;
    if (![self.SendUserUrl containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.SendUserUrl];
    }
    return url;
}

-(NSString *)GuUserHeadURL{
    NSString *url = self.GuUserHeadUrl;
    if (![self.GuUserHeadUrl containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.GuUserHeadUrl];
    }
    return url;

}


- (NSDictionary *)dictionaryRepresentation{
    NSMutableDictionary *m_dict = @{}.mutableCopy;
    [m_dict setValue:self.GroupName forKey:@"GroupName"];
    [m_dict setValue:self.SendName forKey:@"SendName"];
    [m_dict setValue:self.Message forKey:@"Message"];
    [m_dict setValue:@(self.Collect) forKey:@"Collect"];
    [m_dict setValue:self.SendPhotoUrl forKey:@"SendPhotoUrl"];
    [m_dict setValue:self.SendId forKey:@"SendId"];
    [m_dict setValue:self.CollectName forKey:@"CollectName"];
    [m_dict setValue:@(self.SenderType) forKey:@"SenderType"];
    [m_dict setValue:@(self.Duration) forKey:@"Duration"];
    [m_dict setValue:self.GroupHeadPhoto forKey:@"GroupHeadPhoto"];
    [m_dict setValue:self.Guid forKey:@"Guid"];
    [m_dict setValue:self.SendUserUrl forKey:@"SendUserUrl"];
    [m_dict setValue:@(self.ReadState) forKey:@"ReadState"];
    [m_dict setValue:self.Type forKey:@"Type"];
    [m_dict setValue:self.FileUrl forKey:@"FileUrl"];
    [m_dict setValue:@(self.IsGroup) forKey:@"IsGroup"];
    [m_dict setValue:self.SendPhone forKey:@"SendPhone"];
    [m_dict setValue:self.CreatDate forKey:@"CreatDate"];
    [m_dict setValue:self.PostDate forKey:@"PostDate"];
    [m_dict setValue:@(self.MessageType) forKey:@"MessageType"];
    [m_dict setValue:self.SendUserId forKey:@"SendUserId"];
    [m_dict setValue:self.GuUserId forKey:@"GuUserId"];
    [m_dict setValue:self.GuUserName forKey:@"GuUserName"];
    [m_dict setValue:self.GuUserHeadUrl forKey:@"GuUserHeadUrl"];
    return m_dict;
}

@end
