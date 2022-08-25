//
//  HHPlayerProgressView.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/23.
//

#import <UIKit/UIKit.h>
#import "HHPlayerSlider.h"

NS_ASSUME_NONNULL_BEGIN

@class HHPlayerProgressView;
@protocol HHPlayerProgressViewDelegate <NSObject>

/*
 * 功能 ： 移动距离
   参数 ： dragProgressSliderValue slide滑动长度
          event 手势事件，点击-移动-离开
 */
- (void)playerProgressView:(HHPlayerProgressView *)progressView dragProgressSliderValue:(float)value event:(UIControlEvents)event;
@end

@interface HHPlayerProgressView : UIView

@property (nonatomic, weak  ) id<HHPlayerProgressViewDelegate> delegate;

//缓冲条，loadTime
@property (nonatomic, strong) UIProgressView     * loadProgressView;
//进度条
@property (nonatomic, strong) HHPlayerSlider     * playSlider;

@property (nonatomic, assign) float loadTimeProgress;          //设置缓冲progress
@property (nonatomic, assign) float playProgress;              //设置sliderValue

//获取滑块的值
- (float)getSliderValue;
/*
 * 功能 ：更新进度条
 * 参数 ：currentTime 当前播放时间
 durationTime 播放总时长
 */
- (void)updateProgressWithCurrentTime:(float)currentTime durationTime : (float)durationTime;


@end

NS_ASSUME_NONNULL_END
