//
//  HHVideoPlayerControlView.m
//  VideoPlayer
//
//  Created by mac mini on 2022/2/22.
//

#import "HHVideoPlayerControlView.h"
#if __has_include(<Masonry/Masonry.h>)
#import "HHGCDTimerManager.h"
#else
#endif

#import "HHPlayerUtil.h"

@interface HHVideoPlayerControlView () <HHControlTopViewDelegate, HHControlBottomViewDelegate, HHPlayerPopLayerDelegate>

/*点击定时器*/
@property (nonatomic, strong) HHGCDTimer       * tapTimer;

@end

@implementation HHVideoPlayerControlView

- (instancetype)init {
    if (self = [super init]) {
        
        _isDisappear = NO;
        _topHeight = _leftWidth = _bottomHeight = _rightWidth = 49;
        [self initSubViews];
    }
    return self;
}

//手势定时器
- (HHGCDTimer *)tapTimer {
    if (_tapTimer == nil) {
        __weak __typeof(self) weakSelf = self;
        _tapTimer = [[HHGCDTimer alloc] initWithInterval:5
                                               delaySecs:5
                                                   queue:dispatch_get_main_queue()
                                                 repeats:YES
                                                  action:^(NSInteger actionTimes) {
            __typeof(&*weakSelf) strongSelf = weakSelf;
            [strongSelf disappear];
        }];
    }
    return _tapTimer;
}


- (void)initSubViews {
    
    self.clipsToBounds = YES;
    
    //创建并添加点击手势（点击事件、添加手势）
    UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disappearControl)];
    [self addGestureRecognizer:tap];
    
    self.topControlView = [[HHVideoPlayerControlTopView alloc] init];
    [self.topControlView addColorsWithStyle:HHMaskStyle_top];
    self.topControlView.delegate = self;
    [self addSubview:self.topControlView];
    
    self.bottomControlView = [[HHVideoPlayerControlBottomView alloc] init];
    [self.bottomControlView addColorsWithStyle:HHMaskStyle_bottom];
    self.bottomControlView.delegate = self;
    [self addSubview:self.bottomControlView];
    
    self.loadingView = [[HHPlayerLoadingView alloc] init];
    [self addSubview:self.loadingView];
    
    self.touchLayerView = [[HHPlayerTouchControlView alloc] init];
    [self addSubview:self.touchLayerView];
    
    self.popLayerView = [[HHPlayerPopLayer alloc] init];
    self.popLayerView.hidden = YES;
    self.popLayerView.delegate = self;
    [self addSubview:self.popLayerView];
    
    [self resetToolBarDisappearTime];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    
    self.topControlView.frame = CGRectMake(0, 0, size.width, self.topHeight);
    self.bottomControlView.frame = CGRectMake(0, size.height-self.topHeight, size.width, self.topHeight);
    self.loadingView.frame = CGRectMake(size.width/2-20, size.height/2-20, 40, 40);
    self.popLayerView.frame = self.bounds;
    self.touchLayerView.frame = CGRectMake(0, self.topHeight, size.width, size.height-self.topHeight*2);
}

/*
 * 功能 ：显示loading
 */
- (void)showLoading {
    [self.loadingView start];
}

/*
 * 功能 ：隐藏loading
 */
- (void)hideLoading {
    [self.loadingView stop];
}

/*
 * 功能 ：点击响应
 */
- (void)disappearControl {
    //取消定时器
    [self destroyToolBarTimer];
    
    CGSize size = self.bounds.size;
    if (_isDisappear){
        //重新添加工具条定时消失定时器
        [self resetToolBarDisappearTime];
        
        [UIView animateWithDuration:0.35 animations:^{
            self.topControlView.frame = CGRectMake(0, 0, size.width, self.topHeight);
            self.bottomControlView.frame = CGRectMake(0, size.height-self.topHeight, size.width, self.topHeight);
        }];
    }else{
        [UIView animateWithDuration:0.35 animations:^{
            CGFloat topY = -self.topHeight;
            CGFloat bottomY = size.height + self.bottomHeight;
            self.topControlView.frame = CGRectMake(0, topY, size.width, self.topHeight);
            self.bottomControlView.frame = CGRectMake(0, bottomY, size.width, self.topHeight);
        }];
    }
    _isDisappear = !_isDisappear;
}

//重置工具条时间
-(void)resetToolBarDisappearTime{
    [self destroyToolBarTimer];
    [self.tapTimer start];
}

