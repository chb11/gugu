//
//  CB_ActivityModel.m
//  gugu
//
//  Created by Mike Chen on 2019/5/24.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_ActivityGroupModel.h"

@implementation CB_ActivityGroupModel

-(NSString *)GroupHeadPhotoURL{
    NSString *url = self.GroupHeadPhoto;
    if (![self.GroupHeadPhoto containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.GroupHeadPhoto];
    }
    return url;
}

@end
