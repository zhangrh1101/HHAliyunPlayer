//
//  HHPlayerProgressView.m
//  VideoPlayer
//
//  Created by mac mini on 2022/2/23.
//

#import "HHPlayerProgressView.h"
#import "HHPlayerPrivateDefine.h"
#import "HHPlayerUtil.h"

@interface HHPlayerProgressView ()

@property (nonatomic, strong) NSMutableArray * adsViewArray;
@property (nonatomic, strong) NSMutableArray * dotsViewArray;
@property (nonatomic, strong) NSArray * dotsTimeArray;

@end

@implementation HHPlayerProgressView

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
    
    [self addSubview:self.loadProgressView];
    [self addSubview:self.playSlider];

    
//    self.loadProgressView.frame = CGRectMake(0, 10, self.frame.size.width, 2);
//    self.playSlider.frame = self.bounds;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    self.loadProgressView.frame = CGRectMake(0, size.height/2, self.frame.size.width, 2);
    self.playSlider.frame = self.bounds;
}

- (void)setLoadTimeProgress:(float)loadTimeProgress {
    _loadTimeProgress = loadTimeProgress;
    [self.loadProgressView setProgress:loadTimeProgress];
}

- (void)setPlayProgress:(float)playProgress {
    [self.playSlider setValue:playProgress animated:YES];
}

- (float)playProgress {
    return self.playSlider.value;
}

- (float)getSliderValue {
    return self.playSlider.beginPressValue;
}


//缓冲条
- (UIProgressView *)loadProgressView{
    if (!_loadProgressView) {
        _loadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadProgressView.progress = 0.0;
        //设置它的风格，为默认的
        _loadProgressView.trackTintColor= [UIColor colorWithWhite:0.7 alpha:0.5];
        //设置轨道的颜色
        _loadProgressView.progressTintColor= [UIColor whiteColor];
    }
    return _loadProgressView;
}


//进度条
- (HHPlayerSlider *)playSlider{
    if (!_playSlider) {
        _playSlider = [[HHPlayerSlider alloc] init];
        _playSlider.value = 0.0;
        //thumb左侧条的颜色
        _playSlider.minimumTrackTintColor = KHHPlayerMainColor;
        _playSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        //thumb图片
        [_playSlider setThumbImage:[HHPlayerUtil imageWithName:@"hh_play_thumbImage"] forState:UIControlStateNormal];
        //手指落下
        [_playSlider addTarget:self action:@selector(progressSliderDownAction:) forControlEvents:UIControlEventTouchDown];
        //手指抬起
        [_playSlider addTarget:self action:@selector(progressSliderUpAction:) forControlEvents:UIControlEventTouchUpInside];
        //value发生变化
        [_playSlider addTarget:self action:@selector(updateProgressSliderAction:) forControlEvents:UIControlEventValueChanged];
        //手指在外面抬起
        [_playSlider addTarget:self action:@selector(updateProgressUpOUtsideSliderAction:) forControlEvents:UIControlEventTouchUpOutside];
        //手指点击
        [_playSlider addTarget:self action:@selector(updateProgressTouchDownRepeatSliderAction:) forControlEvents:UIControlEventTouchDownRepeat];
        
        [_playSlider addTarget:self action:@selector(cancelProgressSliderAction:) forControlEvents:UIControlEventTouchCancel];
        
        _playSlider.userInteractionEnabled = YES;

    }
    return _playSlider;
}

#pragma mark - public method
/*
 * 功能 ：更新进度条
 * 参数 ：currentTime 当前播放时间
         durationTime 播放总时长
 */
- (void)updateProgressWithCurrentTime:(float)currentTime durationTime:(float)durationTime {
    if (durationTime == 0) {
        [self.playSlider setValue:0 animated:NO];
        self.playSlider.userInteractionEnabled = NO;
    }else {
        [self.playSlider setValue:currentTime/durationTime animated:YES];
        self.playSlider.userInteractionEnabled = YES;
    }
}


#pragma mark - slider action
- (void)progressSliderDownAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate playerProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchDown];
    }
}

- (void)updateProgressSliderAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate playerProgressView:self dragProgressSliderValue:sender.value event:UIControlEventValueChanged];
    }
}

- (void)progressSliderUpAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate playerProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchUpInside];
    }
}

- (void)updateProgressUpOUtsideSliderAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate playerProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchUpOutside];
    }
}

- (void)updateProgressTouchDownRepeatSliderAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate playerProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchDownRepeat];
    }
}

- (void)cancelProgressSliderAction:(UISlider *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerProgressView:dragProgressSliderValue:event:)]) {
        [self.delegate playerProgressView:self dragProgressSliderValue:sender.value event:UIControlEventTouchCancel];
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
