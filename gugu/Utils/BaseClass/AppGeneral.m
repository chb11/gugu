//
//  QianHe.m
//  Factoring
//
//  Created by douyinbao on 15/7/30.
//  Copyright (c) 2015年 douyinbao. All rights reserved.
//

#import "AppGeneral.h"
#import <QuartzCore/CALayer.h>
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>

#import "AppTabBarVC.h"


static AppGeneral * SINGLETON = nil;
@interface AppGeneral()<UITabBarControllerDelegate>
{
    NSInteger _selectIndex;
}
@end

@implementation AppGeneral

+ (AppGeneral*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    return SINGLETON;
}

-(NSMutableParagraphStyle*)paragraphStyle
{
    if (!_paragraphStyle) {
        _paragraphStyle =  [[NSMutableParagraphStyle alloc] init];
    }
    return _paragraphStyle;
}

//算出高度
+(CGFloat )sizeHeight:(NSString *)text wordFont:(UIFont * )font width:(CGFloat)width{
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    CGSize   size = rect.size;
    CGFloat heigt=size.height;
    return heigt;
}



//算出高度
+(CGFloat )sizeAutoline:(NSString *)text wordFont:(UIFont * )font width:(CGFloat)width linsSpace:(CGFloat)space {
    [APPGENERAL.paragraphStyle setLineSpacing:space];
    NSDictionary *attributes = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:APPGENERAL.paragraphStyle};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    CGSize   size = rect.size;
    CGFloat heigt=size.height;
    return heigt;
}

+(NSMutableAttributedString *)attributeString:(id )text andSapce:(CGFloat)space textFont:(UIFont *)font
{
    NSMutableAttributedString * attributedString1 =nil;
    if (text==nil) {
        text = @"";
    }
    if ([text isKindOfClass:[NSMutableAttributedString class]]) {
        attributedString1 =[[NSMutableAttributedString alloc] initWithAttributedString:text];
    }else {
        attributedString1 = [[NSMutableAttributedString alloc] initWithString:text];
    }
    [APPGENERAL.paragraphStyle setLineSpacing:space];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:APPGENERAL.paragraphStyle range:NSMakeRange(0, [text length])];
    [attributedString1 addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [text length])];
    if ([attributedString1 isKindOfClass:[NSMutableAttributedString class]]) {
        return attributedString1;
    }else {
        return  [[NSMutableAttributedString alloc] initWithAttributedString:text];
    }
    return attributedString1;
}

+(NSMutableAttributedString *)attributeString:(id )text andSapce:(CGFloat)space
{
    NSMutableAttributedString * attributedString1 =nil;
    if ([text isKindOfClass:[NSMutableAttributedString class]]) {
        attributedString1 =[[NSMutableAttributedString alloc] initWithAttributedString:text];
    }else {
        attributedString1 = [[NSMutableAttributedString alloc] initWithString:text];
        
    }
    [APPGENERAL.paragraphStyle setLineSpacing:space];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:APPGENERAL.paragraphStyle range:NSMakeRange(0, [text length])];
    return attributedString1;
}

//算出文字长度
+ (NSUInteger) lenghtWithString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    
    return len + numMatch;
}

//校验手机号码
+(BOOL)isValidPhone:(NSString *) number
{
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(19[0-9])|(13[0-9])|(17[0-9])|(14[0-9]))\\d{8}$"] evaluateWithObject:[NSString stringWithFormat:@"%@",number]];
}

+ (BOOL)isValidAllNum:(NSString *)inputString {
    if (inputString.length == 0) return NO;
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}

//验证是否为字母和数字
+ (BOOL)inputShouldLetterOrNum:(NSString *)inputString {
    BOOL result = false;
    if ([inputString length] >= 1){
        // 判断长度1-20位后再接着判断是否同时包含数字和字符
        NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{1,20}$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:inputString];
    }
    return result;
}


+(BOOL)isDigitAndCharacter:(NSString *)inputStr{
    NSString *regex = @"^[a-zA-Z0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:inputStr];
    return isMatch;
}

+(BOOL)isValidWallet:(NSString *)acconut
{
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(17[0-9])|(14[0-9]))\\d{8}$"] evaluateWithObject:[NSString stringWithFormat:@"%@",acconut]]||[[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$"] evaluateWithObject:[NSString stringWithFormat:@"%@",acconut]];
}

