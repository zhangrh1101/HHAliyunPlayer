//
//  HHPlayerPopLayer.h
//  VideoTest
//
//  Created by mac mini on 2022/2/25.
//

#import <UIKit/UIKit.h>
#import "HHPlayerPrivateDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class HHPlayerPopLayer;
@protocol HHPlayerPopLayerDelegate <NSObject>

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

@interface HHPlayerPopLayer : UIView

@property (nonatomic, weak) id<HHPlayerPopLayerDelegate>delegate;

@property (nonatomic, assign) HHPlayerErrorType    type;         //错误类型

@property (nonatomic, assign) BOOL hideBack;                     //返回按钮隐藏
@property (nonatomic, assign) BOOL isPortrait;                   //竖屏判断

/*
 * 功能 ：根据不同code，展示弹起的消息界面
 * 参数 ： code ： 事件
          popMsg ：自定义消息
 */
- (void)showPopViewWithCode:(ALYPVPlayerPopCode)code popMsg:(NSString *)popMsg;

@end

NS_ASSUME_NONNULL_END
