//
//  AppDelegate.m
//  gugu
//
//  Created by Mike Chen on 2019/2/28.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "AppDelegate.h"
#import "AppTabBarVC.h"
#import <Bugly/Bugly.h>

#import "ContractNewFriendsController.h"

@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    AppTabBarVC *vc = [[AppTabBarVC alloc] init];
    self.window.rootViewController = vc;
    self.window.backgroundColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self configNotification];
    [self checkLogin];
    [self configMap];
    [[CB_MessageSocketManager shareInstance] action_startSocket];
    [self initJpush];
    
    [JPUSHService setupWithOption:launchOptions appKey:@"1efdb65d6549b200cf095fc2"
                          channel:@"App Store"
                 apsForProduction:NO
            advertisingIdentifier:nil];
    
    [Bugly startWithAppId:@"3f06baafc9"];
    
    [self action_sendDeviceToServer];
    
    return YES;
}

-(void)initJpush{
    //Required
    //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义 categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
}

-(void)configMap{
    [AMapServices sharedServices].apiKey = @"8bc929809a2fc1ba041fb7ba3ecb7d1c";
}

-(void)configNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_needlogin) name:NOTIFICATION_NEED_LOGIN object:nil];
    
}

-(void)checkLogin{
    [CB_LoginViewController LogInStateCheckWithCtrl:self.window.rootViewController LogInSucess:^(BOOL isLogIN) {
        
    }];
}

-(void)action_configControllers{
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GO_TO_BG object:nil];
    [[CB_MessageSocketManager shareInstance] action_stopSocket];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHECK_SOCKET_STATE object:nil];
    [self action_sendDeviceToServer];
    [[CB_MessageSocketManager shareInstance] action_startSocket];
    [application setApplicationIconBadgeNumber:0]; //清除角标
    [[UIApplication sharedApplication] cancelAllLocalNotifications];//清除APP所有通知消息
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRtegisterDelegate

// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    NSInteger pushType = [userInfo[@"pushType"] integerValue];
    //聊天
    if (pushType == 0) {
        NSString *msgModelJson = userInfo[@"ExtraMessage"];
        CB_MessageModel *model = [CB_MessageModel modelWithJSON:msgModelJson];
        [self action_jumpChatWithMsgModel:model];
    }
    //新朋友列表
    if (pushType == 100) {
        [self action_go_newFriend];
    }
    //新版本更新
    if (pushType == 150) {
        
    }

    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required, For systems with less than or equal to iOS 6
    [JPUSHService handleRemoteNotification:userInfo];
}


-(void)action_needlogin{
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USERMODEL];
    if (userDict) {
        UserModel *mm = [UserModel modelWithDictionary:userDict];
        [[NetWorkConnect manager] postDataWith:@{} withUrl:V_GETPUBLICKEY withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                NSString *publicKey = responseObject[@"PublicKey"];
                NSString *pwd =  [[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_PSW];
                NSDictionary *para = @{@"UserName":mm.Phone,@"Password":[pwd RSAEncrypt:publicKey]};
                [[NetWorkConnect manager] postDataWith:para withUrl:V_USER_LOGIN withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
                    if (resultCode == 1) {
                        UserModel *mdel = [UserModel modelWithDictionary:responseObject];
                        [[UserModel shareInstance] reloadModelWith:mdel];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:LOGIN_USERMODEL];
                        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:LOGIN_STATE];
                        
                    }
                }];
            }
        }];
    }else{
        [self checkLogin];
    }
}

-(void)action_sendDeviceToServer{
    
    if ([JPUSHService registrationID].length>1) {
        NSDictionary *para = @{@"Guid":[JPUSHService registrationID],
                               @"Version":APP_CURRENT_VERSION,
                               @"PackageName":@"com.caigetuxun.app.gugu",
                               @"Device":@"iOS",
                               @"Os":@"iOS",
                               };
        
        [[NetWorkConnect manager] postDataWith:para withUrl:OTHER_REGISTERINSTALLDEVICES withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            
        }];
    }

}

-(void)action_jumpChatWithMsgModel:(CB_MessageModel *)model{
    
    SSChatController *page = [SSChatController new];
    page.chatType = SSChatConversationTypeChat;
    page.sessionId = model.SendId;
    page.SendId = model.SendId;
    page.model = model;
    page.titleString = [model.GroupName isEqualToString:@""]?model.SendName:model.GroupName;
    page.hidesBottomBarWhenPushed = YES;
    
    [AppGeneral backToActiveMainTab];
    AppTabBarVC * customer =(AppTabBarVC*)self.window.rootViewController;
    UINavigationController * nav=  (UINavigationController *)customer.selectedViewController;

    [nav pushViewController:page animated:YES];
}

-(void)action_go_newFriend{
    [AppGeneral backToActiveMainTab];
    AppTabBarVC * customer =(AppTabBarVC*)self.window.rootViewController;
    [customer changeIndex:1];
    ContractNewFriendsController *page = [ContractNewFriendsController new];
    page.hidesBottomBarWhenPushed = YES;
    UINavigationController * nav=  (UINavigationController *)customer.selectedViewController;
    [nav pushViewController:nav animated:YES];
}

@end
