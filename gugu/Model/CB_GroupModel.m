//
//  CB_GroupModel.m
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_GroupModel.h"

@implementation CB_GroupModel

-(NSString *)GroupHeadPhotoURL{
    NSString *url = self.GroupHeadPhoto;
    if (![self.GroupHeadPhoto containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.GroupHeadPhoto];
    }
    return url;
}

-(NSString *)HeadPhotoURL{
    NSString *url = self.HeadPhoto;
    if (![self.HeadPhoto containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.HeadPhoto];
    }
    return url;
}
@end
