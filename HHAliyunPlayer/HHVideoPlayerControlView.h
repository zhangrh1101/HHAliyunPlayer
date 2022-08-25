//
//  HHVideoPlayerControlView.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/22.
//

#import <UIKit/UIKit.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import "HHVideoPlayerControlTopView.h"
#import "HHVideoPlayerControlBottomView.h"
#import "HHPlayerLoadingView.h"
#import "HHPlayerPopLayer.h"
#import "HHPlayerTouchControlView.h"

NS_ASSUME_NONNULL_BEGIN

@class HHVideoPlayerControlView;
@protocol HHControlViewDelegate <NSObject>

/*
 * 功能 ： 点击返回按钮
 * 参数 ： controlView 对象本身
 */
- (void)onBackViewClickWithControlView:(HHVideoPlayerControlView*)controlView;

/*
 * 功能 ： 播放按钮
 * 参数 ： controlView 对象本身
 */
- (void)onClickedPlayButtonWithControlView:(HHVideoPlayerControlView*)controlView;

/*
 * 功能 ： 全屏
 * 参数 ： controlView 对象本身
 */
- (void)onClickedfullScreenButtonWithControlView:(HHVideoPlayerControlView*)controlView;

/*
 * 功能 ： 拖动进度条
 * 参数 ： controlView 对象本身
          progressValue slide滑动长度
          event 手势事件，点击-移动-离开
 */
- (void)controlView:(HHVideoPlayerControlView*)controlView dragProgressSliderValue:(float)progressValue event:(UIControlEvents)event;

/*
 * 功能 ：点击返回时操作
 * 参数 ：popLayer 对象本身
 */
- (void)onBackClickedWithAlPVPopLayer:(HHPlayerPopLayer *)popLayer;

/*
 * 功能 ：点击重试按钮
 * 参数 ：popLayer 对象本身
 */
- (void)onRetryClickedWithHHPlayerErrorType:(HHPlayerErrorType)type;

@end

@interface HHVideoPlayerControlView : UIView

@property (nonatomic, strong) HHVideoPlayerControlTopView          *   topControlView;
@property (nonatomic, strong) HHVideoPlayerControlBottomView       *   bottomControlView;

@property (nonatomic, strong) HHPlayerLoadingView                  *   loadingView;
@property (nonatomic, strong) HHPlayerPopLayer                     *   popLayerView;
/**手势控制音量，亮度*/
@property (nonatomic, strong) HHPlayerTouchControlView             *   touchLayerView;

@property (nonatomic, weak  ) id<HHControlViewDelegate> delegate;

@property (nonatomic, assign) float loadTimeProgress;               //缓存进度
@property (nonatomic, assign) BOOL  isProtrait;                     //竖屏判断
@property (nonatomic, assign) BOOL  isFullScreen;                   //是否为全屏
@property (nonatomic, assign) BOOL  smallGestureControl;            //小屏手势是否禁用


// - default is 49.
@property (nonatomic) CGFloat topHeight;
@property (nonatomic) CGFloat leftWidth;
@property (nonatomic) CGFloat bottomHeight;
@property (nonatomic) CGFloat rightWidth;

/**工具条显示/隐藏 标记*/
@property (nonatomic, assign) BOOL  isDisappear;

/*
 * 功能 ：显示loading
 */
- (void)showLoading;

/*
 * 功能 ：隐藏loading
 */
- (void)hideLoading;

/*
 * 功能 ：更新播放器状态
 */
- (void)updateViewWithPlayerState:(AVPStatus)state isScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait;

/*
 * 功能 ：更新播放器状态
 */
- (void)updateViewWithPlayerState:(AVPStatus)state isScreenLocked:(BOOL)isScreenLocked fixedPortrait:(BOOL)fixedPortrait;

/*
 * 功能 ：更新进度条
 */
- (void)updateProgressWithCurrentTime:(NSTimeInterval)currentTime durationTime:(NSTimeInterval)durationTime;

/*
 * 功能 ：更新当前时间
 */
- (void)updateCurrentTime:(NSTimeInterval)currentTime durationTime:(NSTimeInterval)durationTime;

/*
 * 功能 ：根据不同code，展示弹起的消息界面
 * 参数 ： code ： 事件
          popMsg ：自定义消息
 */
- (void)showPopViewWithCode:(ALYPVPlayerPopCode)code popMsg:(NSString *)popMsg;

/*
 * 功能 ：隐藏容错蒙版
 */
- (void)hidePopView;

@end

NS_ASSUME_NONNULL_END
