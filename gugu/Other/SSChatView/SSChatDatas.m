//
//  SSChatDatas.m
//  SSChatView
//
//  Created by soldoros on 2018/9/25.
//  Copyright © 2018年 soldoros. All rights reserved.
//


#import "SSChatDatas.h"


#define headerImg1  @"http://www.120ask.com/static/upload/clinic/article/org/201311/201311061651418413.jpg"
#define headerImg2  @"http://www.qqzhi.com/uploadpic/2014-09-14/004638238.jpg"
#define headerImg3  @"http://e.hiphotos.baidu.com/image/pic/item/5ab5c9ea15ce36d3b104443639f33a87e950b1b0.jpg"

@implementation SSChatDatas

//获取单聊的初始会话 数据均该由服务器处理生成 这里demo写死
+(NSMutableArray *)LoadingMessagesStartWithChat:(NSString *)sessionId{
    
    return nil;
}

//获取群聊的初始会话
+(NSMutableArray *)LoadingMessagesStartWithGroupChat:(NSString *)sessionId{
    
    return nil;
}

//处理接收的消息数组
+(NSMutableArray *)receiveMessages:(NSArray *)messages{
    NSMutableArray *array = [NSMutableArray new];
    for(NSDictionary *dic in messages){
        SSChatMessagelLayout *layout = [SSChatDatas getMessageWithDic:dic];
        [array addObject:layout];
    }
    return array;
}

//接受一条消息
+(SSChatMessagelLayout *)receiveMessage:(NSDictionary *)dic{
    return [SSChatDatas getMessageWithDic:dic];
}

