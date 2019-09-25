//
//  ProcessBrowserViewController.m
//
//
//  Created by BingQiLin on 14-6-4.
//
//

#import "DDNavBrowserViewController.h"
#import "NavgationBarView.h"
#import "AlbumImages.h"
#import "PhotoAlbumView.h"
@interface DDNavBrowserViewController ()<UIActionSheetDelegate>
{
    UIView * _viewNav;
}
@property(nonatomic, strong) UILabel * labelCurrent;
@property (nonatomic, weak) PhotoAlbumView * weakPhoto;

@end

@implementation DDNavBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.muArrayData = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.muArrayData = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    NSMutableArray * imgArray = [NSMutableArray array];
    for (id  objChild in self.muArrayData) {
        if ([objChild isKindOfClass:[AlbumImages class]]) {
            [imgArray addObject:((AlbumImages*)objChild).imageDetailPath];
        }else if([objChild isKindOfClass:[NSDictionary class]]){
            NSDictionary * dic = (NSDictionary *)objChild;
            [imgArray addObject:[dic objectForKey: KEYIMAGE]];
        }else if([objChild isKindOfClass:[UIImage class]]){
            [imgArray addObject:objChild];
        }
    }
    [self setImageUrls:imgArray];
    [self setViews];
    [self changeTitle];
}

-(void)setViews
{
    _viewNav  = [[UIView  alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    UIImageView * imgView =[[UIImageView alloc]initWithFrame:_viewNav.bounds];
    imgView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.618];
    [_viewNav addSubview:imgView];
    //显示文本
    _labelCurrent = [[UILabel alloc]initWithFrame:CGRectMake(0,20, SCREEN_WIDTH, 44)];
    _labelCurrent.textAlignment = NSTextAlignmentCenter;
    _labelCurrent.textColor = [UIColor whiteColor];
    _labelCurrent.font = FONT(14);
    [_viewNav addSubview:_labelCurrent];
    //返回键
    UIButton * buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonLeft.frame = CGRectMake(0, 20, 50, 44);
    [buttonLeft setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
    //删除按钮
    UIButton * buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonRight.frame = CGRectMake(SCREEN_WIDTH-65, 20, 50, 44);
    [buttonRight setImage:[UIImage imageNamed:@"delete_img"] forState:UIControlStateNormal];
    [_viewNav addSubview:buttonRight];
    [_viewNav addSubview:buttonLeft];
    [self.view addSubview:_viewNav];
    [buttonRight addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonLeft addTarget:self action:@selector(btnBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view bringSubviewToFront:_viewNav];
}

-(void)btnDeleteClicked:(UIButton *)button
{
    if (self.muArrayData.count>self.currentPage) {
        id  obj  = self.muArrayData[self.currentPage];
        [_weakPhoto removeObjWithIndex:self.currentPage];
        [self.muArrayData removeObject:obj];
        if (self.muArrayData.count==0) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            return;
        }
        
        self.currentPage = self.currentPage > (self.muArrayData.count-1)?(self.muArrayData.count-1):self.currentPage;
        NSMutableArray * imgArray = [NSMutableArray array];
        for (id  objChild in self.muArrayData) {
            if ([objChild isKindOfClass:[AlbumImages class]]) {
                [imgArray addObject:((AlbumImages*)objChild).imageDetailPath];
            } else if ([objChild isKindOfClass:[NSDictionary class]]){
                NSDictionary * dic = (NSDictionary *)objChild;
                [imgArray addObject:[dic objectForKey: KEYIMAGE]];
            }else if ([objChild isKindOfClass:[UIImage class]]){
                [imgArray addObject:obj];
            }
        }
        [self setImageUrls:imgArray];
        [self changeTitle];
        [self.view bringSubviewToFront:_viewNav];
    } else {
        [_weakPhoto removeObjWithIndex:0];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

}

-(void)btnBackClicked:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)changeTitle
{
    if (self.muArrayData.count>self.currentPage) {
    _labelCurrent.text = [NSString stringWithFormat:@"%ld/%ld",self.currentPage+1,self.muArrayData.count];
        _labelCurrent.hidden = self.muArrayData.count==1;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 导航栏背景图
//更新标题时间及图片内容
- (void)changePictureTextAndNavigationTitleWithPageIndex:(NSNumber *)page
{
    
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;//隐藏为YES，显示为NO
}

#pragma mark -
- (void)pageControllerWillTransitionToViewControllers:(NSInteger)index
{
    [self changeTitle];
}

- (void)didRecognizeSingleTapWithNotification:(NSNotification *)notification
{
    [self showViewNav];
}


-(void)showViewNav
{
    CGRect frame = _viewNav.frame;
    if (_viewNav.frame.origin.y<=-64) {
        frame.origin.y = 0;
    }else {
       frame.origin.y = -64;
    }
    
    [UIView animateWithDuration:0.23 animations:^{
        _viewNav.frame = frame;
    }];
    
}

- (void)didRecognizeDoubleTapWithNotification:(NSNotification *)notification
{
    
}



+(void)showBrowserView:(UIViewController *)ctrl PhotoView:(PhotoAlbumView *)appendView arrayImg:(NSMutableArray *)arrayImg currentPage:(NSInteger)currentpage
{
    DDNavBrowserViewController * browserCtr = [[DDNavBrowserViewController alloc]init];
    browserCtr.currentPage = currentpage;
    browserCtr.weakPhoto = appendView;
    browserCtr.muArrayData = arrayImg;
    browserCtr.tabBarController.tabBar.hidden = YES;
    browserCtr.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [ctrl presentViewController:browserCtr animated:YES completion:^{
        
    }];
    
    
}

@end
