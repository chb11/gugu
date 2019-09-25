//
//  PageViewController.h
//  PageApp
//
//  Created by BingQiLin 14-6-3.
//

#import "BaseViewController.h"

@interface DDPhotoPageViewController : BaseViewController
{
    UIPageViewController *_pageViewController;
}
@property (assign, nonatomic) NSUInteger currentPage;
//设置图片地址数组
- (void)setImageUrls:(NSArray*)urls;

- (void)createContentPages;

//添加通知
- (void)beginObservations;

//换一页
- (void)pageControllerWillTransitionToViewControllers:(NSInteger)index;
@end
