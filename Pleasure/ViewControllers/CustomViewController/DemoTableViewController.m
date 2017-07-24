//
//  DemoTableViewController.m
//  Pleasure
//
//  Created by Sper on 2017/7/5.
//  Copyright © 2017年 WM. All rights reserved.
//

#import "DemoTableViewController.h"

@interface DemoTableViewController ()
@property (nonatomic , strong)UIColor *orginColor;
@end

@implementation DemoTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.title = @"table";
    
    UILabel * llll = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    llll.textColor = [UIColor blackColor];
    llll.font = [UIFont systemFontOfSize:20];
    llll.text = @"table";
    self.navigationItem.titleView = llll;
    
    
    [self showBackItem];
    
}

- (void)showBackItem {
    UIImage * image = [UIImage imageNamed:@"icon_white_back"];
    UIButton* btn = [UIButton buttonWithImage:image title:@"返回" target:self action:@selector(backItemAction:)];
    btn.frame = CGRectMake(btn.frame.origin.x, btn.frame.origin.y, 56, 28);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    btn.adjustsImageWhenHighlighted = NO;
    [self addItemForLeft:YES withItem:item spaceWidth:-8];
}
-(void)addItemForLeft:(BOOL)left withItem:(UIBarButtonItem*)item spaceWidth:(CGFloat)width {
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil action:nil];
    space.width = width;
    if (left) {
        self.navigationItem.leftBarButtonItems = @[space,item];
    } else {
        self.navigationItem.rightBarButtonItems = @[space,item];
    }
}
- (void)backItemAction:(UIButton *)button{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationStringTabBarController object:@1];
}
- (UIView *)loadNavigationHeaderView{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor pageBackgroundColor];
    return view;
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
