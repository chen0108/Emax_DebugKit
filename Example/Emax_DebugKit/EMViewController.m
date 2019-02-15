//
//  EMViewController.m
//  Emax_DebugKit
//
//  Created by chen0108_mbp on 12/24/2018.
//  Copyright (c) 2018 chen0108_mbp. All rights reserved.
//

#import "EMViewController.h"

@interface EMViewController ()

@end

@implementation EMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = [NSString stringWithFormat:@"页面%ld",self.navigationController.viewControllers.count];
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0
                                                green:arc4random_uniform(256)/255.0
                                                 blue:arc4random_uniform(256)/255.0
                                                alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nextPage:(id)sender {
    NSLog(@"%@",@"进入下一界面");
    NSArray *arr = @[@1,@1];
    NSString *r = arr[5];
}

@end
