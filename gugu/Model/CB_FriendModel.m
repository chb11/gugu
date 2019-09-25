//
//  CB_FriendModel.m
//  gugu
//
//  Created by Mike Chen on 2019/3/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_FriendModel.h"

@implementation CB_FriendModel

-(NSString *)HeadPhotoURL{
    NSString *url = self.FriendHeadPhoto;
    if (![self.FriendHeadPhoto containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.FriendHeadPhoto];
    }
    return url;
}

@end
