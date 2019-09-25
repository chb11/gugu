//
//  ProcessBrowserViewController.h
//     
//
//  Created by BingQiLin on 14-6-4.
//
//

#import "DDPhotoPageViewController.h"
@class PhotoAlbumView;
@interface DDNavBrowserViewController : DDPhotoPageViewController
@property (strong, nonatomic) NSString *strTitle;
@property (strong, nonatomic) NSMutableArray *muArrayData;
+(void)showBrowserView:(UIViewController *)ctrl PhotoView:(PhotoAlbumView *)appendView arrayImg:(NSMutableArray *)arrayImg currentPage:(NSInteger)currentpage;

@end
