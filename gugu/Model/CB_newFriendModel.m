//
//  CB_newFriendModel.m
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_newFriendModel.h"

@implementation CB_newFriendModel

-(NSString *)ApplyUserHeadPhotoURL{
    NSString *url = self.ApplyUserHeadPhoto;
    if (![self.ApplyUserHeadPhoto containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.ApplyUserHeadPhoto];
    }
    return url;
}


@end
