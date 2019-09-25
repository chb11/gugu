//
//  PageViewController.m
//  PageApp
//
//  Created by BingQiLin 14-6-3.
//

#import "DDPhotoPageViewController.h"
#import "DDPhotoViewController.h"
#import "DDPhotoNotification.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DDPhotoPageViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (strong, nonatomic) NSArray *pageContent;
@end

@implementation DDPhotoPageViewController

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
        NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey: UIPageViewControllerOptionSpineLocationKey];
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    }
    self.view.layer.contents = nil;
    [self beginObservations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImageUrls:(NSArray*)urls
{
    self.pageContent = [[NSArray alloc] initWithArray:urls];
    [self createContentPages];
}

// 初始化pageController
- (void) createContentPages {
    
    _pageViewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _pageViewController.view.backgroundColor = [UIColor clearColor];
    
    DDPhotoViewController *initialViewController = [self viewControllerAtIndex:_currentPage];
    initialViewController.pageIndex = _currentPage;
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
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
    } else if ([[self.pageContent objectAtIndex:index] isKindOfClass:[UIImage class]]){
        [dataViewController setImage:[self.pageContent objectAtIndex:index]];
    }
    return dataViewController;
}

// 根据数组元素值，得到下标值
- (NSUInteger)indexOfViewController:(DDPhotoViewController *)viewController {
    return viewController.pageIndex;
    if (viewController.url&&![viewController.url isEqualToString:@""]) {
        return [self.pageContent indexOfObject:viewController.url];
    } else if (viewController.asset) {
        return [self.pageContent indexOfObject:viewController.asset];
    } else if (viewController.image) {
        return [self.pageContent indexOfObject:viewController.image];
    }
    return 0;
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DDPhotoViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法，自动来维护次序。
    // 不用我们去操心每个ViewController的顺序问题。
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DDPhotoViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [self.pageContent count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewController
{
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
    DDPhotoViewController *photoViewController = pageViewController.viewControllers[0];
    self.currentPage = [self indexOfViewController:photoViewController];
    [self pageControllerWillTransitionToViewControllers:_currentPage];
}

//换一页
- (void)pageControllerWillTransitionToViewControllers:(NSInteger)index
{
    
}

#pragma mark - Notification and Key Value observing

- (void)beginObservations
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecognizeSingleTapWithNotification:)
                                                 name:EBPhotoViewSingleTapNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRecognizeDoubleTapWithNotification:)
                                                 name:EBPhotoViewDoubleTapNotification
                                               object:nil];
   

}

- (void)stopObservations
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didRecognizeSingleTapWithNotification:(NSNotification *)notification
{
    
}

- (void)didRecognizeDoubleTapWithNotification:(NSNotification *)notification
{
    
}

-(void)didRecognizeLongTapWithNotification:(NSNotification *)notification
{
    
}

- (void)dealloc
{
    [self stopObservations];
    _pageViewController = nil;
    self.pageContent = nil;
}
@end
