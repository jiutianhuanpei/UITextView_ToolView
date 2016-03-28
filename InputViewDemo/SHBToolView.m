//
//  SHBToolView.m
//  InputViewDemo
//
//  Created by shenhongbang on 16/3/25.
//  Copyright © 2016年 shenhongbang. All rights reserved.
//

#import "SHBToolView.h"

@interface Action : NSObject

@property (nonatomic, strong) UIImage *img;
@property (nonatomic, copy) NSString    *title;
@property (nonatomic, assign) NSInteger tag;

@end
@implementation Action

@end

@interface EmojiCell : UICollectionViewCell

@property (nonatomic, strong) UILabel   *title;

@end

@implementation EmojiCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _title = [[UILabel alloc] initWithFrame:self.bounds];
        _title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_title];
    }
    return self;
}

@end

@interface ActionCell : UICollectionViewCell

- (void)configAction:(Action *)action;

@end

@implementation ActionCell {
    UIImageView     *_img;
    UILabel         *_title;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(frame), CGRectGetHeight(frame) - 30)];
        _img.contentMode = UIViewContentModeCenter;
        [self addSubview:_img];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_img.frame), CGRectGetWidth(frame), 20)];
        _title.font = [UIFont systemFontOfSize:15];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.textColor = [UIColor darkGrayColor];
        [self addSubview:_title];
    }
    return self;
}

- (void)configAction:(Action *)action {
    _img.image = action.img;
    _title.text = action.title;
}


@end

CGFloat toolBtnW = 40, toolInputH = 60;
CGFloat toolBottomH = 200;

@interface SHBToolView ()<UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation SHBToolView {
    UIButton        *_voice;
    UITextView      *_textView;
    UIButton        *_emoji;
    UIButton        *_add;
    UIView          *_boView;
    
    UIButton        *_recordBtn;
    
    BOOL            _isVoice;
    
    BOOL            _isEmoji;
    
    UICollectionViewFlowLayout  *_layout;
    UICollectionView    *_collectionView;
    NSMutableArray      *_emojis;
    NSMutableArray      *_actions;
    
