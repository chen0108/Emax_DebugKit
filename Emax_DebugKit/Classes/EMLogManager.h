//
// EMLogManager.h
// Emax_DebugAid
//
// Created by HCC on 2018/12/23.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RedirectLogState) {
    RedirectLogToText,      //重定向到text
    RedirectLogToFile,      //重定向到file
};

@interface EMLogManager : NSObject

/**
 *  设置日志重定向功能
 *  didFinishLaunchingWithOptions方法中调用此方法
 *  #ifdef __OPTIMIZE__
 *       [EMLogManager setRedirectLogState:XX];
 *  #endif
 */
+ (void)setRedirectLogState:(RedirectLogState)state;


/**
 *  返回当前重定向方式
 */
+ (RedirectLogState)currentLogState;

/* ============================================================ */
#pragma mark - 模式一:EMLogManager单例对象保存运行后的日志
/* ============================================================ */

/**
 *    @brief    重定向到text时,调用这个方法返回日志string
 *
 */
+ (NSString *)currentLog;

/* ============================================================ */
#pragma mark - 模式二:本地文件保存日志, 支持日志上传
/* ============================================================ */
/**
 *  @eg: useIn  application didFinishLaunchingWithOptions:
    [LogManager setRedirectLogState:RedirectLogToFile];
    [LogManager setupCloudRegionName:@"ap-guangzhou"
                          bucketName:@"smartthermox-1256637689"];
    [self.window addGestureRecognizer:[LogManager setupGestureTapCount:3]];
 */


/**
 *  @brief  配置上传日志功能所依赖的腾讯云服务
 *  设置参数从腾讯云平台上获取
 *  不使用腾讯云的SDK,直接通过API发起上传,暂没有实现签名鉴权,所以bucket必须是公有读写属性,否则无法上传
 */
+ (void)setupCloudRegionName:(NSString *)regionName
                  bucketName:(NSString *)bucketName;



/**
 *    @brief    查询是否配置了云服务
 */
+ (BOOL)haveConfixCloud;


/**
 *    @brief    生成一个tap手势,手势已经实现了reportLog action
 */
+ (UIGestureRecognizer *)setupGestureTapCount:(NSUInteger)count;


/**
 *    @brief    上报日志(如果BucketName为空,不能上传)
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


@end
