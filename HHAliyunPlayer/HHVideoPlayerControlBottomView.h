//
//  HHVideoPlayerControlBottomView.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/22.
//

#import "HHVideoPlayerControlMaskView.h"
#import <AliyunPlayer/AliyunPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@class HHVideoPlayerControlBottomView;
@protocol HHControlBottomViewDelegate <NSObject>

/*
 * 功能 ：进度条滑动 偏移量
 * 参数 ：bottomView 对象本身
         progressValue 偏移量
         event 手势事件，点击-移动-离开
 */
- (void)controlBottomView:(HHVideoPlayerControlBottomView *)bottomView dragProgressSliderValue:(float)progressValue event:(UIControlEvents)event;

/*
 * 功能 ：点击播放，返回代理
 * 参数 ：bottomView 对象本身
 */
- (void)onClickedPlayButtonWithBottomView:(HHVideoPlayerControlBottomView *)bottomView;


/*
 * 功能 ：点击全屏按钮
 * 参数 ：bottomView 对象本身
 */
- (void)onClickedfullScreenButtonWithBottomView:(HHVideoPlayerControlBottomView *)bottomView;

@end

@interface HHVideoPlayerControlBottomView : HHVideoPlayerControlMaskView

@property (nonatomic, weak  ) id<HHControlBottomViewDelegate> delegate;

@property (nonatomic, assign) float progress;                       //滑动progressValue值
@property (nonatomic, assign) float loadTimeProgress;               //缓存progressValue
@property (nonatomic, assign) BOOL isPortrait;                      //竖屏判断

/*
 * 功能 ：根据播放器状态，改变状态
 * 参数 ：state 播放器状态
 */
- (void)updateViewWithPlayerState:(AVPStatus)state;

/*
 * 功能 ：更新进度条
 * 参数 ：currentTime 当前播放时间
         durationTime 播放总时长
 */
- (void)updateProgressWithCurrentTime:(float)currentTime durationTime:(float)durationTime;

/*
 * 功能 ：更新当前显示时间
 * 参数 ：currentTime 当前播放时间
 durationTime 播放总时长
 */
- (void)updateCurrentTime:(float)currentTime durationTime:(float)durationTime;

@end

NS_ASSUME_NONNULL_END
