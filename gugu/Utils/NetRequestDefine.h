//


#ifndef Fatoring_NetRequestDefine_h
#define Fatoring_NetRequestDefine_h

#pragma mark 请求设置

#define TimerOut 30.0
#define TimingTime 91

#pragma mark 域名地址
//*********************线上内网开关 1：线上 0 内网********************
#define IS_ONLINE 0

#define NET_MAIN_URL IS_ONLINE==1?@"http://gugu.holdone.cn":@"http://gugu.holdone.cn"
#define NET_SOCKET_URL IS_ONLINE==1?@"ws://gugu.holdone.cn":@"ws://gugu.holdone.cn"



#pragma mark - 用户模块
//获取公钥
#define V_GETPUBLICKEY @"/Verification/getPublicKey.json"
//登录
#define V_USER_LOGIN @"/Client/User/login.json"
//退出登录
#define V_USER_LOGOUT @"/Client/User/logout.json"
//验证当前用户登录状态
#define V_USER_CURRENTUSER @"/Client/User/currentUser.json"
//发送验证码
#define V_ADDVERIFICATIONCODE @"/Verification/addVerificationCode.json"
//注册
#define V_USER_REGISTER @"/Client/User/register.json"
//验证手机号，昵称，邮箱是否已被占用（返回值已更改）
#define V_USER_ISUNIQUE @"/Client/User/isUnique.json"
//找回密码
#define V_USER_FINDPASSWORD @"/Client/User/findPassword.json"
//手机号是否已被占用
#define V_USER_ISREGISTEROTHERPHONE @"/Client/User/isregisterOtherPhone.json"
//更改绑定手机号码
#define V_USER_EDITPHONE @"/Client/User/editPhone.json"
//更换用户名
#define V_USER_EDITUSERNAME @"/Client/User/editUserName.json"
//更换头像
#define V_USER_UPLOADHEADPHOTO @"/Client/User/uploadHeadPhoto.json"
//查询搜索用户
#define V_USER_LISTBYPAGE @"/Client/User/listByPage.json"
//咕咕号是否唯一
#define V_USER_GUGU_ONLY @"/Client/User/gugu_only.json"
//更改咕咕号码
#define V_USER_EDITGUNUM @"/Client/User/editGuNum.json"
//更改登录密码
#define V_USER_CHANGEPWD @"/Client/User/changePwd.json"



#pragma mark - 通讯录
//添加好友(原因最多512)
#define CHAT_FRIEND_ADD_FRIEND @"/chat/friend/add_friend.json"
//是否为我的好友
#define CHAT_FRIEND_IS_MY_FRIEND @"/chat/friend/is_my_friend.json"
//我的申请好友列表
#define CHAT_FRIEND_MY_APPLY_FRIEND @"/chat/friend/my_apply_friend.json"
//接收或者拒绝好友0拒绝，1默认，2通过
#define CHAT_FRIEND_RECEIVE @"/chat/friend/receive.json"
//我的好友
#define CHAT_FRIEND_ALL_FRIEND @"/chat/friend/my_all_friend.json"
//修改好友备注
#define CHAT_FRIEND_EDIT_FRIEND @"/chat/friend/edit_friend.json"
//删除好友
#define CHAT_FRIEND_DELETE_FRIEND @"/chat/friend/delete_friend.json"
//用户信息
#define CHAT_FRIEND_USER_FRIEND @"/chat/friend/user_friend.json"

#pragma mark - 我的群
//创建群组
#define CHAT_GROUP_CREAT_GROUP @"/chat/group/creat_group.json"
//加入群组
#define CHAT_GROUP_JOIN_GROUP @"/chat/group/join_group.json"
//修改群资料
#define CHAT_GROUP_EDIT_GROUP @"/chat/group/edit_group.json"
//删除群
#define CHAT_GROUP_DELETE_GROUP @"/chat/group/delete_group.json"
//修改我的讨论组备注
#define CHAT_GROUP_EDIT_NICKNAME @"/chat/group/edit_group_self_name.json"
//退出讨论组（退出活动XXX）
#define CHAT_GROUP_EQUIT_GROUP @"/chat/group/quit_group.json"
//我的所有群
#define CHAT_GROUP_ALL_GROUP @"/chat/group/my_all_group.json"
//查询群信息
#define CHAT_GROUP_SHOW_GROUP @"/chat/group/show_group.json"
//查询群成员（查询群成员位置）
#define CHAT_GROUP_SEARCHMENBER @"/chat/group/search_group_user.json"

#pragma mark - 聊天
// 加入聊天室 （ws） 参数OnlineUserId
#define CHAT_MESSAGE_JOIN_ROOMS @"/chat/message/join_chat_rooms.json"
// 发送消息
#define CHAT_MESSAGE_SEND_MESSAGE @"/chat/message/send_message.json"
// 历史记录
#define CHAT_MESSAGE_HISTORY @"/chat/message/chat_history_with_user.json"
// 删除个人信息
#define CHAT_MESSAGE_DELETE_MY @"/chat/message/delete_self_message.json"
// 共享位置
#define CHAT_MESSAGE_SHARE_LOCATION @"/chat/message/share_location.json"
// 未读消息列表
#define CHAT_MESSAGE_NOT_READ @"/chat/message/searchHistoryNoRead.json"
// 读语音消息
#define CHAT_MESSAGE_READAUDIO @"/chat/message/readAudio.json"
// 进入，退出聊天
#define CHAT_MESSAGE_CHANGEISREAD @"/chat/message/changeIsRead.json"
// 转发消息
#define CHAT_MESSAGE_TRANSMIT @"/chat/message/transmit_message.json"
// 删除消息
#define CHAT_MESSAGE_DELETE_SELF @"/chat/message/delete_self_message.json"


