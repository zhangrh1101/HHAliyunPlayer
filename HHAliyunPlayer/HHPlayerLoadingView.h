//
//  HHPlayerLoadingView.h
//  CLDemo
//
//  Created by AUG on 2018/11/29.
//  Copyright © 2018年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHPlayerLoadingView : UIView

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;
@property (nonatomic) BOOL showsNetworkSpeed;
@property (nonatomic, strong, nullable) NSAttributedString *networkSpeedStr;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
