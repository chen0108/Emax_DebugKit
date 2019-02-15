//
// EMLogManager.m
// Emax_DebugAid
//
// Created by HCC on 2018/12/23.
//
//

#import "EMLogManager.h"
#import "sys/utsname.h"

@interface NSDate (Log)

@end

@implementation NSDate (Log)

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:format];
    NSDate *date = [inputFormatter dateFromString:string];
    return date;
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:self];
}

- (NSInteger)distanceDaysIgnoreTimeToDate:(NSDate *) aDate {
    NSString *selfStr = [self stringWithFormat:@"yyyyMMdd"];
    NSString *comStr = [aDate stringWithFormat:@"yyyyMMdd"];
    NSDate *com = [NSDate dateFromString:comStr withFormat:@"yyyyMMdd"];
    NSDate *com1 = [NSDate dateFromString:selfStr withFormat:@"yyyyMMdd"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar
                                        components:NSCalendarUnitDay fromDate:com toDate:com1 options:0];
    return labs([dateComponents day]);
}


- (NSDate *)dateByAddingDays:(NSInteger)days {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + 86400 * days;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (BOOL)isEarlierThanDate:(NSDate *) aDate {
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)isToday {
    if (fabs(self.timeIntervalSinceNow) >= 60 * 60 * 24) return NO;
    return [[NSDate new] day] == self.day;
}

- (NSInteger)year {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)month {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

- (NSInteger)day {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day];
}

- (NSInteger)hour {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:self] hour];
}

- (NSInteger)minute {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:self] minute];
}

- (NSInteger)second {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:self] second];
}

@end

/* *************************-*************************-************************* */
/*                                                                               */
/* <##>                                                                         */
/*                                                                               */
/* *************************-*************************-************************* */


@implementation EMLogManager

static NSMutableString *_logStr;

static NSUInteger _state;
+ (void)setRedirectLogState:(RedirectLogState)state{
    _state = state;
    switch (state) {
        case RedirectLogToText:
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self redirectToText];
            break;
        case RedirectLogToFile:
            NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self redirectToFile];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redirectToFile) name:UIApplicationWillEnterForegroundNotification object:nil];
            break;
    }
}

+ (RedirectLogState)currentLogState{
    return _state;
}
/**
 *  获取异常崩溃信息
 */
