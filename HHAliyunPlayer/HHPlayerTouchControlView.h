//
//  HHPlayerTouchControlView.h
//  RenMinWenLv
//
//  Created by mac mini on 2022/3/1.
//

#import <UIKit/UIKit.h>
#import "HHPlayerSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHPlayerTouchControlView : UIView

@property (nonatomic, assign) BOOL  smallGestureControl;              //小屏手势是否禁用
@property (nonatomic, assign) BOOL  isFullScreen;                     //是否为全屏

@end

NS_ASSUME_NONNULL_END
