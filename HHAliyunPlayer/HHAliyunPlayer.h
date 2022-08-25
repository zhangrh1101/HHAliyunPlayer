//
//  HHAliyunPlayer.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/21.
//

#import <UIKit/UIKit.h>
#import <AliyunPlayer/AliyunPlayer.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ToolTopBarHiddenType) {
    ToolTopBarHiddenNever = 0, ///<小屏和全屏都不隐藏
    ToolTopBarHiddenAlways,    ///<小屏和全屏都隐藏
    ToolTopBarHiddenSmall,     ///<小屏隐藏，全屏不隐藏
};

@interface HHPlayerViewConfigure : NSObject
/**自动播放 默认No*/
@property (nonatomic, assign) BOOL                    autoPlay;
/**后台返回是否自动播放，默认Yes,会跟随用户，如果是播放状态进入后台，返回会继续播放*/
@property (nonatomic, assign) BOOL                    backPlay;
/**重复播放,默认No*/
@property (nonatomic, assign) BOOL                    repeatPlay;
/**当前页面是否支持横屏,默认NO*/
@property (nonatomic, assign) BOOL                    isLandscape;
/**自动旋转，默认Yes*/
@property (nonatomic, assign) BOOL                    autoRotate;
/**静音,默认为NO*/
@property (nonatomic, assign) BOOL                    mute;
/**播放速率 */
@property (nonatomic, assign) float                   rate;
/**小屏手势控制,默认NO*/
@property (nonatomic, assign) BOOL                    smallGestureControl;
/**全屏手势控制,默认Yes*/
@property (nonatomic, assign) BOOL                    fullGestureControl;;
/**工具条消失时间，默认10s*/
@property (nonatomic, assign) NSInteger               toolBarDisappearTime;
/**顶部工具条隐藏方式，默认不隐藏*/
@property (nonatomic, assign) ToolTopBarHiddenType    topToolBarHiddenType;
/**进度条背景颜色*/
@property (nonatomic, strong) UIColor                 *progressBackgroundColor;
/**缓冲条缓冲进度颜色*/
@property (nonatomic, strong) UIColor                 *progressBufferColor;
/**进度条播放完成颜色*/
@property (nonatomic, strong) UIColor                 *progressPlayFinishColor;
/**转子背景颜色*/
@property (nonatomic, strong) UIColor                 *strokeColor;

/**
 默认配置
 @return 配置
 */
+ (instancetype)defaultConfigure;

@end

@interface HHAliyunPlayer : UIView

/**视频url*/
@property (nonatomic, copy)   NSString                      *   url;
/**封面*/
@property (nonatomic, strong) UIImageView                   *   coverImageView;

/**
 @brief 初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate;

/**
 @brief 更新播放器基本配置
 */
- (void)updateWithConfigure:(void(^)(HHPlayerViewConfigure *configure))configureBlock;

/**是否支持旋转*/
- (void)canRotation:(BOOL)canRotation;

/**
 @brief 开始播放
 */
-(void)start;

/**
 @brief 暂停播放
 */
-(void)pause;

/**
 @brief 停止播放
 */
-(void)stop;

/**播放完成回调*/
//- (void)endPlay:(EndBolck) end;

/**
 功能：重播
 */
- (void)replay;

/**
 功能：重置
 */
- (void)retry;

/**
 功能：停止播放销毁图层
 */
- (void)reset;

/**
 功能：释放播放器
 */
- (void)destroyPlayer;


- (AVPStatus)playerViewState;


@end

NS_ASSUME_NONNULL_END
