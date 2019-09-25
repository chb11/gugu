//
//  NetWorkConnect.h
//  Factoring
//  Created by douyinbao on 14/12/9.
//  Copyright (c) 2014年 douyinbao All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "NetRequestDefine.h"

#define NETMANEGER [NetWorkConnect manager]

typedef void(^AFNNetConnect)( NSInteger resultCode, id responseObject,NSError *error);

@interface NetWorkConnect : NSObject
@property (nonatomic,weak)AFNNetConnect netConnect;

+ (NetWorkConnect *)manager;
//上传图片
-(void)postImageWith:(NSData *)data postDataWith:(NSDictionary *)parameter withUrl:(NSString *)str withFileName:(NSString *)name  withResult:(AFNNetConnect)result;
//需要加密的Post请求
-(void)postDataWith:(NSDictionary *)parameter withUrl:(NSString *)url  withResult:(AFNNetConnect)result;

//- (void)getDataWith:(NSDictionary *)parameter withUrl:(NSString *)str  withResult:(AFNNetConnect)result;

- (void)downloadFileWithUrl:(NSString*)requestURL andFileName:(NSString *)name  downloadSuccess:(void (^)(NSURL *filePath,NSError *error))success;
//音频上传
-(void)postAudioWith:(NSString *)filePath postDataWith:(NSDictionary *)parameter withUrl:(NSString *)url withFileName:(NSString *)name  withResult:(AFNNetConnect)result;
-(void)uploadVideoWithExportUrl:(NSURL*)exporUrl with:(NSString *)uploadUrl WithDic :(NSDictionary *)dic withResult:(AFNNetConnect)result;


+(void)clearCookies;

+(void)CancleDownLoadTask;

@end
