//
//  PerMissonManager.h
//  PPLiaoMei
//
//  Created by BeRich2019 on 2017/5/17.
//  Copyright © 2017年 BingQiLin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PerMissonManager : NSObject
+(BOOL)isOpenCamera;
+(BOOL)isOpenAlbum;
+(BOOL)isOpenMicroPhone;

+(BOOL)PhotoAlbumPermissions;

@end
