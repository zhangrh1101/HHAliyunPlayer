//
//  HHPlayerTouchControlView.m
//  RenMinWenLv
//
//  Created by mac mini on 2022/3/1.
//

#import "HHPlayerTouchControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "HHPlayerPrivateDefine.h"

#define VolumeStep 0.02f
#define BrightnessStep 0.02f
#define MovieProgressStep 5.0f
#define minOffset  5.0f

@interface HHPlayerTouchControlView () <UIGestureRecognizerDelegate>

/**用来保存快进的总时长*/
@property (nonatomic, assign) CGFloat                    sumTime;
/**定义一个实例变量，保存枚举值*/
@property (nonatomic, assign) HHPlayerPanDirection       panDirection;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                       isVolume;
/** 是否正在拖拽 */
@property (nonatomic, assign) BOOL                       isDragged;
/**缓冲判断*/
@property (nonatomic, assign) BOOL                       isBuffering;
/**音量滑杆*/
@property (nonatomic, strong) UISlider              *    volumeViewSlider;

@end

@implementation HHPlayerTouchControlView

- (instancetype)init {
    if (self = [super init]) {

        [self initGestures];
        // 获取系统音量
        [self configureVolume];
    }
    return self;
}


- (void)initGestures {
        
    //添加平移手势，用来控制音量、亮度、快进快退
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    panRecognizer.delegate                = self;
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelaysTouchesBegan:YES];
    [panRecognizer setDelaysTouchesEnded:YES];
    [panRecognizer setCancelsTouchesInView:YES];
    [self addGestureRecognizer:panRecognizer];
}


//MARK:JmoVxia---获取系统音量
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider        = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}


//MARK:---手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    //小屏手势是否禁用
    if (!self.smallGestureControl && !self.isFullScreen) {
        return NO;
    }
    return YES;
}

/*
 * UIPanGestureRecognizer手势方法
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan {
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint  = [pan velocityInView:self];
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                [self cl_progressSliderTouchBegan:nil];
                //显示遮罩
                [UIView animateWithDuration:0.5 animations:^{
//                    self.maskView.topToolBar.alpha    = 1.0;
//                    self.maskView.bottomToolBar.alpha = 1.0;
                }];
                // 取消隐藏
                self.panDirection = HHPlayerPanDirectionHorizontalMoved;
                // 给sumTime初值
//                CMTime time       = self.player.currentTime;
//                self.sumTime      = time.value/time.timescale;
            }
            else if (x < y){ // 垂直移动
                self.panDirection = HHPlayerPanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case HHPlayerPanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case HHPlayerPanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case HHPlayerPanDirectionHorizontalMoved:{
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    [self cl_progressSliderTouchEnded:nil];
                    break;
                }
                case HHPlayerPanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


//MARK:JmoVxia---滑动调节音量和亮度
- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}
//MARK:JmoVxia---水平移动调节进度
- (void)horizontalMoved:(CGFloat)value {
    if (value == 0) {
        return;
    }
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    // 需要限定sumTime的范围
//    CMTime totalTime           = self.playerItem.duration;
//    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
//    if (self.sumTime > totalMovieDuration){
//        self.sumTime = totalMovieDuration;
//    }
//    if (self.sumTime < 0) {
//        self.sumTime = 0;
//    }
//    self.isDragged             = YES;
//    //计算出拖动的当前秒数
//    CGFloat dragedSeconds      = self.sumTime;
//    //滑杆进度
//    CGFloat sliderValue        = dragedSeconds / totalMovieDuration;
//    //设置滑杆
//    self.maskView.slider.value = sliderValue;
//    //转换成CMTime才能给player来控制播放进度
//    CMTime dragedCMTime        = CMTimeMake(dragedSeconds, 1);
//    [_player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//    NSInteger proMin                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
//    NSInteger proSec                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
//    self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)proMin, (long)proSec];
}


//MARK:JmoVxia---拖动进度条
//开始
-(void)cl_progressSliderTouchBegan:(HHPlayerSlider *)slider{
    //暂停
//    [self pausePlay];
    //销毁定时消失工具条定时器
//    [self destroyToolBarTimer];
}
//结束
-(void)cl_progressSliderTouchEnded:(HHPlayerSlider *)slider{
//    if (slider.value != 1) {
//        _isEnd = NO;
//    }
//    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
//        [self bufferingSomeSecond];
//    }else{
//        //继续播放
//        [self playVideo];
//    }
//    //重新添加工具条定时消失定时器
//    [self resetToolBarDisappearTime];
}
//拖拽中
-(void)cl_progressSliderValueChanged:(HHPlayerSlider *)slider{
    //计算出拖动的当前秒数
//    CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
//    CGFloat dragedSeconds   = total * slider.value;
//    //转换成CMTime才能给player来控制播放进度
//    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
//    [_player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//    NSInteger proMin                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
//    NSInteger proSec                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟
//    self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)proMin, (long)proSec];
}


@end
