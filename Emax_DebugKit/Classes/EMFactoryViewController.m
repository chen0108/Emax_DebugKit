// EMFactoryViewController.m 
// Emax_DebugKit 
// 
// Created by HCC on 2018/12/24. 
//  
//

#import "EMFactoryViewController.h"
#import "EMFactoryManager.h"

@interface EMFactoryViewController ()

@property(nonatomic, strong) UILabel *stateLabel;

@end

@implementation EMFactoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"工厂模式";
    self.view.backgroundColor = UIColor.whiteColor;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    UILabel *lb = [UILabel new];
    lb.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];;
    lb.font = [UIFont systemFontOfSize:16];
    lb.numberOfLines = 0;
    lb.text = @"切换工厂模式,可能需要清空用户数据,并重新启动app。";
    lb.frame = CGRectMake(20, 100, self.view.frame.size.width - 30, 60);
    [self.view addSubview:lb];
    
    UILabel *state = [UILabel new];
    state.textColor = UIColor.blackColor;
    state.numberOfLines = 0;
    state.text = [EMFactoryManager inFactoryMode] ? @"工厂模式: 已开启" : @"工厂模式: 已关闭";
    state.textAlignment = NSTextAlignmentCenter;
    state.font = [UIFont boldSystemFontOfSize:18];
    state.frame = CGRectMake(20, CGRectGetMaxY(lb.frame) + 20, self.view.frame.size.width - 40, 60);
    [self.view addSubview:state];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.bounds  = CGRectMake(0, 0, 100, 36);
    btn.center = CGPointMake(self.view.frame.size.width/2, CGRectGetMaxY(state.frame) + 40);
    [btn setTitle:@"切换" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}


- (void)btnClick:(UIButton *)btn{
    __weak  typeof(self)this = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"切换工厂模式,可能需要清空用户数据,并重新启动app。" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [EMFactoryManager setFactoryMode:![EMFactoryManager inFactoryMode]];
        [this dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}


@end
