//
//  ViewController.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/22.
//  Copyright © 2017年 wyl. All rights reserved.
//

#import "WYLFriendCircleVC.h"
#import "ViewController.h"
#import "FriendCircleData.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [FriendCircleData imageUrlFromFile];

}

- (IBAction)pressBt:(id)sender{
 
    WYLFriendCircleVC *wxfcCtr = [[WYLFriendCircleVC alloc] init];
    
    [self.navigationController pushViewController:wxfcCtr animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