+(BOOL)isEffectiveFloat:(NSString *)text
{
    NSString *iphone=@"^\\d{0,7}\\.{0,1}\\d{0,2}$";
    NSPredicate *iphonePredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",iphone];
    return [iphonePredicate evaluateWithObject:text];
}

//校验密码
+ (BOOL)isValidPassWord:(NSString *)password{
//    NSString *pWord=@"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
//    NSPredicate *passwordPredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",pWord];
//    return [passwordPredicate evaluateWithObject:password];
    NSString *pWord=@"[\u4e00-\u9fa5]";
    NSPredicate *passwordPredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",pWord];
    BOOL ismatch = [passwordPredicate evaluateWithObject:password];
    if (ismatch) {//中文字符
        return NO;
    }else{
        if (password.length>=6 && password.length<=16) {
            return YES;
        }
    }
    return NO;
}

+(BOOL)isValidVerificationCocde:(NSString *)text
{
    NSString *pWord=@"^[@0-9]{6,20}$";
    NSPredicate *passwordPredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",pWord];
    return [passwordPredicate evaluateWithObject:text];
}


+(NSString *)getCurrentDate
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSString * stringFrat =@"yyyy-MM-dd";
    [inputFormatter setDateFormat:stringFrat];
    NSString * shakeCount=[NSString stringWithFormat:@"%@_%@",@"HH",[inputFormatter stringFromDate:[NSDate date]]];
    return shakeCount;
}

+(NSString *)getAccurateCurrentDate
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSString * stringFrat =@"yyyy-MM-dd HH:mm:ss";
    [inputFormatter setDateFormat:stringFrat];
    NSString * shakeCount=[NSString stringWithFormat:@"%@",[inputFormatter stringFromDate:[NSDate date]]];
    return shakeCount;
}



+ (NSArray * )getMsgJsonString:(NSString *)string
{
    __block NSMutableArray *fields = [[NSMutableArray alloc] init];
    NSError *error = NULL;
    
    
    NSRegularExpression *fieldRegularExpression = [NSRegularExpression
                                                   regularExpressionWithPattern:@"\\{\[\\S\\s]*?\\}"
                                                   options:  NSRegularExpressionAnchorsMatchLines
                                                   error:&error];
    [fieldRegularExpression enumerateMatchesInString:string options:0 range:NSMakeRange(0, [string length])
                                          usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                                              if(match.range.length > 2) {
                                                  NSRange range = NSMakeRange(match.range.location , match.range.length );  //Remove '[' and ']'
                                                  [fields insertObject:[string substringWithRange:range] atIndex:fields.count];
                                              }
                                          }];
    return fields;
    
}



