//
//  DDPageCtrlViewController.h
//  LoveSports
//
//  Created by BingQiLin 14-6-4.
//
//

#import "DDPhotoPageViewController.h"
#import "DDPhotoNotification.h"


@interface DDPageCtrlViewController : DDPhotoPageViewController

@property (strong, nonatomic) NSMutableArray *muArrayData;//图片链接数组
@property (strong, nonatomic) UIImage  *ori_image;
@property (strong, nonatomic) UIImageView *ori_imageView;
@property(nonatomic, strong) UILabel * labelCurrent;



- (UIPageViewController *)pageViewController;

//图片放大浏览
+ (id)showDDPagePhotoWithController:(UIViewController *)ctrl
                            DataArray:(NSMutableArray *)datas
                         Ori_frames:(NSMutableArray *)ori_frames
                       CurrentIndex:(int)currentIndex;

+ (id)showDDPagePhotoWithController:(UIViewController *)ctrl
                          DataArray:(NSMutableArray *)datas
                         Ori_frames:(NSMutableArray *)ori_frames
                         Ori_images:(NSMutableArray *)ori_images
                       CurrentIndex:(int)currentIndex;

- (NSString *)ori_frame;
@end
