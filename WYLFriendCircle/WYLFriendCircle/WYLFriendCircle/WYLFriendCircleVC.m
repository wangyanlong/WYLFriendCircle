//
//  WYLFriendCircleVC.m
//  WYLFriendCircle
//
//  Created by wyl on 2017/5/22.
//  Copyright © 2017年 wyl. All rights reserved.
//
#import "FCImageViewCtr.h"
#import "FCLinkViewCtr.h"
#import "FCTextView.h"
#import "WYLFriendCircleVC.h"
#import "FriendCircleData.h"
#import "FriendCircleCell.h"
#import "CellMessageCell.h"

@interface WYLFriendCircleVC ()<UITextViewDelegate,UITableViewDelegate, UITableViewDataSource,FriendCircleCellDelegate>{
    
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
    
    FCImageViewCtr *fcImageVCtr;
    
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
    
    fcImageVCtr = [[FCImageViewCtr alloc] init];
    
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
    [self addFlushViewFromSeverDataFct];

    [NSThread detachNewThreadSelector:@selector(threadReviveMessage) toTarget:self withObject:nil];

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

//被动加载
- (void)threadReviveMessage{
    
    return;
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(netDataFromService) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
    
}

- (void)netDataFromService{
    
    static int __testCount = 10;

    NSString *messageID = [@(__testCount) description];
    
    for (int i = 0; i < fcDataAry.count; i++) {
        
        WYLFCModel *model = fcDataAry[i];
        if ([model.timeStp isEqualToString:messageID]) {
            
            // 这条记录需要更新，更新的是留言评论
            //0(楼主回复XX:) 1(XX回复楼主:) 2(楼主回复:) 3(XX回复:)
            
            NSMutableDictionary *messDict = [NSMutableDictionary dictionary];
            [messDict setObject:messageID forKey:@"name"];
            [messDict setObject:[messageID stringByAppendingString:@"text"] forKey:@"msg"];
            [messDict setObject:@"3" forKey:@"status"];
            
            model.isFlush = YES;
            [model.messageAry addObject:messDict];
            [model.cellContentAry addObject:[WYLFCModel setMessageDict:messDict]];
            
        }
        
    }
    // 苏醒主线程runloop
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CFRunLoopWakeUp(CFRunLoopGetMain());
    });
}

//刷新被动加载的数据
- (void)addFlushViewFromSeverDataFct{
    
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
       
        static int flushPinlv = 0;
        flushPinlv++;
        
        if (flushPinlv%2) {
            
            NSArray *visibleCellAry = [theTableView visibleCells];
            NSMutableArray *flushIndexPath = [NSMutableArray new];
            
            for (int i = 0; i < visibleCellAry.count; i++) {
                
                FriendCircleCell *cell = visibleCellAry[i];
                if (cell.cellModel.isFlush) {
                    [flushIndexPath addObject:[theTableView indexPathForCell:cell]];//保存index
                }
                
            }
            
            if (flushIndexPath.count > 0){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [theTableView reloadRowsAtIndexPaths:flushIndexPath withRowAnimation:UITableViewRowAnimationNone];
                });
                
            }
            
        }
        
    });
    
    CFRunLoopAddObserver(CFRunLoopGetMain(), observerRef, kCFRunLoopDefaultMode);
    
}

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

#pragma mark -tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fcDataAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [FriendCircleCell fcCellHeight:[fcDataAry objectAtIndex:indexPath.row]];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FriendCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendCircleCell" owner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.fcMessageBt addTarget:self action:@selector(pressMessageBt:) forControlEvents:UIControlEventTouchUpInside];
        cell.delegate = self;
    }
    cell.tag = indexPath.row;
    cell.fcMessageBt.tag = indexPath.row;
    cell.cellModel = [fcDataAry objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark -FriendCircleCell delegate

- (void)hiddenSubMenu{
    
    if ([approveAndcommentView superview]) {
        
        [UIView animateWithDuration:0.4 animations:^{
        
            approveAndcommentView.frame = ({
            
                CGRect rect = approveAndcommentView.frame;
                rect.origin.x = CGRectGetMaxX(approveAndcommentView.frame) + 10;
                rect;
                
            });
            
        } completion:^(BOOL finished) {
            
            [approveAndcommentView removeFromSuperview];
            
        }];
        
    }
    
}

- (void)pressMessageBt:(UIButton *)sender{

    //当点赞留言view显示的时候,消失
    if ([approveAndcommentView superview] == [sender superview]) {
        
        [self hiddenSubMenu];
        
        return;
        
    }
    
    [approveAndcommentView removeFromSuperview];
    
    UIView *tmpSuperV = [sender superview];
    [tmpSuperV addSubview:approveAndcommentView];
    [tmpSuperV bringSubviewToFront:sender];
    
    CGRect tmpRect = approveAndcommentView.frame;
    tmpRect.origin.x = sender.frame.origin.x;
    approveAndcommentView.frame = tmpRect;
    approveAndcommentView.hidden = NO;
    
    
}

- (void)cellImagePress:(NSInteger)index images:(NSArray *)imageAry{
    fcImageVCtr.startIndex = index;
    fcImageVCtr.imagAry = imageAry;
    [fcImageVCtr.view setFrame:[UIScreen mainScreen].bounds];
    [self.view.window addSubview:fcImageVCtr.view];
}

- (void)cellLinkPress:(NSDictionary *)linkInfo{
    FCLinkViewCtr *linkLiewCtr = [[FCLinkViewCtr alloc] init];
    linkLiewCtr.urlStr = [linkInfo objectForKey:@"url"];
    linkLiewCtr.title = [linkInfo objectForKey:@"text"];
    [self.navigationController pushViewController:linkLiewCtr animated:YES];
}

- (void)cellSelectSendMessage:(FriendCircleCell*)cell subCell:(CellMessageCell *)subCell{
    
    fcTextView.fcCell = cell;
    fcTextView.messageCell = subCell;
    UITableView *tableV = (UITableView*)[[subCell superview] superview];
    positionY = cell.frame.origin.y + tableV.frame.origin.y + CGRectGetMaxY(subCell.frame);
    [theTextField becomeFirstResponder];
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
