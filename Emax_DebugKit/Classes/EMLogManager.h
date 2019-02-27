//
// EMLogManager.h
// Emax_DebugAid
//
// Created by HCC on 2018/12/23.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DeveloperPushMessage;
@interface EMLogManager : NSObject

/**
 *  设置日志重定向
 */
+ (void)enableRedirectLog:(BOOL)enable;


/**
 *  返回当前是否开启
 */
+ (BOOL)hasEnableRedirectLog;


/**
 *  设置日志保存时长(默认3天)
 */
+ (void)setLogSaveDurationDay:(NSUInteger)day;


/**
 *  @brief  配置上传日志功能所依赖的腾讯云服务参数
 *  设置参数从腾讯云平台上获取
 *  不使用腾讯云的SDK,直接通过API发起上传,暂没有实现签名鉴权,所以bucket必须是公有读写属性,否则无法上传
 *  默认值 regionName:@"ap-chengdu" bucketName:@"emax-1256637689"
 */
+ (void)setupCloudRegionName:(NSString *)regionName
                  bucketName:(NSString *)bucketName;


/**
 *    @brief    生成一个tap手势,手势已经实现了reportLog action
 */
+ (UIGestureRecognizer *)setupGestureTapCount:(NSUInteger)count;


/**
 *    @brief    上报日志
 */
+ (void)reportLogResult:(void(^)(BOOL isSuccess))handle;


/**
 *  获取日志文件列表
 */
+ (NSArray *)getLogListFile;


/**
 *  从path路径中移除文件
 */
+ (BOOL)removeFileOfPath:(NSString *)path;


/* ============================================================ */
#pragma mark - PUSH MESSAGE
/* ============================================================ */
/**
 {
    alert = "Your message Here";
    developer = "chen";
    time = "2019/01/30 HH:mm:ss";   //东8区时间
    title = "emaxReply";
 };
 */
/// 读取最新的推送
+ (DeveloperPushMessage *)getLastPushMessage;

/// 保存最近的推送
+ (void)setLastPushMessage:(DeveloperPushMessage *)msg;


@end

static NSString *const identityKey = @"emaxTitle";
static NSString *const identityVal = @"emaxReply";

@interface DeveloperPushMessage : NSObject

@property(nonatomic, copy  ) NSString *title;
@property(nonatomic, copy  ) NSString *message;
@property(nonatomic, copy  ) NSString *developer;
@property(nonatomic, copy  ) NSString *timeString;

/// 规定info必须包含identityKey这个key才解析, 且值为identityVal
+ (DeveloperPushMessage *)parseFromDictionay:(NSDictionary *)info;

@end



