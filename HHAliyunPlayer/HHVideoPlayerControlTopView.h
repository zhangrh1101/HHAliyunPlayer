//
//  HHVideoPlayerControlTopView.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/22.
//

#import "HHVideoPlayerControlMaskView.h"

NS_ASSUME_NONNULL_BEGIN

@class HHVideoPlayerControlTopView;
@protocol HHControlTopViewDelegate <NSObject>

/*
 * 功能 ：返回按钮，返回代理
 * 参数 ：topView 对象本身
 */
- (void)onClickedBackButtonWithTopView:(HHVideoPlayerControlTopView *)bottomView;

@end

@interface HHVideoPlayerControlTopView : HHVideoPlayerControlMaskView

@property (nonatomic, weak  ) id<HHControlTopViewDelegate> delegate;

@property (nonatomic, assign) BOOL isPortrait;                      //竖屏判断

@end

NS_ASSUME_NONNULL_END