//消息内容生成消息模型
+(SSChatMessagelLayout *)getMessageWithDic:(NSDictionary *)dic{
    
    SSChatMessage *message = [SSChatMessage new];
    CB_MessageModel *model = [CB_MessageModel modelWithDictionary:dic];
    
    message.model = model;
    SSChatMessageType messageType = model.MessageType;
    if (model.MessageType ==11) {
        messageType = 0;
    }
    
    SSChatMessageFrom messageFrom = [model.SendUserId isEqualToString:[UserModel shareInstance].Guid]?SSChatMessageFromMe:SSChatMessageFromOther;
    if(messageFrom == SSChatMessageFromMe){
        message.messageFrom = SSChatMessageFromMe;
        message.backImgString = @"icon_qipao1";
        message.headerImgurl = [UserModel shareInstance].HeadPhotoURL;
    }else{
        message.messageFrom = SSChatMessageFromOther;
        message.backImgString = @"icon_qipao2";
        message.headerImgurl = model.GuUserHeadURL;
    }
    
    message.sessionId    = model.SendId;
    message.sendError    = NO;

    message.messageId    = model.Guid?model.Guid:model.SendId;
    message.textColor    = SSChatTextColor;
    message.messageType  = messageType;
    message.showTime = YES;
    
    //判断时间是否展示
    message.messageTime = [AppGeneral timePublish:model.PostDate];
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    if(!message.sessionId || [user valueForKey:message.sessionId]==nil){
//        [user setValue:model.PostDate forKey:message.sessionId];
//        message.showTime = YES;
//    }else{
//        [message showTimeWithLastShowTime:[user valueForKey:message.sessionId] currentTime:[AppGeneral getAccurateCurrentDate]];
//        if(message.showTime){
//            [user setValue:model.PostDate forKey:message.sessionId];
//        }
//    }

    //判断消息类型
    if(message.messageType == SSChatMessageTypeText){
        message.cellString   = SSChatTextCellId;
        
        if (model.MessageType == SSChatMessageTypeCard) {//名片
            CB_UserCardModel *cardmodel = [CB_UserCardModel modelWithJSON:model.Message];
            NSString *string= [NSString stringWithFormat:@"%@的[名片]\n%@",cardmodel.UserName,cardmodel.Phone];
            message.textString = string;
        }else{
            message.textString = model.Message;
        }
    }else if (message.messageType == SSChatMessageTypeImage){
        message.cellString   = SSChatImageCellId;
        if (model.image) {
            
            message.image = model.image;
        }else{
            NSString *imgURL = model.FileUrlURL;
            UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgURL];
            if (cachedImage) {
                message.image = cachedImage;
            }
        }

//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.FileUrlURL]];
//        UIImage *image = [UIImage imageWithData:data];
//        UIImage *finalImage =image?image:model.image;
//        message.image = finalImage?finalImage:[UIImage imageNamed:@"tupianposun.png"];

    }else if (message.messageType == SSChatMessageTypeVoice){
        
        message.cellString   = SSChatVoiceCellId;
        message.voice = model.voicrData;
        message.voiceRemotePath = model.FileUrlURL;
    
        message.voiceDuration = @(model.Duration/1000).integerValue;
        message.voiceTime = [NSString stringWithFormat:@"%d's",@(model.Duration/1000).intValue];

        message.voiceImg = [UIImage imageNamed:@"chat_animation_white3"];
        message.voiceImgs =
        @[[UIImage imageNamed:@"chat_animation_white1"],
          [UIImage imageNamed:@"chat_animation_white2"],
          [UIImage imageNamed:@"chat_animation_white3"]];
        
        if(messageFrom == SSChatMessageFromOther){

            message.voiceImg = [UIImage imageNamed:@"chat_animation3"];
            message.voiceImgs =
            @[[UIImage imageNamed:@"chat_animation1"],
              [UIImage imageNamed:@"chat_animation2"],
              [UIImage imageNamed:@"chat_animation3"]];
        }
        
    }else if (message.messageType == SSChatMessageTypeMap){
        message.cellString = SSChatMapCellId;
        
        NSString *mapJson = model.Message;
        
        NSArray *mapStrArr = [mapJson componentsSeparatedByString:@","];
        NSString *latStr = [mapStrArr[0] componentsSeparatedByString:@"="].lastObject;
        NSString *longStr = [mapStrArr[1] componentsSeparatedByString:@"="].lastObject;
        NSString *addressStr = mapStrArr[2];
        
        message.latitude = [latStr doubleValue];
        message.longitude = [longStr doubleValue];
        message.addressString = addressStr;
        
    }else if (message.messageType == SSChatMessageTypeVideo){
        message.cellString = SSChatVideoCellId;
        message.videoLocalPath = dic[@"videoLocalPath"];
        message.videoImage = [UIImage getImage:message.videoLocalPath];
    }
    
    SSChatMessagelLayout *layout = [[SSChatMessagelLayout alloc]initWithMessage:message];
    return layout;
}

//发送一条消息
+(void)sendMessage:(NSDictionary *)dict withImage:(UIImage *)image sessionId:(NSString *)sessionId messageType:(SSChatMessageType)messageType messageBlock:(MessageBlock)messageBlock{
   
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithDictionary:dict];
    [messageDic setValue:[UserModel shareInstance].Guid forKey:@"Guid"];
    [messageDic setValue:[UserModel shareInstance].Guid forKey:@"SendUserId"];
    [messageDic setValue:[UserModel shareInstance].HeadPhoto forKey:@"SendUserUrl"];

    NSString *time = [AppGeneral getAccurateCurrentDate];
    NSString *messageId = [time stringByReplacingOccurrencesOfString:@" " withString:@""];
    messageId = [messageId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    messageId = [messageId stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    [messageDic setObject:@"0" forKey:@"from"];
    [messageDic setValue:time forKey:@"PostDate"];
    [messageDic setValue:@(messageType) forKey:@"MessageType"];
    [messageDic setValue:messageId forKey:@"Guid"];
    
    if (image) {
        [messageDic setObject:image forKey:@"image"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SSChatMessagelLayout *layout = [SSChatDatas getMessageWithDic:messageDic];
        messageBlock(layout,nil,nil);
    });
    
}


@end
