// EMFactoryManager.m 
// Emax_DebugAid
//
// Created by HCC on 2018/12/23.
//
//

NSString *const kAppFactoryModeDidChanged = @"EMAppFactoryModeDidChanged";
NSString *const kAppDefaultModeDidSeted   = @"EMAppDefaultModeDidSeted";
NSString *const kApp_FactoryMode          = @"AppFactoryMode";

#import "EMFactoryManager.h"
#import "NSBundle+DebugKit.h"
#import <objc/runtime.h>

typedef void(^modeChange)(void);

@implementation EMFactoryManager

static NSNumber *inFactory;
+ (BOOL)inFactoryMode{
    if (inFactory == nil) {
        inFactory = [[NSUserDefaults standardUserDefaults] objectForKey:kApp_FactoryMode];
    }
    return inFactory.boolValue;
}

static modeChange _handler;
+ (void)setFactoryMode:(BOOL)factory{
    if (factory == inFactory.boolValue) {
        return;
    }
    inFactory = @(factory);
    [[NSUserDefaults standardUserDefaults] setObject:@(factory) forKey:kApp_FactoryMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppFactoryModeDidChanged object:nil];
    if (_handler) {
        _handler();
    }
}

+ (void)setDefaulFactoryMode:(BOOL)factory{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kApp_FactoryMode] == nil) {
        inFactory = @(factory);
        [[NSUserDefaults standardUserDefaults] setObject:@(factory) forKey:kApp_FactoryMode];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppDefaultModeDidSeted object:nil];
    }
}

+ (void)modeChangedHander:(void (^)(void))handler{
    _handler = handler;
}


@end




@implementation UIWindow (FactoryMode)


+ (void)load{
    //storyboard适配
    Method method1 = class_getInstanceMethod([self class], @selector(initWithCoder:));
    Method method2 = class_getInstanceMethod([self class], @selector(adapterInitWithCoder:));
    method_exchangeImplementations(method1, method2);
    //代码创建适配
    Method method3 = class_getInstanceMethod([self class], @selector(initWithFrame:));
    Method method4 = class_getInstanceMethod([self class], @selector(adapterInitWithFrame:));
    method_exchangeImplementations(method3, method4);
}

- (instancetype)adapterInitWithCoder:(NSCoder *)acoder{
    [self adapterInitWithCoder:acoder];
    if (self.class == UIWindow.class) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFactoryModeChanged) name:kAppFactoryModeDidChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFactoryModeChanged) name:kAppDefaultModeDidSeted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFactoryModeChanged) name:UIWindowDidBecomeVisibleNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFactoryModeChanged) name:UIWindowDidBecomeHiddenNotification object:nil];
        [self didFactoryModeChanged];
    }
    return self;
}

- (instancetype)adapterInitWithFrame:(CGRect)frame{
    [self adapterInitWithFrame:frame];
    if (self.class == UIWindow.class) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFactoryModeChanged) name:kAppFactoryModeDidChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFactoryModeChanged) name:kAppDefaultModeDidSeted object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFactoryModeChanged) name:UIWindowDidBecomeVisibleNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFactoryModeChanged) name:UIWindowDidBecomeHiddenNotification object:nil];
        [self didFactoryModeChanged];
    }
    return self;
}

static UIImageView *logView1 = nil;
static UIImageView *logView2 = nil;
- (void)didFactoryModeChanged{
    if (logView1 == nil) {
        NSBundle *bundle = [NSBundle bundleWithBundleName:@"EMDebugKit" podName:@"Emax_DebugKit"];
        logView1 = [[UIImageView alloc] init];
        logView1.frame = CGRectMake(0, 120, 105*1.5, 26*1.5);
        logView1.image = [UIImage imageNamed:@"gongc-b" inBundle:bundle compatibleWithTraitCollection:nil];
        logView1.contentMode = UIViewContentModeScaleAspectFit;
        logView1.transform = CGAffineTransformMakeRotation(-30 *M_PI / 180.0);
    }
    if (logView2 == nil) {
        NSBundle *bundle = [NSBundle bundleWithBundleName:@"EMDebugKit" podName:@"Emax_DebugKit"];
        logView2 = [[UIImageView alloc] init];
        logView2.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width-160, UIScreen.mainScreen.bounds.size.height-120, 105*1.5, 26*1.5);
        logView2.image = [UIImage imageNamed:@"gongc-w" inBundle:bundle compatibleWithTraitCollection:nil];
        logView2.contentMode = UIViewContentModeScaleAspectFit;
        logView2.transform = CGAffineTransformMakeRotation(-30 *M_PI / 180.0);
    }
    if (self.hidden == NO) {
        if ([EMFactoryManager inFactoryMode]) {
            [self addSubview:logView1];
            [self addSubview:logView2];
            [self bringSubviewToFront:logView1];
            [self bringSubviewToFront:logView2];
        }else{
            [logView1 removeFromSuperview];
            [logView2 removeFromSuperview];
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (logView1.superview && self.class == UIWindow.class) {
        [self bringSubviewToFront:logView1];
    }
    if (logView2.superview && self.class == UIWindow.class) {
        [self bringSubviewToFront:logView2];
    }
}

@end
