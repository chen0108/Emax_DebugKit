// EMFeedbackManager.m 
// Emax_DebugKit_Example 
// 
// Created by HCC on 2019/3/8. 
// Copyright © 2019 chen0108_mbp. All rights reserved. 
//

#import "EMFeedbackManager.h"
#import <CommonCrypto/CommonDigest.h>

static NSString * const FEEDBACK = @"FEEDBACK";
static NSString * const MESSAGELAST = @"MESSAGELASTKEY";
static NSString * const MESSAGEALL = @"MESSAGEALLKEY";

typedef void (^SuccessBlock)(NSDictionary *object);

@implementation EMFeedbackMessage

+ (instancetype)modelFromDictionary:(NSDictionary *)dict{
    NSString *time = [dict objectForKey:@"updatedAt"];
    NSString *content = [dict objectForKey:@"content"];
    NSString *objectId = [dict objectForKey:@"objectId"];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [fmt dateFromString:time];
    EMFeedbackMessage *message = [EMFeedbackMessage new];
    message.messageId = objectId;
    message.content = content;
    message.date = date;
    return message;
}

- (NSString *)dateString{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"MM-dd HH:mm"];
    return [fmt stringFromDate:self.date];
}

@end


@implementation EMFeedbackManager

#pragma mark - store
static NSString *_feedbackID;
static EMFeedbackMessage *_lastMessage;
static NSDictionary *_allMessage;

+ (void)saveFeedbackID:(NSString *)feedbackID{
    _feedbackID = feedbackID;
    [[NSUserDefaults standardUserDefaults] setObject:feedbackID forKey:FEEDBACK];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveMessageDictionary:(NSDictionary *)dict{
    _lastMessage = [EMFeedbackMessage modelFromDictionary:dict];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:MESSAGELAST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveAllMessage:(NSDictionary *)dict{
    _allMessage = dict;
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:MESSAGEALL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - setup && API
static NSString *_appId = @"UyrMBENxh2s8YWdM7pFje10s-gzGzoHsz";
static NSString *_appKey = @"d9F1QAzEhwYfxfNiLKUYKklv";
static NSString *_apiServer = @"uyrmbenx.api.lncld.net";
static NSString *_apiVersion = @"1.1";
+ (void)setupAppID:(NSString *)appid appKey:(NSString *)appkey{
    if (appid.length > 0 && appkey.length > 0) {
        _appId = appid;
        _appKey = appkey;
        _apiServer = [NSString stringWithFormat:@"%@.api.lncld.net",[appid substringToIndex:8].lowercaseString];
    }
    [self updateServerAPI];
    _feedbackID = [[NSUserDefaults standardUserDefaults] objectForKey:FEEDBACK];
    _allMessage = [[NSUserDefaults standardUserDefaults] objectForKey:MESSAGEALL];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:MESSAGELAST];
    if (dict) {
        _lastMessage = [EMFeedbackMessage modelFromDictionary:dict];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLastReplyMessage) name:UIApplicationDidBecomeActiveNotification object:nil];
}

+ (void)setupDefaultAppIdKey{
    [self setupAppID:@"" appKey:@""];
}


static BOOL _enableAlert = NO;
static NSDictionary *_titleAtt;
static NSDictionary *_textAtt;
+ (void)setEnableAlert:(BOOL)anableAlert titleAttribute:(NSDictionary<NSAttributedStringKey,id> *)titleAtt textAttribute:(NSDictionary<NSAttributedStringKey,id> *)textAtt{
    _enableAlert = anableAlert;
    if (titleAtt == nil) {
        _titleAtt = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:22],
                      NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
                      NSForegroundColorAttributeName:[UIColor redColor]};
    }else{
        _titleAtt = titleAtt;
    }
    if (textAtt == nil) {
        _textAtt = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                     NSForegroundColorAttributeName:[UIColor blackColor]};
    }else{
        _textAtt  =textAtt;
    }
}

+ (EMFeedbackMessage *)getLastLocalMessage{
    return _lastMessage;
}

+ (NSDictionary *)getAllLocalMessage{
    return _allMessage;
}

/// 发送1条反馈消息
+ (void)sendMessage:(NSString *)message{
    //检查反馈对象是否存在,是否处于打开状态
    // 本地不存在反馈,创建
    if (_feedbackID == nil) {
        [self createNewFeedbackRet:^(NSDictionary *object) {
            NSString *feedbackID = [object objectForKey:@"objectId"];
            if (feedbackID) {
                [self saveFeedbackID:feedbackID];
                [self createNewMessage:message feedbackID:feedbackID success:^(NSDictionary *object) {}];
            }
        }];
    }
    //本地存在,检查状态
    else{
        [self queryFeedback:_feedbackID success:^(NSDictionary *object) {
            NSString *status = [object objectForKey:@"status"];
            if ([status isEqual:@"open"]) {
                [self createNewMessage:message feedbackID:_feedbackID success:^(NSDictionary *object) {}];
            }else{
                //服务器关闭或删除了这个反馈
                [self saveFeedbackID:nil];
                [self sendMessage:message];
            }
        }];
    }
}

/// 获取开发者回复
+ (void)updateLastReplyMessage{
    if (_feedbackID == nil) {
        return;
    }
    [self queryFeedbackMessage:_feedbackID success:^(NSDictionary *object) {
        [self saveAllMessage:object];
        NSArray *result = [object objectForKey:@"results"];
        for (NSInteger i = result.count - 1; i > 0; i--) {
            NSDictionary *msg = result[i];
            NSString *type = [msg objectForKey:@"type"];
            if ([type isEqual:@"dev"]) {
                [self didReceiveMessageDictionary:msg];
                break;
            }
        }
    }];
}

