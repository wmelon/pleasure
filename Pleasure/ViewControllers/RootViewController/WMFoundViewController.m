//
//  WMFoundViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/25.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "WMFoundViewController.h"
#import "Demo2ViewController.h"

@interface WMFoundViewController ()
@property (nonatomic , strong)UIImageView *imageView;
@end

@implementation WMFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    UIImage *image = [UIImage imageNamed:@"pc_bg"];
    imageView.userInteractionEnabled = YES;
    imageView.image =image;
    [self.view addSubview:imageView];
    
    self.imageView = imageView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(present)];
    [imageView addGestureRecognizer:tap];
}
- (void)present{
    Demo2ViewController * vc = [Demo2ViewController new];
    vc.srcImageView = self.imageView;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
