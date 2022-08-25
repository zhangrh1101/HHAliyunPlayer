//
//  HHVideoPlayerControlBottomView.m
//  VideoPlayer
//
//  Created by mac mini on 2022/2/22.
//

#import "HHVideoPlayerControlBottomView.h"
#import "HHPlayerUtil.h"
#import "HHPlayerPrivateDefine.h"
#import "HHPlayerProgressView.h"

static NSString * const HHBottomViewDefaultTime          = @"00:00:00";                //默认时间样式

@interface HHVideoPlayerControlBottomView () <HHPlayerProgressViewDelegate>

@property (nonatomic, strong) UIImageView *bottomBarBG;             //背景图片
@property (nonatomic, strong) UIButton *playButton;                 //播放按钮
@property (nonatomic, strong) UILabel *leftTimeLabel;               //左侧时间
@property (nonatomic, strong) UILabel *rightTimeLabel;              //右侧时间
@property (nonatomic, strong) UILabel *fullScreenTimeLabel;         //全屏时时间
@property (nonatomic, strong) UIButton *fullScreenButton;           //全屏按钮
@property (nonatomic, strong) HHPlayerProgressView *progressView;   //进度条

@end

@implementation HHVideoPlayerControlBottomView

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    
    [self addSubview:self.playButton];
    [self addSubview:self.fullScreenButton];
    [self addSubview:self.leftTimeLabel];
    [self addSubview:self.rightTimeLabel];
    [self addSubview:self.progressView];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.fullScreenButton.selected = !self.isPortrait;
    
    CGSize size = self.bounds.size;
    if (self.isPortrait) {
        
        self.playButton.frame = CGRectMake(0, 0, HHPlayerViewButtonWidth, HHPlayerViewButtonWidth);
        self.fullScreenButton.frame = CGRectMake(size.width-HHPlayerViewButtonWidth, 0, HHPlayerViewButtonWidth, HHPlayerViewButtonWidth);
       
        float progressMarginLeft = HHPlayerViewButtonWidth + 10;
        self.progressView.frame = CGRectMake(progressMarginLeft, 0, size.width - progressMarginLeft*2, HHPlayerViewButtonWidth-5);
     
        CGRect progressFrame = self.progressView.frame;
        CGFloat timeY = progressFrame.size.height/2 + 5;
        CGFloat timeWidth = progressFrame.size.width / 2;
        self.leftTimeLabel.frame = CGRectMake(progressFrame.origin.x, timeY, timeWidth, 20);
        self.rightTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.progressView.frame)-timeWidth, timeY, timeWidth, 20);
    
    }else{
        
        self.playButton.frame = CGRectMake(KHHPlayerMarginTop, 0, HHPlayerViewButtonWidth, HHPlayerViewButtonWidth);
        self.fullScreenButton.frame = CGRectMake(size.width - HHPlayerViewButtonWidth - KHHPlayerMarginBottom, 0, HHPlayerViewButtonWidth, HHPlayerViewButtonWidth);
       
        CGFloat progressMarginLeft = HHPlayerViewButtonWidth + 10 + KHHPlayerMarginTop;
        CGFloat progressMarginRight = HHPlayerViewButtonWidth + 10 + KHHPlayerMarginBottom;
        CGFloat progressWidth = size.width -  progressMarginLeft - progressMarginRight;
        self.progressView.frame = CGRectMake(progressMarginLeft, 0, progressWidth, HHPlayerViewButtonWidth-5);
     
        CGRect progressFrame = self.progressView.frame;
        CGFloat timeY = progressFrame.size.height/2 + 5;
        CGFloat timeWidth = progressFrame.size.width / 2;
        self.leftTimeLabel.frame = CGRectMake(progressFrame.origin.x, timeY, timeWidth, 20);
        self.rightTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.progressView.frame)-timeWidth, timeY, timeWidth, 20);
    }

}


- (void)setProgress:(float)progress{
    self.progressView.playProgress = progress;
}

- (float)progress {
    return self.progressView.playProgress;
}

- (CGFloat)getSliderValue {
    
  return [_progressView getSliderValue];
}


- (void)setLoadTimeProgress:(float)loadTimeProgress {
    _loadTimeProgress = loadTimeProgress;
    self.progressView.loadTimeProgress = loadTimeProgress;
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

- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        _playButton.adjustsImageWhenHighlighted = NO;
        [_playButton setImage:[HHPlayerUtil imageWithName:@"hh_video_player_play"] forState:UIControlStateNormal];
        [_playButton setImage:[HHPlayerUtil imageWithName:@"hh_video_player_pause"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (void)playButtonClicked:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedPlayButtonWithBottomView:)]) {
        [self.delegate onClickedPlayButtonWithBottomView:self];
    }
}

- (UIButton *)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [[UIButton alloc] init];
        _fullScreenButton.adjustsImageWhenHighlighted = NO;
        [_fullScreenButton setImage:[HHPlayerUtil imageWithName:@"hh_video_player_fullscreen"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[HHPlayerUtil imageWithName:@"hh_video_player_shrinkscreen"] forState:UIControlStateSelected];
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}

