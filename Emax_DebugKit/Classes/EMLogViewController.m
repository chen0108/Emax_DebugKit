// EMLogViewController.m 
// Emax_DebugAid
//
// Created by HCC on 2018/12/24.
//
//

#import "EMLogViewController.h"
#import "EMLogManager.h"
#import "EMLogSubmitViewController.h"

@interface EMLogDetailViewController : UIViewController<UIDocumentInteractionControllerDelegate>

@property(nonatomic, copy  ) NSString *filePath;
@property (nonatomic, strong) UIDocumentInteractionController *documentVC;

@end

@implementation EMLogDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UITextView *text = [UITextView new];
    text.editable = NO;
    text.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44 - [UIApplication sharedApplication].statusBarFrame.size.height);
    text.textColor = UIColor.blackColor;
    text.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:text];
    text.text = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStyleDone target:self action:@selector(share)];
    if (self.filePath.length > 10) {
        self.title = [self.filePath substringFromIndex:self.filePath.length-10];
    }
}

- (void)share{
    NSURL *fileUrl = [NSURL fileURLWithPath:self.filePath];
    self.documentVC = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
    self.documentVC.delegate = self;
    [self.documentVC presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

@end




@interface EMLogViewController ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) UIDocumentInteractionController *documentVC;

@end

@implementation EMLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日志列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上传服务器" style:UIBarButtonItemStyleDone target:self action:@selector(didClickPush)];
    self.tableView.tableFooterView = [UIView new];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSArray *list = [EMLogManager getLogListFile];
    self.list = [NSMutableArray arrayWithArray:list];
    [self.tableView reloadData];
}


- (void)didClickPush{
    [self.navigationController pushViewController:[EMLogSubmitViewController new] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"defaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.separatorInset = UIEdgeInsetsZero;
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(share:)];
        lpgr.minimumPressDuration = 1;
        [cell addGestureRecognizer:lpgr];
    }
    NSString *fullPath = self.list[indexPath.row];
    cell.textLabel.text = fullPath;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EMLogDetailViewController *detailVC = [EMLogDetailViewController new];
    detailVC.filePath = self.list[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)share:(UILongPressGestureRecognizer *)gestureRecognizer {
    UITableViewCell *cell = (UITableViewCell*)gestureRecognizer.view;
    NSURL *fileUrl = [NSURL fileURLWithPath:cell.textLabel.text];
    self.documentVC = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
    self.documentVC.delegate = self;
    [self.documentVC presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    UILabel *lb = [UILabel new];
    lb.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];;
    lb.font = [UIFont systemFontOfSize:16];
    lb.numberOfLines = 0;
    lb.text = @"只保留最近15天的日志记录,过期后自动删除,长按可以分享日志。";
    lb.frame = CGRectMake(20, 10, tableView.frame.size.width - 40, 60);
    [view addSubview:lb];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [EMLogManager removeFileOfPath:self.list[indexPath.row]];
        [self.list removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


@end

