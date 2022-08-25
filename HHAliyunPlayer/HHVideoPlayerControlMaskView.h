//
//  HHVideoPlayerControlMaskView.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 style

 - SJMaskStyle_bottom:  从上到下的颜色 浅->深
 - SJMaskStyle_top:     从上到下的颜色 深->浅
 */
typedef NS_ENUM(NSUInteger, HHMaskStyle) {
    HHMaskStyle_bottom,
    HHMaskStyle_top,
};

@interface HHVideoPlayerControlMaskView : UIView

- (instancetype)initWithStyle:(HHMaskStyle)style;

- (void)addColorsWithStyle:(HHMaskStyle)style;

- (void)cleanColors;

@end

NS_ASSUME_NONNULL_END