+(void)clearLoactionVoice
{
    
    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/downloadFile.caf"];
    NSString *amrPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/downloadFile.amr"];
    NSString *mp3Path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/downloadFile.mp3"];
    NSString *wav =[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/downloadFile.wav"];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:amrPath error:nil])
    {
    }
    
    if([fileManager removeItemAtPath:cafFilePath error:nil])
    {
    }
    
    if([fileManager removeItemAtPath:mp3Path error:nil])
    {
    }
    if([fileManager removeItemAtPath:wav error:nil])
    {
    }
}

+(CGFloat)textWidth:(NSString *)title andTitleFont:(UIFont *)font
{
    CGSize titleSize = [title sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
    return titleSize.width;
}


//与当前时间比较返回NSInteger（s）
+(NSInteger)dateReductionofdate:(NSString *)time{
    //字符串转化成时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:time];
    //当前时间转换成规范时间模式
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate  *date2 = [dateFormatter dateFromString :currentDateStr ];
    NSTimeInterval secondsInterval= [date timeIntervalSinceDate:date2];
    return secondsInterval;
}

+(NSString *)timeAgo:(NSString *)newsDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLog(@"newsDate = %@",newsDate);
    NSDate *newsDateFormatted = [dateFormatter dateFromString:newsDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    NSDate* current_date = [[NSDate alloc] init];
    NSTimeInterval time=[current_date timeIntervalSinceDate:newsDateFormatted];
    //间隔的秒数
    int year =((int)time)/(3600*24*30*12);
    int month=((int)time)/(3600*24*30);
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minute=((int)time)%(3600*24)/60;
    NSLog(@"time=%f",(double)time);
    NSString *dateContent;
    if (year!=0) {
        dateContent = newsDate;
        
    }else if(month!=0){
        dateContent = [NSString stringWithFormat:@"%i%@",month,@"个月前"];
        
    }else if(days!=0){
        dateContent = [NSString stringWithFormat:@"%i%@",days,@"天前"];
        
    }else if(hours!=0){
        dateContent = [NSString stringWithFormat:@"%i%@",hours,@"小时前"];
        
    }else {
        dateContent = [NSString stringWithFormat:@"%i%@",minute,@"分钟前"];
        
    }
    return dateContent;

}


+(NSString *)timePublish:(NSString *)strDate
{
    NSDate *now = [NSDate date];
    strDate = [strDate stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *myDate = [dateFormatter dateFromString:strDate];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    
    double deltaSeconds = fabs([myDate timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    
//    if(deltaSeconds < 60)
//    {
//        return @"刚刚";
//    }
    
//    else if(deltaSeconds < 120)
//    {
//        return @"1分钟前";
//    }
//    else if (deltaMinutes < 60)
//    {
//        return [NSString stringWithFormat:@"%d分钟前",(int)deltaMinutes];
//    }
    
    
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm";
    } else {
        
        if (nowCmps.day==myCmps.day) {
            if (nowCmps.month!=myCmps.month) {
                dateFmt.dateFormat = @"MM-dd HH:mm";
            }else {
                dateFmt.dateFormat = @"HH:mm";
            }
        } else if((nowCmps.day-myCmps.day)==1) {
            if (nowCmps.month!=myCmps.month) {
                dateFmt.dateFormat = @"MM-dd HH:mm";
            }else {
                dateFmt.dateFormat = @"MM-dd HH:mm";
            }
        } else {
            dateFmt.dateFormat = @"MM-dd HH:mm";
        }
    }
    return [dateFmt stringFromDate:myDate];
}




+(NSString *)timeWxChatAgo:(NSString *)strDate
{
    NSDate *now = [NSDate date];
    strDate = [strDate stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *myDate = [dateFormatter dateFromString:strDate];
    
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:myDate];
    
    NSDateFormatter *dateFmt = [[ NSDateFormatter alloc ] init ];
    
    double deltaSeconds = fabs([myDate timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    
    
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy年MM月";
    } else {
        
        if (nowCmps.day==myCmps.day) {
            if (nowCmps.month!=myCmps.month) {
                dateFmt.dateFormat = @"MM月dd日";
            }else {
                dateFmt.dateFormat = @"HH:mm";
            }
        } else if((nowCmps.day-myCmps.day)==1) {
            if (nowCmps.month!=myCmps.month) {
                dateFmt.dateFormat = @"MM月dd日";
            }else {
                dateFmt.dateFormat = @"昨天";
            }
        } else {
            dateFmt.dateFormat = @"MM月dd日";
        }
    }
    return [dateFmt stringFromDate:myDate];
}



+(void)showMessage:(NSString *)message andDealy:(double)delay
{
    if (message.length==0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView * mbView = [[UIApplication sharedApplication].keyWindow viewWithTag:2000];
        [mbView removeFromSuperview];
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = message;
        hud.labelFont = [UIFont systemFontOfSize:15];
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        hud.mode = MBProgressHUDModeText;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES afterDelay:delay];
            });
        });
    });
}



+(NSString *)getPerSonAge:(NSString *)bitthdayStr
{
    if (bitthdayStr.length==0) {
        return @"未知";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    if ([bitthdayStr containsString:@" "]) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
     NSDate *myDate = [dateFormatter dateFromString:bitthdayStr];
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSYearCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:myDate toDate:nowDate options:0];
    NSInteger year = [comps year];
    year+=1;
    if (year<0) {
        year = 0;
    }
    return [NSString stringWithFormat:@"%ld",year];
}

+(NSArray *)arrayTags:(NSString *)tags
{
    if (tags.length) {
        NSArray * array =  [tags componentsSeparatedByString:@","];
        return array;
    }
    return nil;
}




+ (NSString*)dictionaryToJson:(id )dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

+ (BOOL)stringContainsEmoji:(NSString *)string{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

+(void)resetButton:(UIButton *)button
{
    button.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.enabled = YES;
    });
}



+(BOOL)isBadTime
{
    NSString* string = @"2018-04-16 00:00:00";
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* endDate = [inputFormatter dateFromString:string];
    NSInteger _intervatTime = [endDate timeIntervalSinceDate:[NSDate date]];
    if (_intervatTime>0) {
        return  YES;
    }
    return NO;
}






