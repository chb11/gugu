//
//  NetWorkConnect.m
//  Factoring
//  Created by douyinbao on 14/12/9.
//  Copyright (c) 2014年 douyinbao. All rights reserved.
//

#import "NetWorkConnect.h"
#import "AppDelegate.h"
#define BASE_PARAMETER  [NSString stringWithFormat:@"appid=%@&version=%@", HappyChat_APPID,APP_CURRENT_VERSION]

//访问接口超时时间
#define timeOut 5
@interface NetWorkConnect()

//上次访问的接口
@property (nonatomic,strong) NSMutableArray *lastUrls;
@property (nonatomic, weak) NSURLSessionDownloadTask *downLoadTask;

@end

@implementation NetWorkConnect

static NetWorkConnect *data= nil;
+(NetWorkConnect *)manager{
    @synchronized(self){
        if (data == nil) {
            data = [[NetWorkConnect alloc] init];
        }
    }
    return data;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(NSMutableArray *)lastUrls{
    if (!_lastUrls) {
        _lastUrls = @[].mutableCopy;
    }
    return _lastUrls;
}

-(void)postDataWith:(NSDictionary *)parameter withUrl:(NSString *)url  withResult:(AFNNetConnect)result
{
    //验证重复提交
    if (![self checkResumbit:url]) {
        return;
    }

    if ([url isEqualToString:CHAT_MESSAGE_SEND_MESSAGE]) {
        NSMutableDictionary *m_dict = parameter.mutableCopy;
        NSString *uuidSetr = [AppGeneral randomUuidString];
        if (uuidSetr.length>0) {
            [m_dict setValue:uuidSetr forKey:@"LocalGuid"];
            parameter = m_dict.copy;
        }
    }
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = timeOut;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.HTTPShouldHandleCookies = YES;
    [manager.requestSerializer setValue:[self loginCookieStrFromLocal] forHTTPHeaderField:@"Cookie"];
    NSString * requestUrl = IMGLINK(NET_MAIN_URL, url);
    
    
    NSLog(@"url =  %@ para:%@",requestUrl,parameter);
    
    [manager POST:requestUrl parameters:parameter progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [HYActivityIndicator stopActivityAnimation];
        NSDictionary *returnDict = @{};
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            returnDict = responseObject;
        }else if ([responseObject isKindOfClass:[NSData class]]){
            NSString*jsonString = [[NSString alloc]initWithBytes:[responseObject bytes]length:[responseObject length]encoding:NSUTF8StringEncoding];
            NSData* jsonData1 = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            returnDict = [NSJSONSerialization JSONObjectWithData:jsonData1 options:NSJSONReadingMutableLeaves error:nil];
            if (returnDict.allKeys.count ==0) {
                
                NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                returnDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            }
            NSLog(@"请求结果===%@",jsonString);
        }
        
        if ([url isEqualToString:V_USER_LOGIN]) {
            
            //获取 Cookie
            NSHTTPURLResponse* response = (NSHTTPURLResponse* )task.response;
            [self saveCookie:response];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger returnCode  = [[returnDict objectForKey:@"status"] integerValue];
            if (returnCode != 1) {
                NSString *msg = [returnDict objectForKey:@"msg"];
                [SVProgressHUD showErrorWithStatus:msg];
                [SVProgressHUD dismissWithDelay:1.5];
            }
            if (result) {
                NSDictionary *dataDict = [returnDict objectForKey:@"data"];
                result(returnCode,dataDict,nil);
            }
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                result(-1,nil,error);
            }
        });
       
        NSLog(@"%@",error);
        
        //访问超时
        if (error.code == -1001) {
            
            [task cancel];
            [SVProgressHUD showErrorWithStatus:@"当前网络不稳定，请稍后重试"];
            [SVProgressHUD dismissWithDelay:1.5];
        }
    }];
}



