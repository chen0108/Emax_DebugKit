// EMDebugManager.m 
// Emax_DebugAid 
// 
// Created by HCC on 2018/12/23. 
//  
//

#import "EMDebugManager.h"
#import "EMDebugListViewController.h"

@implementation EMDebugManager

static NSString *_password = @"emax";
+ (UIGestureRecognizer *)setupTriggerGestureTapCount:(NSUInteger)count password:(nonnull NSString *)password{
    if (password) {
        _password = password;
    }
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(authorization)];
    ges.numberOfTapsRequired = count;
    return ges;
}

static NSString *_inputWord;
+ (void)authorization{
    if (_password.length == 0 || _inputWord) {
        [self access];
        return;
    }
    ///授权框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * tf1 = alertController.textFields[0];
        if ([tf1.text isEqualToString:_password]) {
            _inputWord = tf1.text;
            [self access];
        }
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"password";
    }];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)access{
    EMDebugListViewController *aidVC = [EMDebugListViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:aidVC];
    [nav.navigationBar setTintColor:[UIColor blackColor]];
    [nav.navigationBar setTranslucent:NO];
    [nav.navigationBar setTintColor:[UIColor blackColor]];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-2000, 0) forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

+ (void)exitApplication {
    
    [UIView beginAnimations:@"exitApplication" context:nil];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[UIApplication sharedApplication].delegate.window cache:NO];
    [UIApplication sharedApplication].delegate.window.bounds = CGRectMake(0, 0, 0, 0);
    [UIView commitAnimations];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

@end


