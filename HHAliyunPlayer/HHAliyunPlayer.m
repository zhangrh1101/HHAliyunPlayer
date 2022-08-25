//
//  HHAliyunPlayer.m
//  VideoPlayer
//
//  Created by mac mini on 2022/2/21.
//

#import "HHAliyunPlayer.h"
#import "HHPlayerUtil.h"
#import "HHPlayerPrivateDefine.h"
#import "HHPlayerProgressView.h"
#import "HHVideoPlayerControlView.h"
#import "HHReachability.h"

@implementation HHPlayerViewConfigure


+ (instancetype)defaultConfigure {
    HHPlayerViewConfigure *configure = [[HHPlayerViewConfigure alloc] init];
    configure.autoPlay                = NO;
    configure.repeatPlay              = NO;
    configure.mute                    = NO;
    configure.smallGestureControl     = NO;
    configure.isLandscape             = NO;
    configure.autoRotate              = YES;
    configure.fullGestureControl      = YES;
    configure.backPlay                = YES;
    configure.rate                    = 1.0;
    configure.progressBackgroundColor = [UIColor colorWithRed:0.54118
                                                        green:0.51373
                                                         blue:0.50980
                                                        alpha:1.00000];
    configure.progressPlayFinishColor = [UIColor greenColor];
    configure.progressBufferColor     = [UIColor colorWithRed:0.84118
                                                        green:0.81373
                                                         blue:0.80980
                                                        alpha:1.00000];
    configure.strokeColor             = [UIColor whiteColor];
    configure.topToolBarHiddenType    = ToolTopBarHiddenNever;
    configure.toolBarDisappearTime    = 10;
    return configure;
}

@end


@interface HHAliyunPlayer () <AVPDelegate, HHControlViewDelegate>

/**网络监听*/
@property (nonatomic, strong) HHReachability                *   reachability;
/**是否是流量播放*/
@property (nonatomic, assign) BOOL                              isPlayWWAN;
#pragma mark - 播放方式
/**是否是全屏*/
@property (nonatomic, assign, readonly) BOOL                    isFullScreen;
/**播放器*/
@property (nonatomic, strong) AliPlayer                     *   player;
@property (nonatomic, strong) UIView                        *   playerView;

/**蒙版控制视图*/
@property (nonatomic, strong) HHVideoPlayerControlView      *   controlView;

/**记录播放器的状态*/
@property (nonatomic, assign) AVPUrlSource                  *   source;
@property (nonatomic, assign) AVPStatus                         currentPlayStatus;
@property (nonatomic, assign) AVPSeekMode                       seekMode;

@property (nonatomic) BOOL isPlayFinished;///< 播放结束

@property (nonatomic, strong) UIView * fatherView;                       //父类控件
@property (nonatomic, assign) CGRect saveFrame;                          //记录竖屏时尺寸,横屏时为全屏状态。
@property (nonatomic, assign) float  saveCurrentTime;                    //保存重试之前的播放时间
@property (nonatomic, assign) BOOL   isScreenLocked;                     //屏锁
@property (nonatomic, assign) BOOL   fixedPortrait;                      //yes：竖屏全屏；no：横屏全屏;
@property (nonatomic, assign) BOOL   isProtrait;                         //是否是竖屏
@property (nonatomic, assign) BOOL   isUserTapMaxButton;                 //点击最大化标记
@property (nonatomic, assign) BOOL   mProgressCanUpdate;                 //进度条是否更新，默认是NO
@property (nonatomic, assign) BOOL   isLive;                             //是否为直播

@property (nonatomic, assign) BOOL   isEnterBackground;
@property (nonatomic, assign) BOOL   isPauseByBackground;

/*配置*/
@property (nonatomic, strong) HHPlayerViewConfigure * configure;

@end

@implementation HHAliyunPlayer

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    //回到竖屏
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HHReachabilityChangedNotification object:self.player];
    [self.reachability stopNotifier];
    
    if (self.player) {
        [self destroyPlayer];
    }
}

#pragma mark - 更新配置
- (HHPlayerViewConfigure *) configure{
    if (_configure == nil){
        _configure = [HHPlayerViewConfigure defaultConfigure];
    }
    return _configure;
}