-(void)postImageWith:(NSData *)data postDataWith:(NSDictionary *)parameter withUrl:(NSString *)str withFileName:(NSString *)name  withResult:(AFNNetConnect)result{
    
    //验证重复提交
    if (![self checkResumbit:str]) {
        return;
    }
    NSString * url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,str];
    NSMutableDictionary * dicParameters = [NSMutableDictionary dictionaryWithDictionary:parameter];
    NSLog(@"url =  %@",[NSString stringWithFormat:@"%@",url]);
    NSMutableURLRequest *request=[[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dicParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        formatter.dateFormat=@"yyyyMMddHHmmss";
        NSString *str=[formatter stringFromDate:[NSDate date]];
        NSString *fileName=[NSString stringWithFormat:@"upload_%@.jpg",str];
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
    } error:nil];
    request.HTTPShouldHandleCookies = YES;
    [request setValue:[self loginCookieStrFromLocal] forHTTPHeaderField:@"Cookie"];
    
    AFURLSessionManager *manager=[[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    
    NSURLSessionUploadTask *uploadTask=[manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
        {
            NSLog(@"%@",error);
            [HYActivityIndicator stopActivityAnimation];
        }
        else
        {
            NSString*requestTmp = [[NSString alloc]initWithBytes:[responseObject bytes]length:[responseObject length]encoding:NSUTF8StringEncoding];
            NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"请求结果===%@",requestTmp);
            NSInteger returnCode  = [[dic objectForKey:@"status"] integerValue];
            
            if (returnCode == 2) {
                NSString *msg = [dic objectForKey:@"msg"];
                if ([msg containsString:@"登录"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEED_LOGIN object:nil];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    result(returnCode,dic,nil);
                }
                [HYActivityIndicator stopActivityAnimation];
            });
            
        }
    }];
    [uploadTask resume];
}

- (void)downloadFileWithUrl:(NSString*)requestURL andFileName:(NSString *)name  downloadSuccess:(void (^)(NSURL *filePath,NSError *error))success
{
    
    
    [NetWorkConnect ManageLocalFileWithFileName:name];
    
    if ([self isSavedFileToLocalWithLink:requestURL andName:name]) {
        
        NSString * destaion =[self getPathWithUrl:requestURL andName:name]  ;
        dispatch_async(dispatch_get_main_queue(), ^{
            success([NSURL fileURLWithPath:destaion],nil);
        });
        
        return;
    }
    if (_downLoadTask) {
        [_downLoadTask cancel];
    }
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //    NSString * destaion =IMGLINK([self getPathWithUrl:requestURL andName:name], @"file")  ;
    NSString * destaion =[self getPathWithUrl:requestURL andName:name]  ;
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *fileURL = [NSURL fileURLWithPath:destaion];
        return  fileURL ;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            success(filePath,error);
        });
    }];
    _downLoadTask  = task;
    
    [task resume];
}


//音频上传
-(void)postAudioWith:(NSString *)filePath postDataWith:(NSDictionary *)parameter withUrl:(NSString *)url withFileName:(NSString *)name  withResult:(AFNNetConnect)result{
    
    //验证重复提交
    if (![self checkResumbit:url]) {
        return;
    }
    
    NSString * requestUrl = IMGLINK(NET_MAIN_URL, url);
    
    NSURL *path = [NSURL fileURLWithPath:filePath];
    NSMutableDictionary * dicParameters = [NSMutableDictionary dictionaryWithDictionary:parameter];
    NSLog(@"url =  %@",[NSString stringWithFormat:@"%@",requestUrl]);
    NSMutableURLRequest *request=[[AFHTTPRequestSerializer serializer]multipartFormRequestWithMethod:@"POST" URLString:requestUrl parameters:dicParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        formatter.dateFormat=@"yyyyMMddHHmmss";
        NSString *str=[formatter stringFromDate:[NSDate date]];
        NSString *fileName=[NSString stringWithFormat:@"head_%@.mp3",str];
        [formData appendPartWithFileURL:path name:name fileName:fileName mimeType:@"application/octet-stream" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager=[[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    
    NSURLSessionUploadTask *uploadTask=[manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
        {
            [HYActivityIndicator stopActivityAnimation];
        }
        else
        {
            NSString*requestTmp = [[NSString alloc]initWithBytes:[responseObject bytes]length:[responseObject length]encoding:NSUTF8StringEncoding];
            NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"请求结果===%@",requestTmp);
            NSInteger returnCode  = [[dic objectForKey:@"result"] integerValue];
            if (result) {
                result(returnCode,dic,nil);
            }
            [HYActivityIndicator stopActivityAnimation];
        }
    }];
    [uploadTask resume];
}
-(void)uploadVideoWithExportUrl:(NSURL*)exporUrl with:(NSString *)uploadUrl WithDic :(NSDictionary *)dic withResult:(AFNNetConnect)result
{
    NSString * url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,uploadUrl];
    
    NSURL *path = exporUrl;
    NSMutableDictionary * dicParameters = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSLog(@"url =  %@",url);
    NSMutableURLRequest *request=[[AFHTTPRequestSerializer serializer]multipartFormRequestWithMethod:@"POST" URLString:url parameters:dicParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        formatter.dateFormat=@"yyyyMMddHHmmss";
        NSString *str=[formatter stringFromDate:[NSDate date]];
        NSString *fileName=[NSString stringWithFormat:@"head_%@.MOV",str];
        [formData appendPartWithFileURL:path name:@"Video" fileName:fileName mimeType:@"application/octet-stream" error:nil];
    } error:nil];
    
    AFURLSessionManager *manager=[[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    
    NSURLSessionUploadTask *uploadTask=[manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error)
        {
            NSLog(@"请求结果===%@",error);
            [HYActivityIndicator stopActivityAnimation];
        }
        else
        {
            NSString*requestTmp = [[NSString alloc]initWithBytes:[responseObject bytes]length:[responseObject length]encoding:NSUTF8StringEncoding];
            NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"请求结果===%@",requestTmp);
            NSInteger returnCode  = [[dic objectForKey:@"status"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    result(returnCode,dic,nil);
                }
                [HYActivityIndicator stopActivityAnimation];
            });
            
        }
    }];
    [uploadTask resume];
}

