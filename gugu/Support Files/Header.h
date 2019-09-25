

#ifndef Header_h
#define Header_h

#pragma mark 设备宽高


#pragma mark APP基本信息pay
//版本号
#define APP_CURRENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
//App名
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]

#define APP_BUNDLE_ID [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

#define LOGIN_THIRD_PLATFORM @"LOGIN_THIRD_PLATFORM"

#define WeakSelf(o)  __weak typeof(o) o##Weak = o;

#define APP_STORE_URL [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",APP_STORE_ID]

#define App_Comment_URL [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",APP_STORE_ID]

#define FONT(font) [UIFont systemFontOfSize:(font)]

#define D_LocalizedCardString(s) [[NSBundle mainBundle] localizedStringForKey:s value:nil table:@"CardToolLanguage"]


//友盟
#define APP_UM_KEY @""
#define APP_WX_KEY @""
#define APP_WX_SECERT @""


//颜色(r,g,b)
#define G_ColorRGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

#pragma mark 常用方法
#define FontBold(fontsize) [UIFont fontWithName:@"Helvetica-Bold" size:fontsize]

#define FONTDETAIL(font) [UIFont fontWithName:@"AppleGothic" size:(font)]
#define IMGLINK(a,b) [NSString stringWithFormat:@"%@%@",a,b]
#define VoiceSingNalPath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/downloadFileSignal.caf"]

#pragma mark 本地存储关键字
//关键之标识
#define SENSITIVE_WORDS_CONTENT @"SENSITIVE_WORDS_CONTENT"
//当前登录用户标识
#define LOGIN_NAME @"LOGIN_NAME"
#define LOGIN_PSW @"LOGIN_PSW_QIANHE"
#define LOGIN_STATE @"LOGIN_STATE"
#define LOGIN_USERMODEL @"LOGIN_USERMODEL"

//是否是第三方登录
#define IS_LOGIN_THIRD @"IS_LOGIN_THIRD"
//首页默认图 (yuyinbaol_kong)
#define HOME_DEFAULT_IMAGE [UIImage imageNamed:@"yuyinbaol_kong"]
//默认头像
#define HOME_DEFAULT_HEADER_IMAGE [UIImage imageNamed:@"default_user_header"]

#pragma mark 枚举定义
typedef void(^VipClicked) (void);
typedef void(^SuccesFinishCallBack) (id obj);
typedef void(^SenderClicked) (NSInteger tag);
typedef void(^DisMissCallBack) (void);
typedef void(^FinishAction) (void);
typedef void(^AppendClickedBlock) (id obj);
typedef void(^AppendVideoBlock) (id obj,NSDictionary * dicResult);
typedef void(^CommentPersonClicked) (id obj,id userID,id cell);
typedef void(^ReplyUserClicked) (id obj);
typedef void (^cutedImage)(id  obj);

typedef enum {
    RootTabStytle=0,//tabBar 做为根控制器
    RootLogStytle,//登录页作为跟控制器
    RootLockLogStytle,//手势密码也作为跟控制器
    RootLocateStytle
}RootCtrlStytle;

typedef enum : NSUInteger {
    CB_ROUTE_TYPE_DEIVE=0,//驾车
    CB_ROUTE_TYPE_RIDE,//骑行
    CB_ROUTE_TYPE_WALK,//步行
    CB_ROUTE_TYPE_BUS,//公交
} CB_ROUTE_TYPE;

#endif /* Header_h */
