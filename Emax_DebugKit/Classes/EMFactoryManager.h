// EMFactoryManager.h 
// Emax_DebugAid
//
// Created by HCC on 2018/12/23.
//
//

#import <Foundation/Foundation.h>

///工厂模式变化时的通知
FOUNDATION_EXPORT NSString *const kAppFactoryModeDidChanged;

@interface EMFactoryManager : NSObject

/**
 *  当前是否工厂模式
 *
 */
+ (BOOL)inFactoryMode;


/**
 *  设置是否工厂模式
 *
 */
+ (void)setFactoryMode:(BOOL)factory;


/**
 *  设置是否默认工厂模式(只有在app安装后生效1次)
 *
 */
+ (void)setDefaulFactoryMode:(BOOL)factory;


/**
 *  模式变化时的回调
 *
 */
+ (void)modeChangedHander:(void(^)(void))handler;


@end




@interface UIWindow (FactoryMode)



@end
