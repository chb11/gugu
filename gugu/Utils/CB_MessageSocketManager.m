//
//  CB_MessageSocketManager.m
//  gugu
//
//  Created by Mike Chen on 2019/5/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_MessageSocketManager.h"
#import <AudioToolbox/AudioToolbox.h>

static CB_MessageSocketManager *_instance = nil;

@interface CB_MessageSocketManager ()<SRWebSocketDelegate>

@property (nonatomic,strong) SRWebSocket *socket;

@property (nonatomic,assign) BOOL isManaClose;

@end

@implementation CB_MessageSocketManager

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CB_MessageSocketManager alloc] init];
        [_instance.socket open];
    });
    return _instance;
}

-(void)action_startSocket{
    self.isManaClose = NO;
    if (self.socket.readyState == SR_CLOSED||
        self.socket.readyState == SR_CLOSING) {
        [self reconnect];
    }
}

-(void)action_stopSocket{
    self.isManaClose = YES;
    if (self.socket.readyState != SR_CLOSED||
        self.socket.readyState != SR_CLOSING) {
        [self.socket close];
    }
    
}

#pragma mark - websocket 代理

-(SRWebSocket *)socket{
    if (!_socket) {
        NSString *socketUrl = CHAT_MESSAGE_JOIN_ROOMS;
        NSString *url = [NSString stringWithFormat:@"%@%@?OnlineUserId=%@",NET_SOCKET_URL,socketUrl,[UserModel shareInstance].OnlineId];
        _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        _socket.delegate = self;
    }
    return _socket;
}

-(void)reconnect{
    self.socket.delegate = nil;
    self.socket = nil;
    [self.socket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"打开socket");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
    NSDictionary *msgDict = @{};
    if ([message isKindOfClass:[NSDictionary class]]) {
        NSLog(@"");
        msgDict = message;
    }else if ([message isKindOfClass:[NSString class]]){
        msgDict = [AppGeneral dictionaryWithJsonString:message];
    }
    if (msgDict.allKeys.count ==0) {
        return;
    }
    NSMutableDictionary *m_msgDict = msgDict.mutableCopy;
    
    if([m_msgDict.allKeys containsObject:@"Guid"]){
        NSString *guid = m_msgDict[@"Guid"];
        [self.socket send:guid];
        
    }
    
    SSChatMessageType type = [msgDict[@"MessageType"] integerValue];
    if (type == SSChatMessageTypeVoice) {
        NSString *voicePath = msgDict[@"Message"];
        [m_msgDict setValue:voicePath forKey:@"FileUrl"];
    }
    if (type == SSChatMessageTypeImage) {
        NSString *voicePath = msgDict[@"Message"];
        [m_msgDict setValue:voicePath forKey:@"FileUrl"];
    }
    
    CB_MessageModel *msgModel = [CB_MessageModel modelWithDictionary:m_msgDict];
     //实时共享
    if (msgModel.MessageType == SSChatMessageTypeShareLocation) {
        NSLog(@"用户实时共享位置 %@",msgDict);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_POSITION_ONTIME object:msgModel];
        
        return;
    }
    
    //用户更新位置
    if (msgModel.MessageType == SSChatMessageTypeUserPosition) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_POSITION_RECEIVED object:msgModel];
        NSLog(@"用户更新位置 %@",msgDict);
        return;
    }
    [self playNotifySound];
    [CB_MessageManager action_saveAction:msgModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SOCKET_MESSAGE_RECEIVED object:msgModel];
    NSLog(@"收到消息 %@",msgDict);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string{
    NSLog(@"接收到消息%@",string);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data{
    NSLog(@"接收到消息%@",data);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"失败%@",error);
    [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean{
    NSLog(@"(连接断开)%@",reason);
    if (!self.isManaClose) {
        [self reconnect];
    }
}

- (void)playNotifySound {
    
    NSString *lastTime = [[NSUserDefaults standardUserDefaults] valueForKey:@"last_play_time"];
    NSInteger timeCount = [AppGeneral CountTimebetownDate:lastTime andDate:[AppGeneral getAccurateCurrentDate]];
    if (lastTime) {
        if (timeCount<2) {
            return;
        }
    }
    
    
    [[NSUserDefaults standardUserDefaults] setValue:[AppGeneral getAccurateCurrentDate] forKey:@"last_play_time"];
    
    //获取路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"gugu" ofType:@"mp3"];
    //定义一个带振动的SystemSoundID
    SystemSoundID soundID = 1007;
    //判断路径是否存在
    if (path) {
        //创建一个音频文件的播放系统声音服务器
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([NSURL fileURLWithPath:path]), &soundID);
        //判断是否有错误
        if (error != kAudioServicesNoError) {
            NSLog(@"%d",(int)error);
        }
    }
    //只播放声音，没振动
    AudioServicesPlaySystemSound(soundID);
}


@end