    UILongPressGestureRecognizer    *_longPress;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (SHBToolView *)toolView {
    SHBToolView *to = [[SHBToolView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - toolInputH, CGRectGetWidth([UIScreen mainScreen].bounds), toolInputH + toolBottomH)];
    return to;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat y = 10;
        _actions = [[NSMutableArray alloc] initWithCapacity:0];
//        _voice = [self createBtn:@"🎤" action:@selector(voice:) frame:CGRectMake(5, y, toolBtnW, toolBtnW)];
//        _add = [self createBtn:@"➕" action:@selector(addBtn:) frame:CGRectMake(CGRectGetWidth(frame) - 5 - toolBtnW, y, toolBtnW, toolBtnW)];
//        _emoji = [self createBtn:@"😂" action:@selector(emoji:) frame:CGRectMake(CGRectGetMinX(_add.frame) - 5 - toolBtnW, y, toolBtnW, toolBtnW)];
        
        _voice = [self createBtnWithImage:[UIImage imageNamed:@"bohao_btn_handfree_nm"] selectedImg:[UIImage imageNamed:@"bohao_btn_handfree_pre"] action:@selector(voice:) frame:CGRectMake(5, y, toolBtnW, toolBtnW)];
        _add = [self createBtnWithImage:[UIImage imageNamed:@"chat_add_pre"] selectedImg:nil action:@selector(addBtn:) frame:CGRectMake(CGRectGetWidth(frame) - 5 - toolBtnW, y, toolBtnW, toolBtnW)];
        _emoji = [self createBtnWithImage:[UIImage imageNamed:@"chat_biaoqing_nm"] selectedImg:[UIImage imageNamed:@"chat_biaoqing_pre"] action:@selector(emoji:) frame:CGRectMake(CGRectGetMinX(_add.frame) - 5 - toolBtnW, y, toolBtnW, toolBtnW)];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_voice.frame) + 5, y, CGRectGetMinX(_emoji.frame) - 10 - CGRectGetMaxX(_voice.frame), toolBtnW)];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _textView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        _textView.layer.cornerRadius = 4;
        [self addSubview:_textView];
        
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordBtn.backgroundColor = [UIColor whiteColor];
        _recordBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _recordBtn.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        _recordBtn.layer.cornerRadius = 4;
        [_recordBtn setTitle:@"长按录音" forState:UIControlStateNormal];
        [_recordBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _recordBtn.frame = _textView.frame;
        
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [_recordBtn addGestureRecognizer:_longPress];
        
        [self addSubview:_recordBtn];
        [self bringSubviewToFront:_textView];
        _isVoice = false;
        
        _boView = [[UIView alloc] initWithFrame:CGRectMake(0, toolInputH, CGRectGetWidth(frame), toolBottomH)];
        _boView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:_boView];
        
        _emojis = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSArray *temp = @[@"😄",@"😊",@"😃",@"☺️",@"😉",@"😍",@"😘",@"😚",@"😳",@"😌",@"😁",@"😜",@"😝",@"😒",@"😏",@"😓",@"😔",@"😞",@"😖",@"😥",@"😰",@"😨",@"😣",@"😢",@"😭",@"😂",@"😲",@"😱",@"😠",@"😡",@"😪",@"😷",@"👿",@"👽",@"💛",@"💙",@"💜",@"💖",@"💚",@"❤️"];
        
        
        NSMutableArray *kk = [NSMutableArray arrayWithArray:temp];
        [kk enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx % 32 != 31) {
                [_emojis addObject:obj];
            } else {
                [kk insertObject:@"🔙" atIndex:idx];
                [_emojis addObject:@"🔙"];
            }
        }];
        
        while (_emojis.count % 32 != 0) {
            NSInteger num = (_emojis.count + 1) % 32;
            if (num != 0) {
                [_emojis addObject:@" "];
            } else {
                [_emojis addObject:@"🔙"];
            }
        }
        
        
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumLineSpacing = 1;
        _layout.minimumInteritemSpacing = 1;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:_boView.bounds collectionViewLayout:_layout];
        _collectionView.backgroundColor = _boView.backgroundColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = true;
        _collectionView.showsHorizontalScrollIndicator = false;
        [_boView addSubview:_collectionView];
        
        [_collectionView registerClass:[EmojiCell class] forCellWithReuseIdentifier:NSStringFromClass([EmojiCell class])];
        [_collectionView registerClass:[ActionCell class] forCellWithReuseIdentifier:NSStringFromClass([ActionCell class])];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    return self;
}

#pragma mark - keyboard
- (void)keyboardDidChanged:(NSNotification *)noti {
    NSDictionary *dic = noti.userInfo;
    NSValue *value = dic[UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [value CGRectValue];
    
    if ([_delegate respondsToSelector:@selector(toolViewDidChangeKeyboardFrame:)]) {
        [_delegate toolViewDidChangeKeyboardFrame:frame];
    }
}

- (void)keyboardChange:(NSNotification *)noti {
    NSDictionary *userInfo = [noti userInfo];
    NSValue* bValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];//更改后的键盘
    
    CGRect bFrame = [bValue CGRectValue];
    CGRect keyboardRect = [aValue CGRectValue];
    if (bFrame.origin.y < keyboardRect.origin.y) {
        // 收回键盘
        _isEditing = false;
        self.frame = CGRectMake(0, CGRectGetHeight(self.superview.frame) - 20 - CGRectGetHeight(_textView.frame), CGRectGetWidth(self.frame), 20 + CGRectGetHeight(_textView.frame) + toolBottomH);
    } else {
        // 弹出键盘
        _isEditing = true;
        self.frame = CGRectMake(0, CGRectGetHeight(self.superview.frame) - 20 - CGRectGetHeight(_textView.frame) - CGRectGetHeight(keyboardRect), CGRectGetWidth(self.frame), 20 + CGRectGetHeight(_textView.frame) + toolBottomH + toolBottomH);
    }
    
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    
    [self setSelfFrame];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] && [_delegate respondsToSelector:@selector(toolViewShouldReturn:)]) {
        [_delegate toolViewShouldReturn:_textView.text];
    }
    
    return true;
}