- (void)updateWithConfigure:(void(^)(HHPlayerViewConfigure *configure))configureBlock {
    if (configureBlock) {
        configureBlock(self.configure);
    }
    self.player.autoPlay                  = self.configure.autoPlay;    //自动播放
    self.player.muted                     = self.configure.mute;        //是否静音
    self.player.rate                      = self.configure.rate;        //播放速率
    
    //    self.maskView.progressBackgroundColor = self.configure.progressBackgroundColor;
    //    self.maskView.progressBufferColor     = self.configure.progressBufferColor;
    //    self.maskView.progressPlayFinishColor = self.configure.progressPlayFinishColor;
    //    [self.maskView.loadingView updateWithConfigure:^(CLRotateAnimationViewConfigure * _Nonnull configure) {
    //        configure.backgroundColor = self.configure.strokeColor;
    //    }];
    [self resetTopToolBarHiddenType];
}

#pragma mark - 重置顶部工具条隐藏方式
-(void)resetTopToolBarHiddenType{
    switch (self.configure.topToolBarHiddenType) {
        case ToolTopBarHiddenNever:
            //不隐藏
            self.controlView.topControlView.hidden = NO;
            self.controlView.popLayerView.hideBack = NO;
            break;
        case ToolTopBarHiddenAlways:
            //小屏和全屏都隐藏
            self.controlView.topControlView.hidden = YES;
            self.controlView.popLayerView.hideBack = YES;
            break;
        case ToolTopBarHiddenSmall:
            //小屏隐藏，全屏不隐藏
            self.controlView.topControlView.hidden = !self.isFullScreen;
            self.controlView.popLayerView.hideBack = !self.isFullScreen;
            self.controlView.smallGestureControl = self.configure.smallGestureControl;
            break;
    }
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        //初始值
        if ([HHPlayerUtil isInterfaceOrientationPortrait]){
            _saveFrame = frame;
            _isProtrait              = YES;
            _isFullScreen            = NO;
            _isUserTapMaxButton      = NO;
            _mProgressCanUpdate      = YES;
        }else{
            self.saveFrame = CGRectZero;
        }
        
        [self addNotofication];
        [self initPlayerView];
        [self.reachability startNotifier];
    }
    return self;
}


- (void)addNotofication {
    
    //开启
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //注册屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
    //APP运行状态通知，将要被挂起
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterPlayground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

//MARK:JmoVxia---APP活动通知
- (void)appDidEnterBackground:(NSNotification *)note{
    _isEnterBackground = YES;
    if (self.currentPlayStatus == AVPStatusStarted || self.currentPlayStatus == AVPStatusPrepared) {
        [self pause];
    }
}
- (void)appDidEnterPlayground:(NSNotification *)note{
    //继续播放
    _isEnterBackground = NO;
    if (self.currentPlayStatus == AVPStatusPaused) {
        [self start];
    }
}

#pragma mark-设置url
- (void)setUrl:(NSString *)url {
    _url = url;
    if (url == nil || url == NULL) {
        _url = @"";
    }
    [self initUrlSource];
}

- (void)initUrlSource{
    
    //设置数据源
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:self.url];
    self.source = source;
    
    [self.player setUrlSource:source];
    [self.player prepare];
    [self.controlView showLoading];
}

- (void)initPlayerView{
    
    //关闭日志
    [AliPlayer setEnableLog:NO];
    
    self.playerView = UIView.new;
    self.playerView.frame = self.bounds;
    self.playerView.backgroundColor = RGBA(0,0,0,1);
    [self addSubview:self.playerView];
    
    //播放器
    self.player = [[AliPlayer alloc] init];
    self.player.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
    self.player.enableHardwareDecoder = NO;
    self.player.delegate = self;
    self.player.playerView = self.playerView;

    //控制蒙版
    self.controlView = [[HHVideoPlayerControlView alloc] init];
    self.controlView.delegate = self;
    self.controlView.isProtrait = self.isProtrait;
    self.controlView.isFullScreen = self.isFullScreen;
    [self addSubview:self.controlView];
}


/**
 网络状态
 */
- (HHReachability *)reachability {
    if (!_reachability) {
        //网络状态判定
        _reachability = [HHReachability reachabilityForInternetConnection];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged)
                                                     name:HHReachabilityChangedNotification
                                                   object:nil];
    }
    return _reachability;
}

