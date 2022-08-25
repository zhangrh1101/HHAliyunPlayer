//
//  HHPlayerSlider.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHPlayerSlider : UISlider

// 手势刚开始的value
@property (nonatomic, assign, readonly) CGFloat beginPressValue;


@end

NS_ASSUME_NONNULL_END
