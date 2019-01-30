// EMLogSubmitViewController.h 
// Emax_DebugKit 
// 
// Created by HCC on 2019/1/24. 
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMLogSubmitViewController : UIViewController

@property(nonatomic, strong) UILabel *titleLb;
@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, strong) UIButton *btnSubmit;

@property(nonatomic, copy  ) NSString *submitErrorString;
@property(nonatomic, copy  ) NSString *submitSuccessString;
@property(nonatomic, copy  ) NSString *enterDescString;
@property(nonatomic, copy  ) NSString *confirmString;

- (void)setupCloudRegionName:(NSString *)regionName
                  bucketName:(NSString *)bucketName;

/// 提交结果回掉, state==-1:没有填写描述无法提交, state==0:提交失败  state==1:提交成功
@property (nonatomic, copy) void (^submitHandler)(NSUInteger state);

@end

NS_ASSUME_NONNULL_END