//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVCFrom:(UIView *)view;
{
    //获取当前view的superView对应的控制器
    UIResponder *next = [view nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}


//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
//获取当前屏幕中present出来的viewcontrolle
+ (UIViewController *)getPresentedViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    return topVC;
}

+(NSString *)getSafeValueWith:(id)value{
    if (value == nil || value == [NSNull null]){
        return @"";
    }else if ([value isKindOfClass:[NSNumber class]]){
        return  [value stringValue];
    }
    return [NSString stringWithFormat:@"%@",value];
}

-(NSString *)getSafeValueWith:(id)value{
    if (value == nil || value == [NSNull null]){
        return @"";
    }else if ([value isKindOfClass:[NSNumber class]]){
        return  [value stringValue];
    }
    return [NSString stringWithFormat:@"%@",value];
}

+ (void)setUpShadowForView:(UIView *)view inFrame:(CGRect)frame From:(UIColor *)fromColor to:(UIColor *)endColor{
    
    //初始化CAGradientlayer对象，使它的大小为UIView的大小
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;

    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
    [view.layer addSublayer:gradientLayer];
    
    //设置渐变区域的起始和终止位置（范围为0-1）
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 1);
    
    //设置颜色数组
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor,
                             (__bridge id)endColor.CGColor];
    //设置颜色分割点（范围：0-1）
//    gradientLayer.locations = @[@(0.3f),@(0.5f),@(0.8f)];
    
}

+(NSString *)showDateFromDateString:(NSString *)stringDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *myDate = [dateFormatter dateFromString:stringDate];
    NSDateFormatter *toFormat = [[NSDateFormatter alloc] init];
    toFormat.locale = [NSLocale currentLocale];
    toFormat.dateFormat = @"MM月dd日";
    return [toFormat stringFromDate:myDate];
}

+(NSString *)timeToMinute:(NSString *)stringDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *myDate = [dateFormatter dateFromString:stringDate];
    
    NSDateFormatter *toFormat = [[NSDateFormatter alloc] init];
    toFormat.locale = [NSLocale currentLocale];
    toFormat.dateFormat = @"MM-dd HH:mm";
    return [toFormat stringFromDate:myDate];
}

+(NSString *)showTimeForemeconds:(int)seconds{
    
//    if (seconds<60) {
//
//        if (sec) {
//            <#statements#>
//        }
//        return [NSString stringWithFormat:@"%d",seconds];
//    }
    
    int min = seconds/60;
    int sec = seconds - min * 60;
    
    NSString *minStr =@"00";
    if (min<10) {
        minStr = [NSString stringWithFormat:@"0%d",min];
    }else{
        minStr = [NSString stringWithFormat:@"%d",min];
    }
    NSString *secStr = @"00";
    if (sec<10) {
        secStr = [NSString stringWithFormat:@"0%d",sec];
    }else{
        secStr = [NSString stringWithFormat:@"%d",sec];
    }
    
    return [NSString stringWithFormat:@"%@:%@",minStr,secStr];
}