- (BOOL)isSavedFileToLocalWithLink:(NSString *)url andName:(NSString*)name
{
    // 判断是否已经离线下载了
    
    NSString *suffix =[[url componentsSeparatedByString:@"."] lastObject];
    
    
    NSRange range = [url rangeOfString:suffix];
    NSString *mp3name = [CMD5 md532BitLower:[url substringToIndex:range.location]];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *path =  [ NSString stringWithFormat:@"%@/%@/%@.%@",documentsDirectory,name, mp3name,suffix];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
}

-(NSString *)getPathWithUrl:(NSString *)url andName:(NSString*)name
{
    NSString *suffix =@"mp3";
    NSString *mp3name = [CMD5 md532BitLower:url];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSString *directoryPath = [ NSString stringWithFormat:@"%@/%@",documentsDirectory, name];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if (![filemanager fileExistsAtPath:directoryPath]) {
        [filemanager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path =  [ NSString stringWithFormat:@"%@/%@/%@.%@",documentsDirectory, name,mp3name,suffix];
    
    return path;
}

//重复提交的验证
-(BOOL)checkResumbit:(NSString *)currUrl{
    
    //如果接口需要验证重复提交
    if ([[self urlWithNeedCheck] containsObject:currUrl]) {
        
        //如果上一次访问的接口和当前接口相同，则重复提交
        if([self.lastUrls containsObject:currUrl]){
            
            return NO;
        }else{
            //当前接口不是重复提交，
            [self.lastUrls addObject:currUrl] ;
            //一秒后重置
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.lastUrls removeAllObjects];
            });
            
            return YES;
        }
    }
    return YES;
}

//需要验证重复提交的接口
-(NSArray *)urlWithNeedCheck{
    
    NSArray *urlArr = @[CHAT_MESSAGE_SEND_MESSAGE,V_ADDVERIFICATIONCODE];
    return urlArr;
    
}

+(void)clearCookies{
    //清除登录接口的cookies
    NSArray *loginUrls = @[V_USER_LOGIN];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"cookie"];
    for (NSString *url in loginUrls) {
        
        //获取所有cookies
        NSArray*array = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",NET_MAIN_URL,url]]];
        //删除
        for(NSHTTPCookie*cookie in array)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie: cookie];
        }
    }
}

+(void)ManageLocalFileWithFileName:(NSString *)filename
{
    NSString * itemKey = [NSString stringWithFormat:@"File_Down_date_%@",filename];
    NSDate * date = [[NSUserDefaults standardUserDefaults] objectForKey:itemKey];
    if (date&&[date timeIntervalSinceNow]<-6*3600*24) {
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *path =  [ NSString stringWithFormat:@"%@/%@",documentsDirectory, filename];
        NSFileManager *filemanager = [NSFileManager defaultManager];
        @try {
            [filemanager removeItemAtPath:path error:nil];
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:itemKey];
    }else if(date==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:itemKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveCookie:(NSHTTPURLResponse*)response{
    
    NSDictionary *allHeaderFieldsDic = response.allHeaderFields;
    NSString *setCookie = allHeaderFieldsDic[@"Set-Cookie"];
    if (setCookie != nil) {
        NSString *cookie = [[setCookie componentsSeparatedByString:@";"] objectAtIndex:0];
        // 这里对cookie进行存储
        [[NSUserDefaults standardUserDefaults] setObject:cookie forKey:@"cookie"];
    }else{
        // 登录失败
    }
}

-(NSString *)loginCookieStrFromLocal{
    
    // 如果已有Cookie, 则把你的cookie符上
    NSString *cookie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    return cookie;
}


@end