#pragma mark - 网络状态改变
- (void)reachabilityChanged{
    
    HHNetworkStatus status = [self.reachability currentReachabilityStatus];
    NSLog(@"网络状态改变 %d", status);
    
    switch (status) {
        case HHNetworkStatusNotReachable: { //由播放器底层判断是否有网络
            self.isPlayWWAN = NO;
            [self pause];
            [self.controlView showPopViewWithCode:ALYPVPlayerPopCodeUnreachableNetwork popMsg:nil];
        }  break;
        case HHNetworkStatusReachableViaWiFi: {
            
            [self haveNetworkStatusChange];
        } break;
        case HHNetworkStatusReachableViaWWAN:
        {
            if (self.player.autoPlay) {
                self.player.autoPlay = NO;
            }
            if (self.isPlayWWAN) {
                [self haveNetworkStatusChange];
            }else{
                [self pause];
                [self.controlView showPopViewWithCode:ALYPVPlayerPopCodeUseMobileNetwork popMsg:nil];
            }
        } break;
        default:
            break;
    }
}

- (void)haveNetworkStatusChange {
    
    if (self.currentPlayStatus == AVPStatusStarted) {
        [self.controlView hidePopView];
        [self start];
    }
    else if (self.currentPlayStatus == AVPStatusPaused) {
        [self.controlView hidePopView];
        [self pause];
    }
    else{
        [self.controlView hidePopView];
        [self replay];
    }
}

//网络状态判定
- (BOOL)networkChangedToShowPopView{
    
    BOOL ret = YES;
    HHNetworkStatus status = [self.reachability currentReachabilityStatus];
    switch (status) {
        case HHNetworkStatusNotReachable: {  //由播放器底层判断是否有网络
            ret = YES;
        }
            break;
        case HHNetworkStatusReachableViaWiFi: {
            if (self.currentPlayStatus == AVPStatusStarted || self.currentPlayStatus == AVPStatusPrepared) {
                [self.controlView hidePopView];
            }
            ret = NO;
        }
            break;
        case HHNetworkStatusReachableViaWWAN: {
            if (self.isPlayWWAN) {
                [self.controlView hidePopView];
            }
            ret = NO;
        }
            break;
        default:
            break;
    }
    return ret;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerView.frame = self.bounds;
    self.controlView.frame = self.playerView.bounds;
}


#pragma mark - 播放事件
- (void)seekTo:(NSTimeInterval)seekTime {
    if (self.player.duration > 0) {
        [self.player seekToTime:seekTime seekMode:self.seekMode];
        [self.controlView showLoading];
    }
}

- (void)start {
    //    if (self.imageAdsView) {
    //        [self.imageAdsView removeFromSuperview];
    //        self.imageAdsView = nil;
    //    }
    
    [self.player start];
    NSLog(@"播放器 start");
}

- (void)pause{
    
    //    if (self.imageAdsView) {
    //        [self.imageAdsView removeFromSuperview];
    //        self.imageAdsView = nil;
    //    }
    //    if ([self isImageAds]) {
    //        self.imageAdsView = [[AVCImageAdView alloc]initWithImage:[UIImage imageNamed:@""] status:PauseStatus inView:self];
    //        self.imageAdsView.player = self.aliPlayer;
    //    }else if (self.stsSource.playConfig){
    //
    //        self.imageAdsView = [[AVCImageAdView alloc]initWithImage:[UIImage imageNamed:@""] status:PauseStatus inView:self];
    //    }
    
    [self.player pause];
    self.currentPlayStatus = AVPStatusPaused; // 快速的前后台切换时，播放器状态的变化不能及时传过来
    
    NSLog(@"播放器 pause");
}

- (void)stop {
    [self.player stop];
    NSLog(@"播放器 stop");
}

- (void)reload {
    [self.player reload];
    [self.player start];
    NSLog(@"播放器 reload");
}

- (void)replay {
    //重播
    [self seekTo:0];
    [self.player prepare];
    [self.player start];
    NSLog(@"播放器 replay");
}

- (void)destroyPlayer {
    
    [self.reachability stopNotifier];
    
    if (self.player) {
        [self.player stop];
        [self.player destroy];
        _player = nil;
    }
    
    //移除
    [self.playerView removeFromSuperview];
    [self removeFromSuperview];
    _playerView = nil;
    _controlView = nil;
    
    //开启休眠
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    NSLog(@"播放器释放了...");
}



#pragma makr - 重写
- (UIView *)view {
    return self.player.playerView;
}

