//
//  RootViewController.m
//  InputViewDemo
//
//  Created by shenhongbang on 16/3/25.
//  Copyright © 2016年 shenhongbang. All rights reserved.
//

#import "RootViewController.h"
#import "SHBToolView.h"

@interface RootViewController ()<SHBToolViewDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation RootViewController {
    UITableView         *_tableView;
    
    
    SHBToolView         *_toolView;
    UILabel             *_hubLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    
    [self configToolView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), _toolView.frame.origin.y) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view bringSubviewToFront:_toolView];
    
    UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedTableView)];
    [_tableView addGestureRecognizer:tap];
}

- (void)clickedTableView {
    [self.view endEditing:true];
}

- (void)configToolView {
    
    _toolView = [SHBToolView toolView];
    _toolView.delegate = self;
    [self.view addSubview:_toolView];
    
    [_toolView addActionWithImage:[UIImage imageNamed:@"chat_add_image_nm"] title:@"图片" tag:100];
    [_toolView addActionWithImage:[UIImage imageNamed:@"chat_add_paizhao_nm"] title:@"拍照" tag:101];
    [_toolView addActionWithImage:[UIImage imageNamed:@"chat_add_video_nm"] title:@"视频" tag:102];
    [_toolView addActionWithImage:[UIImage imageNamed:@"位置icon-0"] title:@"位置" tag:103];
    
    _hubLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    _hubLabel.backgroundColor = [UIColor lightGrayColor];
    _hubLabel.textColor = [UIColor purpleColor];
    _hubLabel.center = self.view.center;
    _hubLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_hubLabel];
    _hubLabel.hidden = true;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"section:%ld   row:%ld", (long)indexPath.section, (long)indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - 重置TableView大小
- (void)reSetTableViewFrameAndScrollToBottom:(BOOL)toBottom animation:(BOOL)acimation {
    _tableView.frame = CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), _toolView.frame.origin.y);
    if (toBottom) {
        [_tableView scrollRectToVisible:CGRectMake(0, _tableView.contentSize.height - 1, CGRectGetWidth(_tableView.frame), 1) animated:acimation];
    }
}

- (void)reSetTableViewFrameAndScrollToBottom:(BOOL)toBottom  {
    [self reSetTableViewFrameAndScrollToBottom:toBottom animation:false];
}



#pragma mark - SHBToolViewDelegate
- (void)toolViewLongPressToRecord:(UILongPressGestureRecognizer *)longPress {
    NSLog(@"longPressState:%ld", (long)longPress.state);
    
    CGPoint point = [longPress locationInView:self.view];
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            _hubLabel.hidden = false;
            _hubLabel.text = @"开始";
            break;
        }
        case UIGestureRecognizerStateChanged: {
            _hubLabel.text = [NSString stringWithFormat:@"%@", NSStringFromCGPoint(point)];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            _hubLabel.hidden = true;
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            _hubLabel.hidden = true;
            break;
        }
            
        default:
            break;
    }
}

- (void)toolViewClickedAction:(NSString *)title actionTag:(NSInteger)tag {
    NSLog(@"title:<%@>    tag:%ld", title, (long)tag);
}

- (void)toolViewShouldReturn:(NSString *)content {
    NSLog(@"content:<%@>", content);
    _toolView.text = nil;
}

- (void)toolViewDidChangeKeyboardFrame:(CGRect)frame {
    NSLog(@"%s", __FUNCTION__);
    [self reSetTableViewFrameAndScrollToBottom:true animation:true];
}


@end
