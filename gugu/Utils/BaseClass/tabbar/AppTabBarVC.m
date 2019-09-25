//
//  AppTabBarVC.m
//  XiaXuan
//
//  Created by JonyHan on 14/12/8.
//  Copyright (c) 2014年 JonyHan. All rights reserved.
//

#import "AppTabBarVC.h"
#import "BaseViewController.h"
#import "GuguViewController.h"



@interface AppTabBarVC ()<UITabBarDelegate,UITabBarControllerDelegate>
{
    BOOL isFirst;
    NSInteger  _selectIndex;
}

@end

@implementation AppTabBarVC
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self createBestUserControllers];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0],NSForegroundColorAttributeName : TEXT_NORMAL_COLOR} forState:UIControlStateNormal];//TabBarItem未选中时的字体大小
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0],NSForegroundColorAttributeName : TEXT_HEIGHT_COLOR} forState:UIControlStateSelected];//TabBarItem未选中时的字体大小
    self.selectedIndex =0;
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance]setBackgroundImage:[UIImage new]];
    [[UITabBar appearance] setTranslucent:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUnReadMessag) name:@"UnReadMsg" object:nil];

}

- (void)createBestUserControllers{
    //用plist中的信息
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppTabBarList" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    //存放视图控制器的对象
    NSMutableArray *controlllers = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        NSString *className = [dic objectForKey:@"controllerName"];
        Class class = NSClassFromString(className);
        UIViewController *root = [[class alloc] init];

        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:root];
        [controlllers addObject:navController];

        NSString *selectImage=dic[@"imageSelect"];
        UIImage* selectedImage = [[UIImage imageNamed:selectImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [root.tabBarItem setSelectedImage:selectedImage];
        NSString *imageName = [dic objectForKey:@"imageName"];
        [root.tabBarItem setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [root.tabBarItem setTitle:dic[@"title"]];
        
    }
    self.viewControllers = controlllers;
}


- (BOOL)shouldAutorotate
{
    return YES;
}

-(void)changeIndex:(NSInteger)selectIndex{
    self.selectedIndex = selectIndex;

}


-(void)onUnReadMessag
{
    
}


-(void)aciton_jumpPackage{
    
}

-(void)aciton_jumpFate{
    __weak typeof(self) weakSelf = self;
    
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        NSArray * array = @[];
        NSDictionary * dicVC =@{};
        NSString * willPushClass = NSStringFromClass([nav.childViewControllers[0] class]);
        _selectIndex = [dicVC[willPushClass] integerValue];
        NSInteger oldSelectIndex = tabBarController.selectedIndex;
        if (_selectIndex!=oldSelectIndex) {
            if (_selectIndex==0) {
                
            }
            if (_selectIndex==1) {
                
            }
            if (_selectIndex==2) {
                
            }
            if (_selectIndex==3) {
                
            }
            
        }
        if ([array containsObject:willPushClass]) {
            
//            return NO;
        }
        
    }
   
    return YES;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_MESSAGE_RECEIVED object:nil];
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


@end