- (AVPStatus)playerViewState {
    return _currentPlayStatus;
}


#pragma makr - 是否支持旋转
- (void)canRotation:(BOOL)canRotation {
    if (canRotation) {
        self.configure.autoRotate = YES;
    }else{
        self.configure.autoRotate = NO;
        [self originalscreen];
    }
}

#pragma mark - 屏幕旋转
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
    //进后台不再旋转屏幕
    if (_isEnterBackground) {
        return;
    }
    
    if (self.isScreenLocked) {
        return;
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (self.configure.autoRotate) {
        if (orientation == UIDeviceOrientationLandscapeLeft){
            if (!_isFullScreen){
                if (self.configure.isLandscape) {
                    //播放器所在控制器页面支持旋转情况下，和正常情况是相反的
                    [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
                }else{
                    [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
                }
            }
        }
        else if (orientation == UIDeviceOrientationLandscapeRight){
            if (!_isFullScreen){
                if (self.configure.isLandscape) {
                    [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
                }else{
                    [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
                }
            }
        }
        else {
            if (_isFullScreen){
                [self originalscreen];
            }
        }
    }
}

#pragma mark - 全屏
- (void)fullScreenWithDirection:(UIInterfaceOrientation)direction{
    
    _isFullScreen             = YES;
    //记录播放器父类
    _fatherView               = self.superview;
    //记录原始大小
    _saveFrame                = self.frame;
    
    [self resetTopToolBarHiddenType];
    
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    [keyWindow addSubview:self];
    [keyWindow endEditing:YES];

    if (self.configure.isLandscape){
        //手动点击需要旋转方向
        if (_isUserTapMaxButton) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationUnknown] forKey:@"orientation"];
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        }
        self.frame = CGRectMake(0, 0, MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
        
        //        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

    }else{
        //播放器所在控制器不支持旋转，采用旋转view的方式实现
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        if (direction == UIInterfaceOrientationLandscapeLeft){
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }];
        }else if (direction == UIInterfaceOrientationLandscapeRight) {
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformMakeRotation( - M_PI / 2);
            }];
        }
        self.frame = CGRectMake(0, 0, MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
    }
    
    self.isProtrait = NO;
    self.controlView.isProtrait = self.isProtrait;
    self.controlView.isFullScreen = self.isFullScreen;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


/**
 原始大小
 */
- (void)originalscreen{
    _isFullScreen             = NO;
    _isUserTapMaxButton       = NO;
    [self resetTopToolBarHiddenType];

    //还原为竖屏
    if (self.configure.isLandscape) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationUnknown] forKey:@"orientation"];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }else{
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformMakeRotation(0);
        }];
    }
    
    self.isProtrait = YES;
    self.controlView.isProtrait = self.isProtrait;
    self.controlView.isFullScreen = self.isFullScreen;

//    //还原到原有父类上
    self.frame = _saveFrame;
    [_fatherView addSubview:self];
}


#pragma mark - HHControlViewDelegate
/**
 全屏按钮事件
 */
- (void)onClickedfullScreenButtonWithControlView:(HHVideoPlayerControlView*)controlView {
    NSLog(@"全屏");
    if (_isFullScreen){
        [self originalscreen];
    }else{
        _isUserTapMaxButton = YES;
        [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
    }
}

/**
 进度条事件
 */
- (void)controlView:(HHVideoPlayerControlView*)controlView dragProgressSliderValue:(float)progressValue event:(UIControlEvents)event {
    
    //总时长
    NSInteger totalTime = self.player.duration;
    HHPlayerProgressView *progressView = [self.controlView viewWithTag:99999999];
    if(totalTime==0){
        [progressView.playSlider setEnabled:NO];
        return;
    }
    switch (event) {
        case UIControlEventTouchDown: {
            NSLog(@"进度条 UIControlEventTouchDown");
        }
            break;
        case UIControlEventValueChanged: {
            NSLog(@"进度条 UIControlEventValueChanged");
            //更新UI上的当前时间
            self.mProgressCanUpdate = NO;
            [self.controlView updateCurrentTime:progressValue*totalTime durationTime:totalTime];
        }
            break;
        case UIControlEventTouchUpOutside:
        case UIControlEventTouchUpInside: {
            
            NSLog(@"进度条 UIControlEventTouchUpInside 跳转到%.1f",progressValue*self.player.duration);
            [self seekTo:progressValue*self.player.duration];
            
            AVPStatus state = [self playerViewState];
            if (state == AVPStatusPaused) {
                [self.player start];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //在播放器回调的方法里，防止sdk异常不进行seekdone的回调，在3秒后增加处理，防止ui一直异常
                self.mProgressCanUpdate = YES;
            });
        }
            break;
        case UIControlEventTouchDownRepeat:{        //点击事件
            
            self.mProgressCanUpdate = NO;
            [self seekTo:progressValue*self.player.duration];
            
            NSLog(@"进度条 UIControlEventTouchDownRepeat 跳转到%.1f",progressValue*self.player.duration);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //在播放器回调的方法里，防止sdk异常不进行seekdone的回调，在3秒后增加处理，防止ui一直异常
                self.mProgressCanUpdate = YES;
            });
        }
            break;
        case UIControlEventTouchCancel:
            NSLog(@"进度条 UIControlEventTouchCancel");
            self.mProgressCanUpdate = YES;
            break;
        default:
            self.mProgressCanUpdate = YES;
            break;
    }
}