//销毁定时消失定时器
- (void)destroyToolBarTimer{
    [self.tapTimer cancel];
    self.tapTimer = nil;
}

//定时消失
- (void)disappear{
    _isDisappear = NO;
    [self disappearControl];
}


#pragma mark - 重写setter方法
- (void)setIsProtrait:(BOOL)isProtrait{
    _isProtrait = isProtrait;
    self.topControlView.isPortrait = isProtrait;
    self.bottomControlView.isPortrait = isProtrait;
    self.popLayerView.isPortrait = isProtrait;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (void)setLoadTimeProgress:(float)loadTimeProgress{
    _loadTimeProgress = loadTimeProgress;
    self.bottomControlView.loadTimeProgress = loadTimeProgress;
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    self.touchLayerView.isFullScreen = isFullScreen;
}

- (void)setSmallGestureControl:(BOOL)smallGestureControl {
    _smallGestureControl = smallGestureControl;
    self.touchLayerView.smallGestureControl = smallGestureControl;
}



#pragma mark - public method
/*
 * 功能 ：更新播放器状态
 */
- (void)updateViewWithPlayerState:(AVPStatus)state isScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait{
    [self.bottomControlView updateViewWithPlayerState:state];
}
/*
 * 功能 ：更新进度条
 */
- (void)updateProgressWithCurrentTime:(NSTimeInterval)currentTime durationTime : (NSTimeInterval)durationTime{
    [self.bottomControlView updateProgressWithCurrentTime:currentTime durationTime:durationTime];
}
/*
 * 功能 ：更新当前时间
 */
- (void)updateCurrentTime:(NSTimeInterval)currentTime durationTime:(NSTimeInterval)durationTime{
    [self.bottomControlView updateCurrentTime:currentTime durationTime:durationTime];
}
/*
 * 功能 ：根据不同code，展示弹起的消息界面
 * 参数 ： code ： 事件
 popMsg ：自定义消息
 */
- (void)showPopViewWithCode:(ALYPVPlayerPopCode)code popMsg:(NSString *)popMsg {
    self.popLayerView.hidden = NO;
    [self.popLayerView showPopViewWithCode:code popMsg:popMsg];
}
/*
 * 功能 ：隐藏容错蒙版
 */
- (void)hidePopView {
    self.popLayerView.hidden = YES;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - HHControlTopViewDelegate
- (void)onClickedBackButtonWithTopView:(HHVideoPlayerControlTopView *)bottomView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBackViewClickWithControlView:)]) {
        [self.delegate onBackViewClickWithControlView:self];
    }
}


#pragma mark - HHControlBottomViewDelegate
- (void)controlBottomView:(HHVideoPlayerControlBottomView *)bottomView dragProgressSliderValue:(float)progressValue event:(UIControlEvents)event{
    switch (event) {
        case UIControlEventTouchDown: //slider 手势按下时
            
            break;
        case UIControlEventValueChanged:
            
            break;
        case UIControlEventTouchUpInside: //slider滑动结束后
            
            break;
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlView:dragProgressSliderValue:event:)]) {
        [self.delegate controlView:self dragProgressSliderValue:progressValue event:event];
    }
}

- (void)onClickedPlayButtonWithBottomView:(HHVideoPlayerControlBottomView *)bottomView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedPlayButtonWithControlView:)]) {
        [self.delegate onClickedPlayButtonWithControlView:self];
    }
}

- (void)onClickedfullScreenButtonWithBottomView:(HHVideoPlayerControlBottomView *)bottomView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedfullScreenButtonWithControlView:)]) {
        [self.delegate onClickedfullScreenButtonWithControlView:self];
    }
    [self resetToolBarDisappearTime];
}




#pragma mark - HHPlayerPopLayerDelegate
/*
 * 功能 ：点击返回时操作
 * 参数 ：popLayer 对象本身
 */
- (void)onBackClickedWithAlPVPopLayer:(HHPlayerPopLayer *)popLayer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedfullScreenButtonWithControlView:)]) {
        [self.delegate onBackClickedWithAlPVPopLayer:self];
    }
}

/*
 * 功能 ：点击重试按钮
 * 参数 ：popLayer 对象本身
 */
- (void)onRetryClickedWithHHPlayerErrorType:(HHPlayerErrorType)type {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickedfullScreenButtonWithControlView:)]) {
        [self.delegate onRetryClickedWithHHPlayerErrorType:type];
    }
}


@end
