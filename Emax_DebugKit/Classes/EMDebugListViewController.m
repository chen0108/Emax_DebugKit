// EMDebugListViewController.m 
// Emax_DebugKit 
// 
// Created by HCC on 2018/12/24. 
//  
//

#import "EMDebugListViewController.h"
#import "EMFactoryViewController.h"
#import "EMAppLanViewController.h"
#import "EMLogViewController.h"
#import "EMAppLanguage.h"
#import "EMLogManager.h"

@interface EMDebugListViewController ()

@property(nonatomic, strong) NSMutableArray *stateArray;

@end

@implementation EMDebugListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"EMAX DEBUG";
    // Uncomment the following line to preserve selection between presentations.
    self.view.backgroundColor = UIColor.whiteColor;
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.tableFooterView = [UIView new];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
    self.stateArray = [NSMutableArray arrayWithObjects:@"",@"",@"",nil];
    if ([EMLogManager hasEnableRedirectLog] == NO) {
        [self.stateArray replaceObjectAtIndex:2 withObject:@"(当前不支持)"];
    }
}

static NSString *listName[] = {
    @"模式切换",
    @"语言切换",
    @"日志管理",
};

static NSString *listClass[] = {
    @"EMFactoryViewController",
    @"EMAppLanViewController",
    @"EMLogViewController",
};

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"defaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.separatorInset = UIEdgeInsetsZero;
    }
    NSString *state = self.stateArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@ %@",@(indexPath.row+1),listName[indexPath.row],state];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *state = self.stateArray[indexPath.row];
    if (state.length > 0) {
        return;
    }
    Class vcClass = NSClassFromString(listClass[indexPath.row]);
    UIViewController *vc = [vcClass alloc];
    if ([vc respondsToSelector:@selector(initWithStyle:)]) {
        vc = [(UITableViewController *)vc initWithStyle:UITableViewStyleGrouped];
    }else{
        vc = [vc init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}


@end