/*
 * 功能 ：点击重试按钮
 * 参数 ：popLayer 对象本身
 */
- (void)onRetryClickedWithHHPlayerErrorType:(HHPlayerErrorType)type {
    
    switch (type) {
        case HHErrorTypeReplay: {
            [self replay];
        }
            break;
        case HHErrorTypeRetry: {
            [self retry];
        }
            break;
        case HHErrorTypePause: {
            
            [self.controlView showLoading];
            [self.player prepare];
            if (self.saveCurrentTime > 0) {
                [self seekTo:self.saveCurrentTime*1000];
            }
            [self.player start];
        }
            break;
        case HHErrorTypeUseMobileNetwork: {
            self.isPlayWWAN = YES;
            [self start];
            [self.controlView hidePopView];
        }
            break;
        default:
            [self retry];
            break;
    }
}

- (void)retry {
    [self stop];
    
    [self.controlView showLoading];
    
    if (self.saveCurrentTime > 0) {
        [self seekTo:self.saveCurrentTime*1000];
    }
    
    [self.player prepare];
    [self.player start];
}

/*
 * 功能 ：容错界面点击返回时操作
 * 参数 ：popLayer 对象本身
 */
- (void)onBackClickedWithAlPVPopLayer:(HHPlayerPopLayer *)popLayer {
    
    if (_isFullScreen) {
        [self originalscreen];
    }else {
        [self pause];
    }
}

/**
 返回按钮事件
 */
- (void)onBackViewClickWithControlView:(HHVideoPlayerControlView*)controlView {
    NSLog(@"返回");
    if (_isFullScreen) {
        [self originalscreen];
    }else {
        [self pause];
    }
}


/**
 播放按钮事件
 */
- (void)onClickedPlayButtonWithControlView:(HHVideoPlayerControlView*)controlView {
    NSLog(@"播放");
    AVPStatus state = [self playerViewState];
    switch (state) {
        case AVPStatusIdle: {
            
        }
            break;
        case AVPStatusInitialzed: {
            
        }
            break;
        case AVPStatusPrepared: {
            [self.player start];
        }
            break;
        case AVPStatusStarted: {
            if (self.player.duration == 0) {  //如果是直播则stop
                _isLive = YES;
                [self stop];
            }else{
                [self pause];
            }
        }
            break;
        case AVPStatusPaused: {
            [self.player start];
        }
            break;
        case AVPStatusStopped: {
            if (_isLive) {  //如果是直播
                [self.player prepare];
                [self.player start];
            }else{
                [self replay];
            }
        }
            break;
        case AVPStatusCompletion: {
            [self replay];
        }
            break;
        case AVPStatusError: {
            
        }
            break;
        default:
            break;
    }
}


