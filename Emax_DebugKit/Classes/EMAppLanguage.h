// EMAppLanguage.h 
// Emax_DebugAid
//
// Created by HCC on 2018/12/23.
//
//

#import <Foundation/Foundation.h>

//语言改变通知
FOUNDATION_EXPORT NSString * const kAppLanguageDidChangeNotification;


@interface EMAppLanguage : NSObject

/**
 *  @brief  设置支持的语言, 默认只支持英文
 *  dict :  key==>语言前缀(zh-,en-)  value==>资源包名称(zh-Hans,en)
 *      [EMAppLanguage setSupportLanguageDictionary:@{@"zh-":@"zh-Hans",
                                                      @"de-":@"de",
                                                      @"ja-":@"ja",
                                                      @"ru-":@"ru-RU",
                                                      @"fr-":@"fr",
                                                      @"el-":@"el-GR",
                                                       }];
 */
+ (void)setSupportLanguageDictionary:(NSDictionary *)dict;

/**
 *  @brief  返回当前app支持的语言
 *  dict :  key==>languageString  value==>sourceName
 */
+ (NSDictionary *)supportLanguageDictionary;


/**
 *  @brief  是否开启自定义语言, 否则跟随手机第一语言
 */
+ (void)setCustomLanguageEnable:(BOOL)enable;

/**
 *  @brief  获取当前是否开启自定义语言状态
 */
+ (BOOL)customLanguageEnable;



/**
 *  @brief  切换自定义语言. (前提是setCustomLanguageEnable设置了YES才有效)
 */
+ (void)setCustomLanguage:(NSString *)lan;



/**
 *  @brief  返回当前自定义语言
 */
+ (NSString *)currentCustomLanguage;

/**
 *  @brief  返回当前手机第一语言
 */
+ (NSString *)currentSystemLanguage;


/**
 *  @brief  返回当前app语言
 */
+ (NSString *)currentAppLanguage;




@end








