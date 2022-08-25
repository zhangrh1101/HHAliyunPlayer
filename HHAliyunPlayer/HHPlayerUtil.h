//
//  HHPlayerUtil.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HHPlayerUtil : NSObject

//是否手机状态条处于竖屏状态
+ (BOOL)isInterfaceOrientationPortrait;

//是否全屏
+ (void)setFullOrHalfScreen;

//从图片库获取图片
+ (UIImage *)imageWithName:(NSString *)name;

//根据s-》hh:mm:ss
+ (NSString *)timeformatFromSeconds:(NSInteger)seconds;

+ (UIWindow *)getCurrentWindow;

//毛玻璃效果
+ (UIView*)makeEffectViewWithFrame:(CGRect)frame stype:(UIBlurEffectStyle)style cornerRadius:(float)cornerRadius;

@end

NS_ASSUME_NONNULL_END