#pragma mark - AVPDelegate
/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    
    NSLog(@"播放器状态更新：%lu",(unsigned long)eventType);
    
    switch (eventType) {
        case AVPEventPrepareDone: {
            // 准备完成
            [self.controlView hideLoading];
            [self.controlView updateProgressWithCurrentTime:0 durationTime:self.player.duration];
        }
            break;
        case AVPEventAutoPlayStart:
            // 自动播放开始事件
            [self.controlView hideLoading];
            break;
        case AVPEventFirstRenderedStart:
            // 首帧显示
            [self.controlView hideLoading];
            //开启常亮状态
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            //隐藏封面
            if (self.coverImageView) {
                self.coverImageView.hidden = YES;
                NSLog(@"播放器:首帧加载完成封面隐藏");
            }
            NSLog(@"AVPEventFirstRenderedStart 首帧回调");
            break;
        case AVPEventCompletion:
            // 播放完成
            if (self.configure.repeatPlay){
                [self replay];
            }
            else{
                [self pause];
            }
            break;
        case AVPEventLoadingStart:
            // 缓冲开始
            [self.controlView showLoading];
            break;
        case AVPEventLoadingEnd:
            // 缓冲完成
            [self.controlView hideLoading];
            break;
        case AVPEventSeekEnd:
            // 跳转完成
            self.mProgressCanUpdate = YES;
            [self.controlView hideLoading];
            break;
        case AVPEventLoopingStart:
            // 循环播放开始
            break;
        default:
            break;
    }
}

/**
 @brief 播放器状态改变回调
 @param player 播放器player指针
 @param oldStatus 老的播放器状态 参考AVPStatus
 @param newStatus 新的播放器状态 参考AVPStatus
 @see AVPStatus
 */
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    
    NSLog(@"状态改变回调：%lu",(unsigned long)newStatus);
    if ([self networkChangedToShowPopView]) {
        return;
    }
    
    self.currentPlayStatus = newStatus;
    
    if(_isEnterBackground){
        if (self.currentPlayStatus == AVPStatusStarted || self.currentPlayStatus == AVPStatusPrepared) {
            [self pause];
        }
    }
    //更新UI状态
    [self.controlView updateViewWithPlayerState:self.currentPlayStatus isScreenLocked:self.isScreenLocked fixedPortrait:self.isProtrait];
}


/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 更新进度条
    NSTimeInterval currentTime = position;
    NSTimeInterval durationTime = self.player.duration;
    self.saveCurrentTime = currentTime/1000;
    
    if(self.mProgressCanUpdate == YES){
        [self.controlView updateProgressWithCurrentTime:currentTime durationTime:durationTime];
    }
}
/**
 @brief 视频缓存位置回调
 @param player 播放器player指针
 @param position 视频当前缓存位置
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 更新缓冲进度
    //    NSLog(@"缓冲进度 %f", (float)position/player.duration);
    self.controlView.loadTimeProgress = (float)position/player.duration;
}
/**
 @brief 获取track信息回调
 @param player 播放器player指针
 @param info track流信息数组 参考AVPTrackInfo
 */
- (void)onTrackReady:(AliPlayer*)player info:(NSArray<AVPTrackInfo*>*)info {
    // 获取多码率信息
    [self.controlView hideLoading];
}
/**
 @brief 字幕显示回调
 @param player 播放器player指针
 @param index 字幕显示的索引号
 @param subtitle 字幕显示的字符串
 */
- (void)onSubtitleShow:(AliPlayer*)player index:(int)index subtitle:(NSString *)subtitle {
    // 获取字幕进行显示
}
/**
 @brief 字幕隐藏回调
 @param player 播放器player指针
 @param index 字幕显示的索引号
 */
- (void)onSubtitleHide:(AliPlayer*)player index:(int)index {
    // 隐藏字幕
}
/**
 @brief 获取截图回调
 @param player 播放器player指针
 @param image 图像
 */
- (void)onCaptureScreen:(AliPlayer *)player image:(UIImage *)image {
    // 预览，保存截图
}
/**
 @brief track切换完成回调
 @param player 播放器player指针
 @param info 切换后的信息 参考AVPTrackInfo
 */
- (void)onTrackChanged:(AliPlayer*)player info:(AVPTrackInfo*)info {
    // 切换码率结果通知
}

/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    //提示错误，及stop播放
    [self.controlView hideLoading];
    //根据错误信息，展示popLayer界面
    NSLog(@"errorCode:%d errorMessage:%@",(int)errorModel.code,errorModel.message);
    [self.controlView showPopViewWithCode:(int)errorModel.code popMsg:errorModel.message];
    
    NSInteger code = errorModel.code;
    if (code == ERROR_LOADING_TIMEOUT) {
        [self.controlView showPopViewWithCode:ALYPVPlayerPopCodeUnreachableNetwork popMsg:nil];
    }else{
        [self.controlView showPopViewWithCode:code popMsg:nil];
    }
}

//...

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
