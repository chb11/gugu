//
//  QianHe.h
//  Factoring
//
//  Created by douyinbao on 15/7/30.
//  Copyright (c) 2015年 douyinbao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define BASEHEIGHT 20
#define APPGENERAL [AppGeneral sharedInstance]

@interface AppGeneral : NSObject

@property (strong, nonatomic) NSMutableParagraphStyle * paragraphStyle;
@property (strong, nonatomic) NSMutableDictionary * dicCatory;
@property (assign, nonatomic) NSInteger buyHouseCoin;
@property (strong, nonatomic) NSDictionary * dicSecury;
@property (strong, nonatomic) NSString *tocken;
@property (nonatomic, strong) NSString *pushStr;
@property (assign, nonatomic) BOOL isBanned;

+ (AppGeneral*)sharedInstance;
+(CGFloat )sizeAutoline:(NSString *)text wordFont:(UIFont * )font width:(CGFloat)width linsSpace:(CGFloat)space;

+(CGFloat )sizeHeight:(NSString *)text wordFont:(UIFont * )font width:(CGFloat)width;

+(CGFloat)textWidth:(NSString *)title andTitleFont:(UIFont *)font;

+(NSMutableAttributedString *)attributeString:(id )text andSapce:(CGFloat)space;
+(NSMutableAttributedString *)attributeString:(id )text andSapce:(CGFloat)space textFont:(UIFont *)font;


+(void)showEmergency:(NSDictionary *)dic;

//算出文字长度
+ (NSUInteger) lenghtWithString:(NSString *)string;
//校验手机号码
+(BOOL)isValidPhone:(NSString *) number;

+(NSString *)timeWxChatAgo:(NSString *)strDate;
//判断是否为纯数字
+(BOOL)isValidAllNum:(NSString *)inputString;

//验证是否为字母和数字
+ (BOOL)inputShouldLetterOrNum:(NSString *)inputString;

+(BOOL)isDigitAndCharacter:(NSString *)inputStr;

//校验密码
+ (BOOL)isValidPassWord:(NSString *)text;
//校验验证码
+(BOOL)isValidVerificationCocde:(NSString *)text;

//与当前时间比较返回NSInteger（s）
+(NSInteger)dateReductionofdate:(NSString *)time;

+(NSString *)timeAgo:(NSString *)strDate;

+(BOOL)isBadTime;

+(void)showMessage:(NSString *)message andDealy:(double)delay;

-(BOOL)isHavePhone;
//计算年龄
+(NSString *)getPerSonAge:(NSString *)bitthdayStr;
//登录
+(BOOL)isValidWallet:(NSString *)acconut;

+ (NSString*)dictionaryToJson:(id )dic;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+(NSString *)getBase64ShareType:(NSString *)type;

+(BOOL)stringContainsEmoji:(NSString *)string;

+(void)resetButton:(UIButton *)button;

+(NSString *)getCurrentDate;

+(NSString *)getYesterday;

+(NSString *)domainName;

+(void)detailPushInfo;
+(void)clearLoactionVoice;

+(void)clearLoactionSignalVoice;

+(BOOL)isAuditVersion;

+(NSString *)getCleartext:(NSString *)text;

+ (NSArray * )getMsgJsonString:(NSString *)string;

+(NSString *)getAccurateCurrentDate;

//获取当前view所在的viewcontroller
+ (UIViewController *)getCurrentVCFrom:(UIView *)view;
//获取当前显示的view controller
+ (UIViewController *)getCurrentVC;
//获取当前屏幕中present出来的viewcontrolle
+ (UIViewController *)getPresentedViewController;
+ (void)setUpShadowForView:(UIView *)view inFrame:(CGRect)frame From:(UIColor *)fromColor to:(UIColor *)endColor;
/**
 判断传入的参数类型，返回字符串类型
 */
+(NSString *)getSafeValueWith:(id)value;
-(NSString *)getSafeValueWith:(id)value;
//返回日期 08 12月
+(NSString *)showDateFromDateString:(NSString *)dateStr;

+(NSString *)getCurrentTime;
//返回 00:00 格式
+(NSString *)showTimeForemeconds:(int)seconds;
//比较date1 是否比 date2  大
+(BOOL)compareDate:(NSString *)date1 andDate:(NSString *)date2;
+(NSInteger)CountTimebetownDate:(NSString *)date1 andDate:(NSString *)date2;
+(CGRect)getRectWithImage:(UIImage *)image andBottomPadding:(CGFloat)padding;
//计算时间差
+ (NSTimeInterval)pleaseInsertStarTime:(NSString *)starTime andInsertEndTime:(NSString *)endTime;
+(NSString *)timePublish:(NSString *)strDate;
// 返回 03-12 11:20 格式
+(NSString *)timeToMinute:(NSString *)stringDate;
//判断是否为ipad
+ (BOOL)getIsIpad;

+(NSString *)getShowNumFromNum:(NSInteger)num;
+(NSString *)getkGDTMobSDKAppId;
+(BOOL)cacluteVoiceSize;

+(void)action_showLaheiWithController:(UIViewController *)control;

+(UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors andGradientType:(int)gradientType;

+(BOOL)isContainsTwoEmoji:(NSString *)string;

+(void)action_showAlertWithTitle:(NSString *)title andConfirmBlock:(void(^)(void))block;

+(NSString *)tempMp3UrlWithTime;
+(void)clearCacheofVoice;

+(NSString *)bianmaWithurl:(NSString *)url;
+(NSString *)jiemawithString:(NSString *)str;
+(void)backToActiveMainTab;

+(NSString *)getNowTimeTimestamp3;

+(NSString *)hourStringWithSeconds:(NSInteger)seconds;
+(void)action_updateBarItemBadgeWith:(NSInteger)count;

+ (NSString *)randomUuidString;

@end