void UncaughtExceptionHandler(NSException *exception) {
    NSArray *callStack = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *content = [NSString stringWithFormat:@"\n========  异常错误报告  ========\n位置:%s\nname:%@\nreason:%@\ncallStackSymbols:\n%@\n", __FUNCTION__,name,reason,[callStack componentsJoinedByString:@"\n"]];
    NSLog(@"\n%@\n",content);
    //把异常崩溃信息发送至开发者
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [EMLogManager reportLogResult:^(BOOL isSuccess) {
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}


/* ============================================================ */
#pragma mark - 重定向日志到self
/* ============================================================ */

+ (void)redirectToText{
    [self redirectSTD:STDOUT_FILENO];
    [self redirectSTD:STDERR_FILENO];
}

+ (NSString *)currentLog{
    if (_logStr == nil) {
        _logStr = [NSMutableString string];
    }
    return _logStr;
}

+ (void)redirectSTD:(int )fd{
    NSPipe * pipe = [NSPipe pipe] ;// 初始化一个NSPipe 对象
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle]; // 注册通知
    [pipeReadHandle readInBackgroundAndNotify];
}

+ (void)redirectNotificationHandle:(NSNotification *)nf{ // 通知方法
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (_logStr == nil) {
        _logStr = [NSMutableString string];
    }
    [_logStr appendString:[NSString stringWithFormat:@"\n%@",str]];
    [[nf object] readInBackgroundAndNotify];
}

/* ============================================================ */
#pragma mark - 模式二:本地文件保存日志, 支持日志上传
/* ============================================================ */

+ (void)redirectToFile{
    [self clearHistoryBeforeDays:15];
    NSString *logFile = [self currentLogFilePath];
    //log写入
    freopen([logFile cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    freopen([logFile cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
}

// 文件命名规则
+ (NSString *)currentLogFilePath{
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceName = device.name;
    NSString *subUUID = [[device.identifierForVendor UUIDString] substringToIndex:6];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *displayName = [infoDic objectForKey:@"CFBundleDisplayName"];
    
    NSString *ver = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDic objectForKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@b%@",ver,build];
    
    NSString *day = [[NSDate date] stringWithFormat:@"yyMMdd"];
    //创建文件路径 文件名不能含有非法字符
    //displayName+3323F5++iPhone XR=> 1.0.1b5 => 181121.log
    NSString *documentpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathCreDirAt = [NSString stringWithFormat:@"%@/ELog",documentpath];
    NSError *errorDirectory = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:pathCreDirAt withIntermediateDirectories:YES attributes:nil error:&errorDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@+%@=%@=%@=>%@.log",displayName,subUUID,deviceName,appVersion,day];
    NSString *logFilePath = [pathCreDirAt stringByAppendingPathComponent:fileName];
    return logFilePath;
}

static NSString *_bucketName = nil;
static NSString *_regionName= nil;
+ (void)setupCloudRegionName:(NSString *)regionName
                  bucketName:(NSString *)bucketName{
    _bucketName = bucketName;
    _regionName = regionName;
}

+ (BOOL)haveConfixCloud{
    return _bucketName && _regionName;
}

///初始化一个上传事件的手势
+ (UIGestureRecognizer *)setupGestureTapCount:(NSUInteger)count{
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(report)];
    ges.numberOfTapsRequired = count;
    return ges;
}

///上传事件
+ (void)report{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Do you want to upload logs to help developers solve exceptions?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [EMLogManager reportLogResult:^(BOOL isSuccess) {
            
        }];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
}

///上报日志
+ (void)reportLogResult:(void (^)(BOOL))handle{
    if (_bucketName == nil || _regionName == nil) {
        //默认上传路径
        [self setupCloudRegionName:@"ap-chengdu" bucketName:@"testhcc-1256637689"];
    }
    ///其他业务
    
    ///上传日志
    [self uploadLogResult:handle];
}

+ (void)uploadLogResult:(void (^)(BOOL))handle{
    NSArray *listFile = [self getLogListFile];
    NSUInteger targetCount = listFile.count;
    if (targetCount == 0) {
        handle(YES);
        return;
    }
    __block BOOL uploadError = NO;
    
    __block NSUInteger completeCount = 0;
    for (int i = 0; i < targetCount; i++) {
        NSString *filePath = listFile[i];
        NSString *fileName = [[filePath componentsSeparatedByString:@"/"] lastObject];
        NSString *host = [NSString stringWithFormat:@"%@.cos.%@.myqcloud.com",_bucketName,_regionName];
        //接口地址
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@",host]];
        NSString *theBoundary = [NSString stringWithFormat:@"myBoundary%uend",arc4random_uniform(255)];
        //访问请求
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.allHTTPHeaderFields = @{@"Host":host};
        request.HTTPMethod = @"POST";
        request.timeoutInterval = 6;
        NSMutableData *data = [NSMutableData data];
        //拼接第一个参数key
        [data appendData:[[NSString stringWithFormat:@"--%@\r\n", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[@"Content-Disposition:form-data;name=\"key\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[fileName dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //拼接第二个参数file
        [data appendData:[[NSString stringWithFormat:@"--%@\r\n", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data;name=\"file\";filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[@"Content-Type:text/plain" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]]];
        [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //拼接结束标志
        [data appendData:[[NSString stringWithFormat:@"--%@--", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        request.HTTPBody = data;
        [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@", theBoundary] forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%@", @(data.length)] forHTTPHeaderField:@"Content-Length"];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSUInteger code = ((NSHTTPURLResponse*)response).statusCode;
            BOOL fail = code>300 || code==0;
            uploadError = uploadError || fail;
            if (fail == NO) {//上传成功后删除文件
                if ([self distanceToday:filePath] != 0) {
                    [self removeFileOfPath:filePath];
                }
            }
            completeCount++;
            if (completeCount == targetCount) {//任务结束
                handle(uploadError==NO);
            }
        }];
        [dataTask resume];
    }
}

// day == 15 清除15天前的日志
+ (void)clearHistoryBeforeDays:(NSInteger)day{
    NSArray *list = [self getLogListFile];
    for (NSString *path in list) {
        NSInteger distance = [self distanceToday:path];
        if (distance < day*(-1)) {
            [self removeFileOfPath:path];
        }
    }
}

///获取日志文件列表
+ (NSArray *)getLogListFile{
    NSString *documentpath = [NSString stringWithFormat:@"%@/ELog",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentpath error:&error];
    NSMutableArray *logFiles = [NSMutableArray new];
    if (error) {
        NSLog(@"getFileListInFolderWithPathFailed, errorInfo:%@",error);
    }else{
        for (int i = 0; i < fileList.count; i++) {
            NSString *fileName = fileList[i];
            if (fileName.length < 10) {
                continue;
            }
            if (![fileName hasSuffix:@"log"]) {
                continue;
            }
            NSString *day = [fileName substringWithRange:NSMakeRange(fileName.length-10, 6)];
            NSDate *date = [NSDate dateFromString:day withFormat:@"yyMMdd"];
            if (date == nil) {
                continue;
            }
            [logFiles addObject:[NSString stringWithFormat:@"%@/%@",documentpath,fileName]];
        }
    }
    return logFiles;
}

/// 查询logpath是几天前的日志
+ (NSInteger)distanceToday:(NSString *)logPath{
    NSDate *today = [NSDate date];
    NSString *fileName = [[logPath componentsSeparatedByString:@"/"] lastObject];
    if (fileName.length < 10) {
        return 0;
    }
    if (![fileName hasSuffix:@"log"]) {
        return 0;
    }
    NSString *day = [fileName substringWithRange:NSMakeRange(fileName.length-10, 6)];
    NSDate *date = [NSDate dateFromString:day withFormat:@"yyMMdd"];
    if (date == nil) {
        return 0;
    }
    return [date distanceDaysIgnoreTimeToDate:today];
}

//从path路径中移除文件
+ (BOOL)removeFileOfPath:(NSString *)path{
    BOOL flag = YES;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:path]) {
        if (![fileManage removeItemAtURL:[NSURL fileURLWithPath:path] error:nil]) {
            flag = NO;
        }
    }
    if ([self distanceToday:path] == 0) {
        [self redirectToFile];
    }
    return flag;
}

///设备型号
+ (NSString *)getDeviceModel{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

@end



