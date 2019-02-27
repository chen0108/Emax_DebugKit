// EMLogSubmitViewController.m 
// Emax_DebugKit 
// 
// Created by HCC on 2019/1/24. 
//  
//

#import "EMLogSubmitViewController.h"
#import "EMLogManager.h"
#import "sys/utsname.h"

@interface EMLogSubmitViewController ()<UITextViewDelegate>


@end

@implementation EMLogSubmitViewController

- (UILabel *)titleLb{
    if (!_titleLb) {
        _titleLb = [UILabel new];
        _titleLb.frame = CGRectMake(20, 10, 200, 40);
        _titleLb.textColor = [UIColor blackColor];
        _titleLb.font = [UIFont boldSystemFontOfSize:15];
        _titleLb.text = @"问题描述:";
    }
    return _titleLb;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        _textView.layer.cornerRadius = 5;
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = [UIColor grayColor].CGColor;
        _textView.textColor = [UIColor blackColor];
        _textView.font = [UIFont boldSystemFontOfSize:15];
        _textView.frame = CGRectMake(20, CGRectGetMaxY(self.titleLb.frame) + 10, self.view.bounds.size.width-40, 160 * self.view.bounds.size.height/667);
    }
    return _textView;
}

- (UILabel *)replayLb{
    if (!_replayLb) {
        _replayLb = [UILabel new];
        _replayLb.numberOfLines = 0;
        _replayLb.frame = CGRectZero;
        _replayLb.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
        _replayLb.font = [UIFont boldSystemFontOfSize:14];
    }
    return _replayLb;
}

- (UIButton *)btnSubmit{
    if (!_btnSubmit) {
        _btnSubmit = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnSubmit.frame = CGRectMake(20, CGRectGetMaxY(self.textView.frame) + 20, self.view.bounds.size.width-40, 36);
        _btnSubmit.backgroundColor = [UIColor blackColor];
        [_btnSubmit setTitle:@"提交" forState:UIControlStateNormal];
        [_btnSubmit setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _btnSubmit.layer.cornerRadius = 5;
        _btnSubmit.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_btnSubmit addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSubmit;
}

- (NSString *)submitErrorString{
    if (!_submitErrorString) {
        _submitErrorString = @"提交失败";
    }
    return _submitErrorString;
}

- (NSString *)submitSuccessString{
    if (!_submitSuccessString) {
        _submitSuccessString = @"提交成功";
    }
    return _submitSuccessString;
}

- (NSString *)enterDescString{
    if (!_enterDescString) {
        _enterDescString = @"请输入问题描述后再提交";
    }
    return _enterDescString;
}

- (NSString *)confirmString{
    if (!_confirmString) {
        _confirmString = @"确定";
    }
    return _confirmString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.title == nil) {
        self.title = @"上传服务器";
    }
    self.view.backgroundColor = UIColor.whiteColor;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Do any additional setup after loading the view.
    
    UIScrollView *scr = [UIScrollView new];
    scr.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:scr];
    [scr addSubview:self.titleLb];
    [scr addSubview:self.textView];
    [scr addSubview:self.btnSubmit];
    scr.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(self.btnSubmit.frame) + 20);

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    /// 开发者的回复
    DeveloperPushMessage *message = [EMLogManager getLastPushMessage];
    if (message) {
        NSString *title = [NSString stringWithFormat:@"Last developer's Reply  %@\n\n%@\n\n%@",message.timeString,message.message, message.developer];
        CGFloat width = self.view.frame.size.width - 40;
        NSDictionary *att = @{NSFontAttributeName:self.replayLb.font};
        CGFloat height = [title boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:att context:nil].size.height + 20;
        self.replayLb.text = title;
        self.replayLb.frame = CGRectMake(20, self.view.frame.size.height - height - 20, width, height);
        [self.view addSubview:self.replayLb];
    }
}

- (void)submit{
    [self.view endEditing:YES];
    if (self.textView.text.length == 0) {
        [self submitResultState:-1];
        return;
    }
    NSLog(@"deviceName: %@",[self getDeviceModel]);
    NSLog(@"======== Submit issues ======== \n<\n %@ \n>",self.textView.text);
    [EMLogManager reportLogResult:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self submitResultState:isSuccess];
        });
    }];
}

- (void)submitResultState:(NSUInteger)state{
    if (self.submitHandler) {
        self.submitHandler(state);
        return;
    }
    if (state == -1) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:self.enterDescString message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:self.confirmString style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else if (state == 0){
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:self.submitErrorString message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:self.confirmString style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else{
        __weak  typeof(self)this = self;
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:self.submitSuccessString message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:self.confirmString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [this.navigationController popViewControllerAnimated:YES];
        }]];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView endEditing:YES];
    }
    return YES;
}


///设备型号
- (NSString *)getDeviceModel{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}


@end
