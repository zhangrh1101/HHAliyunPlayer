//
//  HHVideoPlayerControlTopView.m
//  VideoPlayer
//
//  Created by mac mini on 2022/2/22.
//

#import "HHVideoPlayerControlTopView.h"
#import "HHPlayerUtil.h"
#import "HHPlayerPrivateDefine.h"

@interface HHVideoPlayerControlTopView ()

@property (nonatomic, strong) UIImageView *bottomBarBG;             //背景图片
@property (nonatomic, strong) UIButton *backButton;                 //返回按钮

@end

@implementation HHVideoPlayerControlTopView

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
//        [self makeConstraints];
    }
    return self;
}

- (void)initSubViews {
    
    [self addSubview:self.backButton];
}


- (void)layoutSubviews {
    [super layoutSubviews];

    //返回按钮
    if (self.isPortrait) {
        self.backButton.frame = CGRectMake(0, 0, HHTopViewPlayBackButtonWidth, HHTopViewPlayBackButtonWidth);
    }else{
        self.backButton.frame = CGRectMake(KHHPlayerMarginTop, 0, HHTopViewPlayBackButtonWidth, HHTopViewPlayBackButtonWidth);
    }
}


- (void)setIsPortrait:(BOOL)isPortrait {
    _isPortrait = isPortrait;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        _backButton.adjustsImageWhenHighlighted = NO;
        [_backButton setImage:[HHPlayerUtil imageWithName:@"hh_video_player_back"] forState:UIControlStateNormal];
        [_backButton setImage:[HHPlayerUtil imageWithName:@"hh_video_player_back"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)backButtonClicked:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedBackButtonWithTopView:)]) {
        [self.delegate onClickedBackButtonWithTopView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