+(BOOL)compareDate:(NSString *)date1 andDate:(NSString *)date2{
    NSDateFormatter *inputFormatter1 = [[NSDateFormatter alloc] init];
    [inputFormatter1 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if (date1.length==10) {
        [inputFormatter1 setDateFormat:@"yyyy-MM-dd"];
    }else if (date1.length==16) {
        [inputFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
    }else{
        [inputFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate *d1= [inputFormatter1 dateFromString:date1];
    
    
    NSDateFormatter *inputFormatter2 = [[NSDateFormatter alloc] init];
    [inputFormatter2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if (date2.length==10) {
        [inputFormatter2 setDateFormat:@"yyyy-MM-dd"];
    }else if (date2.length==16) {
        [inputFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm"];
    }else{
        [inputFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate *d2= [inputFormatter2 dateFromString:date2];
    
    if (d1.timeIntervalSince1970>d2.timeIntervalSince1970) {
        return YES;
    }
    
    return NO;
}

+(NSInteger)CountTimebetownDate:(NSString *)date1 andDate:(NSString *)date2{
    NSDateFormatter *inputFormatter1 = [[NSDateFormatter alloc] init];
    [inputFormatter1 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if (date1.length==10) {
        [inputFormatter1 setDateFormat:@"yyyy-MM-dd"];
    }else if (date1.length==16) {
        [inputFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm"];
    }else{
        [inputFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate *d1= [inputFormatter1 dateFromString:date1];
    
    
    NSDateFormatter *inputFormatter2 = [[NSDateFormatter alloc] init];
    [inputFormatter2 setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    if (date2.length==10) {
        [inputFormatter2 setDateFormat:@"yyyy-MM-dd"];
    }else if (date2.length==16) {
        [inputFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm"];
    }else{
        [inputFormatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate *d2= [inputFormatter2 dateFromString:date2];
    NSTimeInterval timeCount =  d1.timeIntervalSince1970-d2.timeIntervalSince1970;
    return @(fabs(timeCount)).integerValue;
}

+(CGRect)getRectWithImage:(UIImage *)image andBottomPadding:(CGFloat)padding
{
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-padding);
    CGRect aspectRect = AVMakeRectWithAspectRatioInsideRect(image.size, frame);
    return aspectRect;
}

+ (BOOL)getIsIpad

{
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    
    
    if([deviceType isEqualToString:@"iPhone"]) {
        
        //iPhone
        
        return NO;
        
    }
    
    else if([deviceType isEqualToString:@"iPod touch"]) {
        
        //iPod Touch
        
        return NO;
        
    }
    
    else if([deviceType isEqualToString:@"iPad"]) {
        
        //iPad
        
        return YES;
        
    }
    
    return NO;
    
}

+(void)backToActiveMainTab
{
    AppDelegate * delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([delegate.window.rootViewController isKindOfClass:[AppTabBarVC class]]) {
        AppTabBarVC * customer =(AppTabBarVC*)delegate.window.rootViewController;
        UINavigationController * nav=  (UINavigationController *)customer.selectedViewController;
        [nav popToRootViewControllerAnimated:NO];
        [customer changeIndex:0];
    }
}

+(NSString *)getShowNumFromNum:(NSInteger)num{
    if (num>=10000) {
        return [NSString stringWithFormat:@"%.2fW",num*0.0001];
    }else if(num <= 0){
        return @"0";
    }
    return [NSString stringWithFormat:@"%ld",num];
}

-(NSString *)tocken{
    if (_tocken == nil||[_tocken isEqualToString:@"(null)"]) {
        return @"";
    }
    return _tocken;
}

+ (NSTimeInterval)pleaseInsertStarTime:(NSString *)starTime andInsertEndTime:(NSString *)endTime{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//根据自己的需求定义格式
    NSDate* startDate = [formater dateFromString:starTime];
    NSDate* endDate = [formater dateFromString:endTime];
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time;
}

+(BOOL)cacluteVoiceSize
{
    float totalSize = 0;
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *directname = @"chat_voice";
    NSString *directoryPath = [ NSString stringWithFormat:@"%@/%@",documentsDirectory, directname];
    
    NSString *cafFilePath = directoryPath;
    
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:cafFilePath error:nil];
    unsigned long long length = [attrs fileSize];
    totalSize += length / 1024.0 / 1024.0;
    if (totalSize * 1024<=5) {
        return NO;
    }
    return YES;
}

+(void)clearLoactionSignalVoice
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:VoiceSingNalPath error:nil])
    {
    }
}


+(void)detailPushInfo
{
    NSString *  pushInfo = APPGENERAL.pushStr;
    AppDelegate * delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([delegate.window.rootViewController isKindOfClass:[AppTabBarVC class]]) {
        AppTabBarVC * customer =(AppTabBarVC*)delegate.window.rootViewController;
        UINavigationController * nav=  (UINavigationController *)customer.selectedViewController;
        NSString * classNowName = NSStringFromClass([nav.visibleViewController class]);
        NSDictionary * dic = [AppGeneral dictionaryWithJsonString:pushInfo];
        NSString * className = dic[@"classname"];
        NSString * linkurl = dic[@"linkurl"];
        NSString * paraName = dic[@"paraname"];
        id  paraValue = dic[@"value"];
        if(linkurl&&linkurl.length){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkurl]];
        }else if (className&&className.length) {
             if(NSClassFromString(className)) {
//                BaseViewController * vc = [[NSClassFromString(className) alloc]init];
//                vc.hidesBottomBarWhenPushed = YES;
//                if ([classNowName isEqualToString:className]) {
//                    if ([[vc valueForKey:paraName] isEqualToString:paraValue]) {
//                        return;
//                    }
//                }
//                @try {
//                    if (paraName&&paraValue) {
//                        [vc setValue:paraValue  forKey:paraName];
//                    }
//                } @catch (NSException *exception) {
//
//                } @finally {
//                    [nav  pushViewController:vc animated:YES];
//                }
            }
        }
    }
}

+(void)action_showLaheiWithController:(UIViewController *)control{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"拉黑后将不再看到该用户的相关作品，且无法撤销，确定要拉黑么？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [AppGeneral showMessage:@"已拉黑该用户" andDealy:1];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:cancel];
        [alert addAction:confirm];
        [control presentViewController:alert animated:YES completion:nil];
    });
}

/**
 *  获取矩形的渐变色的UIImage(此函数还不够完善)
 *
 *  @param bounds       UIImage的bounds
 *  @param colors       渐变色数组，可以设置两种颜色
 *  @param gradientType 渐变的方式：0--->从上到下   1--->从左到右
 *
 *  @return 渐变色的UIImage
 */
+(UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors andGradientType:(int)gradientType{
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, bounds.size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(bounds.size.width, 0.0);
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

+(BOOL)isContainsTwoEmoji:(NSString *)string
{
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         //         NSLog(@"hs++++++++%04x",hs);
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f)
                 {
                     isEomji = YES;
                 }
                 //                 NSLog(@"uc++++++++%04x",uc);
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3|| ls ==0xfe0f) {
                 isEomji = YES;
             }
             //             NSLog(@"ls++++++++%04x",ls);
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
         
     }];
    return isEomji;
}

+(void)action_showAlertWithTitle:(NSString *)title andConfirmBlock:(void(^)(void))block{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
    }];
    
    [alert addAction:cancel];
    [alert addAction:confirm];
    [[AppGeneral getPresentedViewController] presentViewController:alert animated:YES completion:nil];
}


+(NSString *)tempMp3UrlWithTime{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat=@"yyyyMMddHHmmss";
    NSString *str=[formatter stringFromDate:[NSDate date]];
    NSString *fileName=[NSString stringWithFormat:@"head_%@.mp3",str];
    NSString *directname = @"chat_voice";
    NSString *directoryPath = [ NSString stringWithFormat:@"%@/%@",documentsDirectory, directname];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if (![filemanager fileExistsAtPath:directoryPath]) {
        [filemanager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",documentsDirectory,directname,fileName];
    
    return path;
}

+(void)clearCacheofVoice{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *directname = @"chat_voice";
    NSString *directoryPath = [ NSString stringWithFormat:@"%@/%@",documentsDirectory, directname];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:directoryPath]) {
        [filemanager removeItemAtPath:directoryPath error:nil];
    }
}

+(NSString *)bianmaWithurl:(NSString *)url{
    NSString *charactersToEscape = @"?!@#$^&%*+,:-;='\"`<>()[]{}/\\| ";//此处不做更改，
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodeStr = [url stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodeStr;
}
+(NSString *)jiemawithString:(NSString *)str{
    NSString *deCodeStr = str.stringByRemovingPercentEncoding;
    return deCodeStr;
}

+(NSString *)getNowTimeTimestamp3{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
}

+(NSString *)hourStringWithSeconds:(NSInteger)totalSeconds{
    
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    NSString *hourStr = @"";
    if (hours == 0) {
        
    }else if (hours>0 &&hours<10) {
        hourStr = [NSString stringWithFormat:@"0%ld小时",hours];
    }else{
        hourStr = [NSString stringWithFormat:@"%ld小时",hours];
    }
    
    NSString *minStr = @"";
    if (minutes == 0) {
        
    }else if (minutes>0 &&minutes<10) {
        minStr = [NSString stringWithFormat:@"0%ld分",minutes];
    }else{
        minStr = [NSString stringWithFormat:@"%ld分",minutes];
    }
    
    return [NSString stringWithFormat:@"%@%@",hourStr, minStr];
}

+(void)action_updateBarItemBadgeWith:(NSInteger)count{
    AppDelegate * delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([delegate.window.rootViewController isKindOfClass:[AppTabBarVC class]]) {
        AppTabBarVC * customer =(AppTabBarVC*)delegate.window.rootViewController;
        UITabBarItem *item = customer.tabBar.items[0];
        if (count>0) {
            item.badgeValue = [NSString stringWithFormat:@"%ld",(long)count];
        }else{
            item.badgeValue = nil;
        }
    }
}


+ (NSString *)randomUuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}
@end
