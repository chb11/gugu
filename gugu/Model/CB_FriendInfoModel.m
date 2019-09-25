//
//  CB_FriendInfoModel.m
//  gugu
//
//  Created by Mike Chen on 2019/3/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_FriendInfoModel.h"

@implementation CB_FriendInfoModel

-(NSString *)HeadPhotoURL{
    NSString *url = self.PhotoUrl;
    if (![self.PhotoUrl containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.PhotoUrl];
    }
    return url;
}


@end