#pragma mark - 个人名片
// 查询用户名片
#define CARD_USER_CARD @"/app/card/user_card.json"
// 编辑用户名片
#define CARD_EDIT_CARD @"/app/card/edit_card.json"
// 编辑用户名片地址
#define CARD_EDIT_CARD_ADDRESS @"/app/card/edit_card_address.json"
// 查询地址tag
#define CARD_SEARCH_ADDRESS_TAG @"/app/card/search_address_tag.json"
// 查询名片地址列表
#define CARD_SEARCH_CARD_ADDRESS @"/app/card/search_card_address.json"
// 名片输出（无需使用）
#define CARD_VIEW_CARD @"/app/card/view_card.json"
// 地址输出（无需使用）
#define CARD_VIEW_CARD_ADDRESS @"/app/card/view_card_address.json"
// 删除名片地址
#define CARD_DELETE_CARD_ADDRESS @"/app/card/delete_card_address.json"
// 分享名片地址给别人
#define CARD_SHARE_CARD_ADDRESS @"/app/card/share_card_address.json"
// 分享名片给别人
#define CARD_SHARE_CARD @"/app/card/share_card.json"

#pragma mark - 收藏
// 收藏消息或者取消收藏消息
#define COLLECT_MESSAGE @"/app/collect/collect_message.json"
// 查询和某人的收藏
#define COLLECT_LIST_MESSAGE @"/app/collect/list_collect_message.json"
// 收藏类型列表
#define COLLECT_LIST_TYPE @"/app/collect/type.json"


#pragma mark - 活动
// 修改或者新建活动
#define ACTIVITY_EDIT @"/chat/activity/edit_activity.json"
// 群里有哪些活动
#define ACTIVITY_GROUP_ACTIVITY @"/chat/activity/group_activity.json"
// 删除活动
#define ACTIVITY_DELETE_ACTIVITY @"/chat/activity/delete_activity.json"
// 加入活动（更改定位）删除活动
#define ACTIVITY_JOIN_ACTIVITY @"/chat/activity/join_activity.json"
// 申请成为队长
//#define ACTIVITY_APPLY_CAPTAIN @"/chat/activity/apply_captain.json"
// 通过队长
//#define ACTIVITY_PASS_CAPTAIN @"/chat/activity/pass_captain.json"
// 点击地图加入或者创建临时活动（也会通知）
#define ACTIVITY_EDIT_TEMP_ACTIVITY @"/chat/activity/edit_temp_activity.json"
// 活动页面点击返回
#define ACTIVITY_BACK_ACTIVITY @"/chat/activity/back_activity.json"
// 进入活动通知
#define ACTIVITY_JOIN_PUSH_ACTIVITY @"/chat/activity/join_push_activity.json"
// 我的所有活动
//#define ACTIVITY_SELF_ACTIVITY_LISTY @"/chat/activity/self_activity_list.json"
// 更改活动目的地
#define ACTIVITY_ACTIVITY_ROUTE @"/chat/activity/activity_route.json"
// 聊天页面底部弹窗共享位置查询
#define MESSAGE_LIST_LOCATION @"/chat/message/list_location.json"


#pragma mark - 行程
// 添加，修改，通过，拒绝行程
#define TRIP_EDIT @"/chat/trip/edit_trip.json"
// 行程显示输出（无需使用）
#define TRIP_SHOW @"/chat/trip/show_trip.json"
// 活动的所有行程
#define TRIP_ACTIVITY_TRIP @"/chat/trip/activity_trip.json"
// 删除行程
#define TRIP_DELETE_TRIP @"/chat/trip/delete_trip.json"

#pragma mark - 紧急联系人
// 编辑紧急联系人
#define OTHER_EDIT_MY_CONTACT @"/Client/other/edit_my_contact.json"
// 删除紧急联系人
#define OTHER_DELETE_MY_CONTACT @"/Client/other/delete_my_contact.json"
// 紧急联系人列表
#define OTHER_MY_CONTACT @"/Client/other/my_contact.json"
// 搜索周边分类
#define OTHER_MAP_ALLTYPE @"/Client/other/gd_category.json"

// 咨询列表
#define OTHER_NEWS_LIST_NEWS @"/news/article/list_news.json"
// 报警
#define OTHER_CALL_POLICE @"/Client/other/call_police.json"
// 发送设备信息
#define OTHER_REGISTERINSTALLDEVICES @"/Client/User/registerInstallDevices.json"

#pragma mark - 卡包
// 编辑卡片
#define COMPANY_EDIT_COMPANY_CARD @"/app/company/edit_company_card.json"
// 卡片分页列表
#define COMPANY_LIST_COMPANY_CARD @"/app/company/list_company_card.json"
// 删除卡片
#define COMPANY_DELETE_COMPANY_CARD @"/app/company/delete_company_card.json"
// 公司分页列表
#define COMPANY_LIST_COMPANY @"/app/company/list_company.json"


#endif
