//
//  WYLFriendCircleVC.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/22.
//  Copyright © 2017年 wyl. All rights reserved.
//
#import "FCTextView.h"
#import "WYLFriendCircleVC.h"
#import "FriendCircleData.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface WYLFriendCircleVC ()<UITextViewDelegate,UITableViewDelegate, UITableViewDataSource>{
    
    IBOutlet UIView *theHeadView;
    IBOutlet UIView *theFootView;
    IBOutlet UILabel *footDesLb;//底部加载label
    IBOutlet UIActivityIndicatorView *activityView;//底部等待圈
    IBOutlet UIView *approveAndcommentView;//点赞view
    IBOutlet UIButton *approveBt;//点赞btn
    
    /*
     1文本输入框用UITextField还是用UITextView ,用UITextView，而UITextField只是用来触发键盘，然后设置inputAccessView
     2键盘的自适应inputaccessviw自适应高度怎么来做
     */
    IBOutlet UIView *inputAccessView;
    IBOutlet UIView *keyBoardHeadV;
    IBOutlet FCTextView *fcTextView;

    NSMutableArray *fcDataAry;//数据数组
    NSInteger currentPage; // 当前页
    BOOL isNext;// 是否还有下一页
    
    float positionY; // 键盘顶部的位置
    float keyHight; // 键盘高度
    UITextField *theTextField;
    UITableView *theTableView;
    
}

- (IBAction)approveBt:(UIButton*)sender;
- (IBAction)messageBt:(UIButton*)sender;

@end

@implementation WYLFriendCircleVC

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"U17";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    currentPage = 0;//设置初始值为第0页
    isNext = YES;
    fcDataAry = [NSMutableArray new];
    
    theTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:theTextField];
    
    [inputAccessView removeFromSuperview];
    theTextField.returnKeyType = UIReturnKeySend;
    theTextField.inputAccessoryView = inputAccessView;
    fcTextView.returnKeyType = UIReturnKeySend;
    
    //给inputAccessView添加手势,点击消失键盘
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInputView:)];
    [inputAccessView addGestureRecognizer:tapGes];
    
    [approveAndcommentView removeFromSuperview];
    
    theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    theTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    theTableView.delegate   = self;
    theTableView.dataSource = self;
    theTableView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:theTableView];
    
    [theHeadView removeFromSuperview];
    [theFootView removeFromSuperview];
    
    [theTableView setTableHeaderView:theHeadView];
    [theTableView setTableFooterView:theFootView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self netLoadData:currentPage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)approveBt:(UIButton*)sender{

}

- (IBAction)messageBt:(UIButton*)sender{
    
}

#pragma mark - loadData

/**
 加载数据调用的方法

 @param pageNum 第几页
 */
- (void)netLoadData:(NSInteger)pageNum{
    
    if (!isNext) {
        return;
    }
    
    NSDictionary *backInfoDict = [FriendCircleData backFriendCircleData:pageNum];
    
    //得到数据并赋值
    [fcDataAry addObjectsFromArray:[backInfoDict objectForKey:@"data"]];
    currentPage = [[backInfoDict objectForKey:@"page"] integerValue];
    isNext = [[backInfoDict objectForKey:@"isNext"] boolValue];
    
    //如果小于5页可以加载
    if (isNext) {
        footDesLb.text = @"        正在加载...";
        [activityView startAnimating];
    }else{
        footDesLb.text = @"数据已加载完";
        [activityView stopAnimating];
    }
    
    [theTableView reloadData];

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
