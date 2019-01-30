// EMAppLanguage.m 
// Emax_DebugAid
//
// Created by HCC on 2018/12/23.
//
//

#import "EMAppLanguage.h"
#import <objc/runtime.h>

NSString * const kAppLanguageDidChangeNotification = @"EMAppLanguageDidChanged";
NSString * const customLanKey = @"customLanKey";

static NSNumber *_customEnable = nil;
static NSDictionary *_LanDictionary = nil;

/* *************************-*************************-************************* */
/*                                                                               */
/* NSBundle custom                                                               */
/*                                                                               */
/* *************************-*************************-************************* */
@interface ZZBundleEx : NSBundle


@end

@implementation ZZBundleEx

static const char kBundleKey = 0;
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = objc_getAssociatedObject(self, &kBundleKey);
    if (bundle) {
        return [bundle localizedStringForKey:key value:value table:tableName];
    } else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}

@end



/* *************************-*************************-************************* */
/*                                                                               */
/* NSBundle extension                                                            */
/*                                                                               */
/* *************************-*************************-************************* */
@interface NSBundle (EMLanguage)


@end

@implementation NSBundle (EMLanguage)

///需要支持更多语言时,自行添加
+ (void)setup{
    NSString *lan = [EMAppLanguage currentAppLanguage];
    NSDictionary *lanDict = [EMAppLanguage supportLanguageDictionary];
    NSString *path;
    NSArray *lanArray = [lanDict allKeys];
    for (NSString *lanVar in lanArray) {
        if ([lan hasPrefix:lanVar]) {//
            NSString *source = [lanDict objectForKey:lanVar];
            NSLog(@"加载语言包%@ => %@",lanVar,source);
            path = [[NSBundle mainBundle] pathForResource:source ofType:@"lproj"];
            break;
        }
    }
    //默认英文包
    if (path == nil) {
        NSLog(@"%@",@"未找到语言包,加载默认英文包");
        path = [[NSBundle mainBundle] pathForResource:@"en"ofType:@"lproj"];
    }
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    objc_setAssociatedObject([NSBundle mainBundle], &kBundleKey, bundle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppLanguageDidChangeNotification object:nil];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle],[ZZBundleEx class]);
        [self setup];
    });
}

@end


/* *************************-*************************-************************* */
/*                                                                               */
/* EMAppLanguage                                                            */
/*                                                                               */
/* *************************-*************************-************************* */


@implementation EMAppLanguage

/// 设置支持的语言
+ (void)setSupportLanguageDictionary:(NSDictionary *)dict{
    _LanDictionary = dict;
}


/// 返回当前app支持的语言
+ (NSDictionary *)supportLanguageDictionary{
//    if (_LanDictionary == nil || [_LanDictionary allKeys].count == 0) {
//        _LanDictionary = @{@"en-":@"en"};
//    }
    return _LanDictionary;
}

/// 是否开启自定义语言, 否则跟随手机第一语言
+ (void)setCustomLanguageEnable:(BOOL)enable{
    _customEnable = [NSNumber numberWithBool:enable];
    if (enable == NO) {
        [self setCustomLanguage:nil];
    }
    //重新初始化bundle
    [NSBundle setup];
}

/// 获取当前是否开启自定义语言状态
+ (BOOL)customLanguageEnable{
    return _customEnable.boolValue;
}

/// 切换自定义语言. (前提是setCustomLanguageEnable设置了YES才有效)
+ (void)setCustomLanguage:(NSString *)lan{
    if (lan == nil || lan.length == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:customLanKey];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:lan forKey:customLanKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    //重新初始化bundle
    [NSBundle setup];
}

//当前自定义语言
+ (NSString *)currentCustomLanguage{
    return [[NSUserDefaults standardUserDefaults] objectForKey:customLanKey];
}

//当前手机第一语言
+ (NSString *)currentSystemLanguage{
    //强制复位,防止其他模块修改了AppleLanguages无法拿到真实的语言列表
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //手机首选语言
    return [NSLocale preferredLanguages].firstObject;
}

//当前app语言
+ (NSString *)currentAppLanguage{
    NSString *lan;
    BOOL enable = [_customEnable boolValue];
    if (enable) {
        lan = [self currentCustomLanguage];
    }
    if (lan == nil || lan.length == 0) {
        lan = [self currentSystemLanguage];
    }
    return lan;
}


@end


