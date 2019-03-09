// EMFeedbackManager.h 
// Emax_DebugKit_Example 
// 
// Created by HCC on 2019/3/8. 
// Copyright © 2019 chen0108_mbp. All rights reserved. 
// 不是即时通讯!!
// 使用第三方云服务存取反馈消息,app进入前台时主动查询回复消息,暂时只保留最近的1条回复消息

#import <Foundation/Foundation.h>

@interface EMFeedbackMessage : NSObject

@property(nonatomic, copy  ) NSString *messageId;
@property(nonatomic, copy  ) NSString *content;
@property(nonatomic, strong) NSDate *date;
- (NSString *)dateString;

@end

typedef void (^NewMessageHandler)(EMFeedbackMessage *message);

@interface EMFeedbackManager : NSObject

/// 初始化
+ (void)setupAppID:(NSString *)appid appKey:(NSString *)appkey;
+ (void)setupDefaultAppIdKey;

/// 有新消息时是否弹框,弹框配置
+ (void)setEnableAlert:(BOOL)anableAlert titleAttribute:(NSDictionary<NSAttributedStringKey, id> *)titleAtt textAttribute:(NSDictionary<NSAttributedStringKey, id> *)textAtt;

/// 获取本地最新的回复消息
+ (EMFeedbackMessage *)getLastLocalMessage;

/// 获取本地所有消息
+ (NSDictionary *)getAllLocalMessage;

/// 发送反馈消息
+ (void)sendMessage:(NSString *)message;

/// 如果有需要,调用这个方法请求最新回复数据
+ (void)updateLastReplyMessage;

/// 有新消息时的回调
+ (void)didReceiveNewMessageHandle:(NewMessageHandler)handler;


@end