- (void)setSelfFrame {
    
    CGFloat x = CGRectGetMinX(_textView.frame);
    CGFloat textW = CGRectGetWidth(_textView.frame);
    CGFloat width = CGRectGetWidth(self.superview.frame);
    CGFloat y = self.frame.origin.y + CGRectGetHeight(_textView.frame) + 20;
    
    if (_textView.contentSize.height < toolBtnW) {
        self.frame = CGRectMake(0, y - toolInputH, CGRectGetWidth([UIScreen mainScreen].bounds), toolInputH + toolBottomH);
        
        _textView.frame = CGRectMake(x, 10, textW, toolBtnW);
        _boView.frame = CGRectMake(0, toolInputH, width, toolBottomH);
    } else if (_textView.contentSize.height < 90) {
        CGFloat h = _textView.contentSize.height;
        self.frame = CGRectMake(0, y - 20 - h, CGRectGetWidth([UIScreen mainScreen].bounds), 20 + h + toolBottomH);
        _textView.frame = CGRectMake(x, 10, textW, h);
        _boView.frame = CGRectMake(0, h + 20, width, toolBottomH);
    } else {
        self.frame = CGRectMake(0, y - 110, CGRectGetWidth([UIScreen mainScreen].bounds), 110 + toolBottomH);
        
        _textView.frame = CGRectMake(x, 10, textW, 90);
        _boView.frame = CGRectMake(0, 110, width, toolBottomH);
    }
}

#pragma mark - Btn

- (void)voice:(id)sender {
    _emoji.selected = false;
    _add.selected = false;
    _voice.selected = !_voice.selected;
    if (_voice.selected) {
        [_textView resignFirstResponder];
        
//        [self hidden];
//        
//        if (_isVoice) {
//            _textView.hidden = false;
//            _recordBtn.hidden = true;
//            self.frame = CGRectMake(0, CGRectGetHeight(self.superview.frame) - 20 - CGRectGetHeight(_textView.frame), CGRectGetWidth(self.frame), toolInputH + toolBottomH);
//            
//            [self bringSubviewToFront:_textView];
//        } else {
//            _textView.hidden = true;
//            _recordBtn.hidden = false;
//            
//            self.frame = CGRectMake(0, CGRectGetHeight(self.superview.frame) - toolInputH, CGRectGetWidth(self.frame), toolInputH + toolBottomH);
//            
//            [self bringSubviewToFront:_recordBtn];
//        }
//        _isVoice = !_isVoice;
        _textView.hidden = true;
        _recordBtn.hidden = false;
        
        self.frame = CGRectMake(0, CGRectGetHeight(self.superview.frame) - toolInputH, CGRectGetWidth(self.frame), toolInputH + toolBottomH);
        
        [self bringSubviewToFront:_recordBtn];

    } else {
        [_textView becomeFirstResponder];
        _textView.hidden = false;
        _recordBtn.hidden = true;
//        self.frame = CGRectMake(0, CGRectGetHeight(self.superview.frame) - 20 - CGRectGetHeight(_textView.frame), CGRectGetWidth(self.frame), toolInputH + toolBottomH);
        
        [self bringSubviewToFront:_textView];

    }
    if ([_delegate respondsToSelector:@selector(toolViewDidChangeKeyboardFrame:)]) {
        [_delegate toolViewDidChangeKeyboardFrame:self.frame];
    }
}

- (void)emoji:(id)sender {
    _voice.selected = false;
    _add.selected = false;
    _emoji.selected = !_emoji.selected;
    if (_emoji.selected) {
        [_textView resignFirstResponder];
        _isVoice = false;
        _textView.hidden = false;
        _recordBtn.hidden = true;
        [self bringSubviewToFront:_textView];
        [self setSelfFrame];
        
        _isEmoji = true;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        [_textView resignFirstResponder];
        [self show];
        [_collectionView reloadData];
    } else {
        [_textView becomeFirstResponder];
    }
}