static NewMessageHandler _handler;
+ (void)didReceiveNewMessageHandle:(NewMessageHandler)handler{
    _handler = handler;
}

+ (void)didReceiveMessageDictionary:(NSDictionary *)dict{
    NSString *msgID = [dict objectForKey:@"objectId"];
    if ([msgID isEqual:_lastMessage.messageId]) {
        return;
    }
    [self saveMessageDictionary:dict];
    NSLog(@"===[EmaxDebug] 提示1条新消息:%@ (%@)",_lastMessage.content,_lastMessage.date);
    if (_enableAlert) {
        [self showNewMessage];
    }
    if (_handler) {
        _handler(_lastMessage);
    }
}

+ (void)showNewMessage{
    if (_lastMessage.content.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *time = [fmt stringFromDate:_lastMessage.date]?:@"";
            
            NSMutableAttributedString *str = [NSMutableAttributedString new];
            NSAttributedString *attTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"New Message", nil) attributes:_titleAtt];
            NSAttributedString *attContent = [[NSAttributedString alloc] initWithString:_lastMessage.content attributes:_textAtt];
            NSAttributedString *attTime = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",time] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor grayColor]}];
            NSAttributedString *attBigWarp = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n "] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:30]}];
            NSAttributedString *attWarp = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n "] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
            [str appendAttributedString:attTitle];
            [str appendAttributedString:attBigWarp];
            [str appendAttributedString:attContent];
            [str appendAttributedString:attWarp];
            [str appendAttributedString:attTime];
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            @try {
                [alertVC setValue:str forKey:@"attributedMessage"];
            } @catch (NSException *exception) {
                [alertVC setTitle:NSLocalizedString(@"New Message", nil)];
                [alertVC setTitle:[NSString stringWithFormat:@"%@\n%@",_lastMessage.content,time]];
            } @finally {
                
            }
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
        });
    }
}


#pragma mark - NET Method

/// 查询反馈对象
+ (void)queryFeedback:(NSString *)feedbackID success:(SuccessBlock)block{
    NSString *path = [NSString stringWithFormat:@"feedback/%@",feedbackID];
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    [self sendRequest:request success:block];
}

/// 查询反馈消息
+ (void)queryFeedbackMessage:(NSString *)feedbackID success:(SuccessBlock)block{
    NSString *path = [NSString stringWithFormat:@"feedback/%@/threads",feedbackID];
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:nil];
    [self sendRequest:request success:block];
}

/// 创建1个反馈对象
+ (void)createNewFeedbackRet:(SuccessBlock)block{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *displayName = [infoDic objectForKey:@"CFBundleDisplayName"];
    UIDevice *device = [UIDevice currentDevice];
    NSString *subUUID = [[device.identifierForVendor UUIDString] substringToIndex:6];
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"feedback" parameters:@{@"content":displayName,@"contact":subUUID}];
    [self sendRequest:request success:block];
}

/// 创建1个反馈消息
+ (void)createNewMessage:(NSString *)message feedbackID:(NSString *)feedbackID success:(SuccessBlock)block{
    if (message.length == 0) {
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"user" forKey:@"type"];
    [param setObject:message forKey:@"content"];
    [param setObject:feedbackID forKey:@"feedback"];
    NSString *path = [NSString stringWithFormat:@"feedback/%@/threads",feedbackID];
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:param];
    [self sendRequest:request success:block];
}

+ (void)sendRequest:(NSURLRequest *)request success:(SuccessBlock)block{
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (response && data && block) {
            NSError *error;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error == nil && dictionary) {
//                NSLog(@"===[EmaxDebug] [%@] %@ RESP:%@",request.HTTPMethod,request.URL.absoluteString,dictionary);
                block(dictionary);
            }
        }
    }];
    [dataTask  resume];
}

+ (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSString *fullPath = [NSString stringWithFormat:@"https://%@/%@/%@",_apiServer,_apiVersion,path];
    NSURL *url = [NSURL URLWithString:fullPath];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString *timestamp = [NSString stringWithFormat:@"%.0f",1000*[[NSDate date] timeIntervalSince1970]];
    NSString *sign = [self calMD5:[NSString stringWithFormat:@"%@%@",timestamp,_appKey]];
    NSString *headerValue = [NSString stringWithFormat:@"%@,%@",sign,timestamp];
    [request setValue:headerValue forHTTPHeaderField:@"X-LC-Sign"];
    [request setValue:_appId forHTTPHeaderField:@"X-LC-Id"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:8];
    [request setHTTPMethod:method];
    if ([method isEqualToString:@"GET"]) {
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:@"?%@", [self queryStringFromParameters:parameters]]];
        [request setURL:url];
    } else {
        [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
        NSError *error;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];
    }
    return request;
}

+ (void)updateServerAPI{
    NSString *fullPath = [NSString stringWithFormat:@"https://app-router.leancloud.cn/2/route?appId=%@",_appId];
    NSURL *url = [NSURL URLWithString:fullPath];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return;
        }
        if (response && data) {
            NSError *error;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSString *apiServer = [dictionary objectForKey:@"api_server"];
            if ([apiServer isKindOfClass:NSString.class]) {
                NSLog(@"===[EmaxDebug] Update APIServer:%@",apiServer);
                _apiServer = apiServer;
            }
        }
    }];
    [dataTask  resume];
}

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters {
    NSMutableString *queries = [[NSMutableString alloc] init];
    NSArray *keys = [parameters allKeys];
    for (int i = 0; i < keys.count; i++) {
        if (i != 0) {
            [queries appendString:@"&"];
        }
        NSString *value = [parameters valueForKey:keys[i]];
        [queries appendFormat:@"%@=%@", keys[i], value];
    }
    return [queries stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*)calMD5:(NSString *)input {
    const char *cstr = [input UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

@end