- (void)fullScreenButtonClicked:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedfullScreenButtonWithBottomView:)]) {
        [self.delegate onClickedfullScreenButtonWithBottomView:self];
    }
}

- (UILabel *)leftTimeLabel{
    if (!_leftTimeLabel) {
        _leftTimeLabel = [[UILabel alloc] init];
        _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
        [_leftTimeLabel setFont:[UIFont systemFontOfSize:HHBottomViewTextSizeFont]];
        [_leftTimeLabel setTextColor:kHHColorTextNomal];
        _leftTimeLabel.text = HHBottomViewDefaultTime;
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
        [_rightTimeLabel setFont:[UIFont systemFontOfSize:HHBottomViewTextSizeFont]];
        [_rightTimeLabel setTextColor:kHHColorTextNomal];
        _rightTimeLabel.text = HHBottomViewDefaultTime;
    }
    return _rightTimeLabel;
}


- (HHPlayerProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[HHPlayerProgressView alloc] init];
        _progressView.delegate = self;
        _progressView.tag = 99999999;
    }
    return _progressView;
}

#pragma mark - progressDelegate
- (void)playerProgressView:(HHPlayerProgressView *)progressView dragProgressSliderValue:(float)value event:(UIControlEvents)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlBottomView:dragProgressSliderValue:event:)]) {
        [self.delegate controlBottomView:self dragProgressSliderValue:value event:event];
    }
}


#pragma mark -  public method

/*
 * 功能 ：根据播放器状态，改变状态
 * 参数 ：state 播放器状态
 */
- (void)updateViewWithPlayerState:(AVPStatus)state {
    switch (state) {
        case AVPStatusIdle:
        {
            [self.playButton setSelected:NO];
//            [self.qualityButton setUserInteractionEnabled:NO];
//            [self.progressView setUserInteractionEnabled:NO];
        }
            break;
        case AVPStatusError:
        {
            [self.playButton setSelected:NO];
            //cai 错误也应该让用户点击按钮重试
//            [self.playButton setUserInteractionEnabled:NO];
//            [self.progressView setUserInteractionEnabled:NO];
        }
            break;
        case AVPStatusPrepared:
        {
            [self.playButton setSelected:NO];
            [self.progressView setUserInteractionEnabled:YES];
        }
            break;
        case  AVPStatusStarted:
        {
            [self.playButton setSelected:YES];
            [self.progressView setUserInteractionEnabled:YES];
        }
            break;
        case  AVPStatusPaused:
        {
            [self.playButton setSelected:NO];
            [self.progressView setUserInteractionEnabled:YES];
        }
            break;
        case AVPStatusStopped:
        {
            [self.playButton setSelected:NO];
            [self.progressView setUserInteractionEnabled:NO];

        }
            break;
//        case AliyunVodPlayerStateLoading:
//        {
//            [self.progressView setUserInteractionEnabled:YES];
//        }
//            break;
        case AVPStatusCompletion:
        {
            [self.playButton setSelected:NO];
            [self.progressView setUserInteractionEnabled:YES];
        }
            break;

        default:
            break;
    }
}

/*
 * 功能 ：更新进度条
 * 参数 ：currentTime 当前播放时间
 durationTime 播放总时长
 */
- (void)updateProgressWithCurrentTime:(float)currentTime durationTime:(float)durationTime{
    
    //左右全屏时间
    if (durationTime < 0) { durationTime = 0; }
    NSString *curTimeStr = [HHPlayerUtil timeformatFromSeconds:roundf(currentTime)];
    NSString *totalTimeStr = [HHPlayerUtil timeformatFromSeconds:roundf(durationTime)];
    self.rightTimeLabel.text = totalTimeStr;
    self.leftTimeLabel.text = curTimeStr;
    NSString *time = [NSString stringWithFormat:@"%@/%@", curTimeStr, totalTimeStr];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:time];
    [str addAttribute:NSForegroundColorAttributeName value:kHHColorTextNomal range:NSMakeRange(0, curTimeStr.length)];
    [str addAttribute:NSForegroundColorAttributeName value:kHHColorTextGray range:NSMakeRange(curTimeStr.length, curTimeStr.length + 1)];
    self.fullScreenTimeLabel.attributedText = str;
    
    //进度条
    [self.progressView updateProgressWithCurrentTime:currentTime durationTime:durationTime];
}

- (void)updateCurrentTime:(float)currentTime durationTime:(float)durationTime{
    //左右全屏时间
    NSString *curTimeStr = [HHPlayerUtil timeformatFromSeconds:roundf(currentTime)];
    NSString *totalTimeStr = [HHPlayerUtil timeformatFromSeconds:roundf(durationTime)];
    self.rightTimeLabel.text = totalTimeStr;
    self.leftTimeLabel.text = curTimeStr;
    NSString *time = [NSString stringWithFormat:@"%@/%@", curTimeStr, totalTimeStr];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:time];
    [str addAttribute:NSForegroundColorAttributeName value:kHHColorTextNomal range:NSMakeRange(0, curTimeStr.length)];
    [str addAttribute:NSForegroundColorAttributeName value:kHHColorTextGray range:NSMakeRange(curTimeStr.length, curTimeStr.length + 1)];
    self.fullScreenTimeLabel.attributedText = str;
}


@end
