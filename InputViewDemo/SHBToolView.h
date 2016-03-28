//
//  SHBToolView.h
//  InputViewDemo
//
//  Created by shenhongbang on 16/3/25.
//  Copyright © 2016年 shenhongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHBToolViewDelegate <NSObject>

- (void)toolViewClickedAction:(NSString *)title actionTag:(NSInteger)tag;
- (void)toolViewLongPressToRecord:(UILongPressGestureRecognizer *)longPress;
- (void)toolViewShouldReturn:(NSString *)content;

@optional
- (void)toolViewDidChangeKeyboardFrame:(CGRect)frame;

@end

@interface SHBToolView : UIView

@property (nonatomic, assign) id<SHBToolViewDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL            isEditing;
@property (nonatomic, copy) NSString                    *text;


+ (SHBToolView *)toolView;

- (void)bottom;
- (void)addActionWithImage:(UIImage *)img title:(NSString *)title tag:(NSInteger)tag;

@end