- (void)addBtn:(id)sender {
    _voice.selected = false;
    _emoji.selected = false;
    _isVoice = false;
    _textView.hidden = false;
    _recordBtn.hidden = true;
    [self bringSubviewToFront:_textView];
    [self setSelfFrame];
    
    _isEmoji = false;
    _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [_textView resignFirstResponder];
    [self show];
    [_collectionView reloadData];
    if ([_delegate respondsToSelector:@selector(toolViewDidChangeKeyboardFrame:)]) {
        [_delegate toolViewDidChangeKeyboardFrame:self.frame];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)press {
    if ([_delegate respondsToSelector:@selector(toolViewLongPressToRecord:)]) {
        [_delegate toolViewLongPressToRecord:press];
    }
}

#pragma mark - 外引
- (void)bottom {
    [_textView resignFirstResponder];
    [self hidden];
}

- (void)addActionWithImage:(UIImage *)img title:(NSString *)title tag:(NSInteger)tag {
    Action *action = [[Action alloc] init];
    action.img = img;
    action.title = title;
    action.tag = tag;
    [_actions addObject:action];
    [_collectionView reloadData];
}

- (void)show {
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = CGRectMake(0, CGRectGetHeight(self.superview.frame) - 20 - CGRectGetHeight(_textView.frame) - toolBottomH, CGRectGetWidth(self.frame), 20 + CGRectGetHeight(_textView.frame) + toolBottomH);
    }];
}

- (void)hidden {
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = CGRectMake(0, CGRectGetHeight(self.superview.frame) - 20 - CGRectGetHeight(_textView.frame), CGRectGetWidth(self.frame), 20 + CGRectGetHeight(_textView.frame) + toolBottomH);
    }];
}

- (UIButton *)createBtnWithImage:(UIImage *)img selectedImg:(UIImage *)selImg action:(SEL)action frame:(CGRect)frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:img forState:UIControlStateNormal];
    [btn setImage:selImg forState:UIControlStateSelected];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = frame;
    [self addSubview:btn];
    return btn;
}

- (UIButton *)createBtn:(NSString *)title action:(SEL)action frame:(CGRect)frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.frame = frame;
    [self addSubview:btn];
    return btn;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    
    if (_isEmoji) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([EmojiCell class]) forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ActionCell class]) forIndexPath:indexPath];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _isEmoji ? _emojis.count : _actions.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //🔙
    
    if (_isEmoji) {
        [(EmojiCell *)cell title].text = _emojis[indexPath.row];
    } else {
        [(ActionCell *)cell configAction:_actions[indexPath.row]];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEmoji) {
        
        CGFloat h = (CGRectGetHeight(_collectionView.frame) - 3) / 4.;
        CGFloat w = (CGRectGetWidth(_collectionView.frame) - 7) / 8.;
        
        h = floor(h);
        w = floor(w);
        
        return CGSizeMake(w, h);
    }
    CGFloat w = (CGRectGetWidth(_collectionView.frame) - 3) / 4.;
    CGFloat h = (CGRectGetHeight(_collectionView.frame) - 1) / 2.;
    
    h = floor(h);
    w = floor(w);
    return CGSizeMake(w, h);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_isEmoji) {
        EmojiCell *cell = (EmojiCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSString *emoji = cell.title.text;
        if ([emoji isEqualToString:@"🔙"]) {
            NSInteger length = _textView.text.length;
            if (length == 0) {
                return;
            }
            
            NSInteger emL = @"😄".length;
            if (length - emL > 0) {
                NSString *sub = [_textView.text substringFromIndex:_textView.text.length - emL];
                
                if ([self stringContainsEmoji:sub]) {
                    _textView.text = [_textView.text substringToIndex:_textView.text.length - emL];
                } else {
                    _textView.text = [_textView.text substringToIndex:_textView.text.length - 1];

                }
            } else if ([self stringContainsEmoji:_textView.text]) {
                _textView.text = nil;
            } else {
                _textView.text = [_textView.text substringToIndex:_textView.text.length - 1];
            }
        } else {
            _textView.text = [NSString stringWithFormat:@"%@%@", _textView.text, emoji];
        }
        [self setSelfFrame];
        [_textView scrollRectToVisible:CGRectMake(0, _textView.contentSize.height - 1, CGRectGetWidth(_textView.frame), 1) animated:true];
    } else {
        Action *action = _actions[indexPath.row];
        if ([_delegate respondsToSelector:@selector(toolViewClickedAction:actionTag:)]) {
            [_delegate toolViewClickedAction:action.title actionTag:action.tag];
        }
        
    }
}


//判断是否含有表情
- (BOOL)stringContainsEmoji:(NSString *)string{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

#pragma mark - set
- (void)setText:(NSString *)text {
    _text = text;
    _textView.text = text;
    [self setSelfFrame];
}

@end
