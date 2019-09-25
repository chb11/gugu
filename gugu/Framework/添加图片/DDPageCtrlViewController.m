//
//  DDPageCtrlViewController.m
//  LoveSports
//
//  Created by BingQiLin 14-6-4.
//
//


#import "DDPageCtrlViewController.h"
#import "DDPhotoViewController.h"
#import "UIImageView+WebCache.h"
#import "DDPhotoView.h"
#import "DDPhotoPageViewController.h"
#import "UIImage+FX.h"

@interface DDPageCtrlViewController ()<UIActionSheetDelegate>
{
    UIPageControl *pageControl;
}
@property (strong, nonatomic) NSArray *pageContent;
@property (strong, nonatomic) NSArray *originFrames;
@property (strong, nonatomic) UIImage  *imageSave;
@property (strong, nonatomic) NSArray *originImages;


@end

@implementation DDPageCtrlViewController

+ (id)showDDPagePhotoWithController:(UIViewController *)ctrl
                          DataArray:(NSMutableArray *)datas
                         Ori_frames:(NSMutableArray *)ori_frames
                         Ori_images:(NSMutableArray *)ori_images
                       CurrentIndex:(int)currentIndex
{
    DDPageCtrlViewController *pageController = [[DDPageCtrlViewController alloc] init];
    pageController.muArrayData = datas;
    pageController.originFrames = [NSArray arrayWithArray:ori_frames];
    pageController.originImages = ori_images;
    pageController.currentPage = currentIndex;
    [ctrl.navigationController.view addSubview:pageController.view];
//    [ctrl presentModalViewController:pageController animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:ctrl
                                             selector:@selector(didRecognizeSingleTapWithNotification:)
                                                 name:EBPhotoViewSingleTapNotification
                                               object:nil];
    return pageController;
}

+ (id)showDDPagePhotoWithController:(UIViewController *)ctrl
                            DataArray:(NSMutableArray *)datas
                            Ori_frames:(NSMutableArray *)ori_frames
                       CurrentIndex:(int)currentIndex
{
    return [self showDDPagePhotoWithController:ctrl DataArray:datas Ori_frames:ori_frames Ori_images:nil CurrentIndex:currentIndex];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.muArrayData = nil;
    self.ori_image = nil;
    self.ori_imageView = nil;
    pageControl = nil;
    self.pageContent = nil;
    self.originFrames = nil;
    self.originImages = nil;
    self.imageSave = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    //图片链接数组
    [self setImageUrls:self.muArrayData];
	[self createPageControl];
}

//初始化UIPageControl
- (void)createPageControl
{
    if (!_labelCurrent) {
        _labelCurrent = [[UILabel alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT-64, SCREEN_WIDTH, 44)];
        _labelCurrent.textAlignment = NSTextAlignmentCenter;
        _labelCurrent.textColor = [UIColor whiteColor];
        _labelCurrent.font = FONT(14);
        [self.view addSubview:_labelCurrent];
        _labelCurrent.alpha = 0;

//        pageControl = [[UIPageControl alloc]init];
//        [self.view addSubview:pageControl];
    }
    
       _labelCurrent.text = [NSString stringWithFormat:@"%ld/%ld",self.currentPage+1,self.pageContent.count];

//    
//    pageControl.frame = CGRectMake(20, self.view.bounds.size.height-20, self.view.bounds.size.width - 40, 10);
//    pageControl.hidden = !(self.pageContent.count > 1);
//    [pageControl setNumberOfPages:[_pageContent count]];
//    
//    [pageControl setCurrentPage:self.currentPage];
}

// 初始化pageController
- (void) createContentPages {
    _pageViewController.view.frame = self.view.bounds;
    _pageViewController.view.alpha = 0;
    _pageViewController.view.backgroundColor = [UIColor clearColor];
    DDPhotoViewController *initialViewController = [self viewControllerAtIndex:self.currentPage];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];

    _ori_imageView = [[UIImageView alloc] initWithFrame:CGRectFromString(_originFrames[self.currentPage])];
    _ori_imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
    CGRect to_show_bounds = self.view.bounds;
    if (_originImages.count&&_originImages[self.currentPage]) {
        UIImage *origin_image = _originImages[self.currentPage];
        CGSize imageSize = [[origin_image imageCroppedAndScaledToSize:self.view.bounds.size contentMode:UIViewContentModeScaleAspectFit padToFit:NO] size];
        to_show_bounds = CGRectMake((self.view.bounds.size.width-imageSize.width)/2, (self.view.bounds.size.height-imageSize.height)/2, imageSize.width, imageSize.height);
        _ori_imageView.image = _originImages[self.currentPage];
    } else {
        [_ori_imageView sd_setImageWithURL:[NSURL URLWithString:self.pageContent[self.currentPage]] placeholderImage:[UIImage imageNamed:DEFAULT_BG_IMAGE]];
    }
    
    [self.view addSubview:_ori_imageView];
    [UIView animateWithDuration:0.6 animations:^{
        _pageViewController.view.backgroundColor = [UIColor blackColor];
        _ori_imageView.frame = to_show_bounds;
    } completion:^(BOOL finished) {
        _pageViewController.view.alpha = 1;
        _ori_imageView.alpha = 0;
        _labelCurrent.alpha = 1;
    }];
}

// 得到相应的VC对象
- (DDPhotoViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageContent count] == 0) || (index >= [self.pageContent count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    DDPhotoViewController *dataViewController =[[DDPhotoViewController alloc] init];
    dataViewController.pageIndex = index;
    if ([[self.pageContent objectAtIndex:index] isKindOfClass:[NSString class]]) {
        [dataViewController setImageWithUrl:[self.pageContent objectAtIndex:index]];
    } else if ([[self.pageContent objectAtIndex:index] isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = [self.pageContent objectAtIndex:index];
        [dataViewController setAlssetImage:asset];
    } else {
        [dataViewController setImage:[self.pageContent objectAtIndex:index]];
    }
    return dataViewController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIPageViewController *)pageViewController
{
    return _pageViewController;
}

#pragma mark - Rotation Handling

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self createPageControl];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsLayout];
}


#pragma mark -
- (void)pageControllerWillTransitionToViewControllers:(NSInteger)index
{
    [pageControl setCurrentPage:index];
    _labelCurrent.text = [NSString stringWithFormat:@"%ld/%ld",index+1,self.pageContent.count];

    if (_originImages.count&&_originImages[index]) {
        UIImage *origin_image = _originImages[self.currentPage];
        CGSize imageSize = [[origin_image imageCroppedAndScaledToSize:self.view.bounds.size contentMode:UIViewContentModeScaleAspectFit padToFit:NO] size];
        CGRect to_show_bounds = CGRectMake((self.view.bounds.size.width-imageSize.width)/2, (self.view.bounds.size.height-imageSize.height)/2, imageSize.width, imageSize.height);
        _ori_imageView.image = _originImages[index];
        _ori_imageView.frame = to_show_bounds;
    } else {
        [_ori_imageView sd_setImageWithURL:self.pageContent[index]];
    }
   
    
}

#pragma mark -

- (NSString *)ori_frame
{
    return _originFrames[self.currentPage];
}

- (void)didRecognizeSingleTapWithNotification:(NSNotification *)notification
{

}


@end
