//
//  CB_ContactModel.m
//  gugu
//
//  Created by Mike Chen on 2019/3/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_ContactModel.h"

@implementation CB_ContactModel


-(NSString *)HeadPhotoURL{
    NSString *url = self.PhotoUrl;
    if (![self.PhotoUrl containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,self.PhotoUrl];
    }
    return url;
}

@end
