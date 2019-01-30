// EMAppLanViewController.m 
// Emax_DebugKit 
// 
// Created by HCC on 2018/12/24. 
//  
//

#import "EMAppLanViewController.h"
#import "EMAppLanguage.h"
#import "NSBundle+DebugKit.h"
#import "EMDebugManager.h"
@interface EMAppLanViewController ()

@property(nonatomic, strong) NSMutableArray *listLan;

@end

@implementation EMAppLanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"app语言设置";
    self.tableView.tableFooterView = [UIView new];
    
    self.listLan = [NSMutableArray arrayWithObject:@"自适应"];
    [self.listLan addObjectsFromArray:[EMAppLanguage supportLanguageDictionary].allKeys];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSString *curLan = [EMAppLanguage currentCustomLanguage];
    NSUInteger target = 0;
    for (int i = 0; i < self.listLan.count; i++) {
        NSString *lan = self.listLan[i];
        if ([curLan isEqualToString:lan]) {
            target = i;
            break;
        }
    }
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:target inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([EMAppLanguage customLanguageEnable] == NO) {
        return 1;
    }
    return self.listLan.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([EMAppLanguage customLanguageEnable] == NO) {
        UITableViewCell *tipCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tipcell"];
        tipCell.accessoryType = UITableViewCellAccessoryNone;
        tipCell.separatorInset = UIEdgeInsetsZero;
        tipCell.textLabel.text = @"app未启用多语言切换功能";
        return tipCell;
    }
    static NSString *ID = @"defaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.separatorInset = UIEdgeInsetsZero;
        
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
        UIImageView *icon = [[UIImageView alloc] init];
        NSBundle *bundle = [NSBundle bundleWithBundleName:@"EMDebugKit" podName:@"Emax_DebugKit"];
        icon.image = [UIImage imageNamed:@"xuanzhong" inBundle:bundle compatibleWithTraitCollection:nil];
        icon.frame = CGRectMake(tableView.frame.size.width - 60, 15, 20, 20);
        [view addSubview:icon];
        cell.selectedBackgroundView = view;
    }
    cell.textLabel.text = self.listLan[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    UILabel *lb = [UILabel new];
    lb.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];;
    lb.font = [UIFont systemFontOfSize:16];
    lb.numberOfLines = 0;
    lb.text = [NSString stringWithFormat:@"%@",@"语言设置是为了方便测试本地化词汇是否正常。如果不支持设置的语言将默认加载英文。"];
    lb.frame = CGRectMake(20, 0, tableView.frame.size.width - 40, 80);
    [view addSubview:lb];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([EMAppLanguage customLanguageEnable] == NO) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    NSString *lan;
    if (indexPath.row == 0) {
        lan = nil;
    }else{
        lan = self.listLan[indexPath.row];
    }
    if ([[EMAppLanguage currentCustomLanguage] isEqualToString:lan]) {
        return;
    }
    __weak  typeof(self)this = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"切换语言将重新启动app" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [this.navigationController popViewControllerAnimated:YES];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [EMAppLanguage setCustomLanguage:lan];
        [EMDebugManager exitApplication];
    }]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
