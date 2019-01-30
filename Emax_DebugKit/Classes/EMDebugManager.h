// EMDebugManager.h 
// Emax_DebugAid 
// 
// Created by HCC on 2018/12/23. 
//  
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface EMDebugManager : NSObject


/**
 *  返回1个触发手势
 *
 *  @param  count  点击次数
 *  @param  password  密码验证
 */
+ (UIGestureRecognizer *)setupTriggerGestureTapCount:(NSUInteger)count password:(NSString *)password;


/**
 *  退出APP
 *
 */
+ (void)exitApplication;

@end

NS_ASSUME_NONNULL_END
