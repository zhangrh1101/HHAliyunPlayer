//
//  HHPlayerPrivateDefine.h
//  VideoPlayer
//
//  Created by mac mini on 2022/2/23.
//

#ifndef HHPlayerPrivateDefine_h
#define HHPlayerPrivateDefine_h

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)
#define IS_IPHONE_X (IS_IOS_11 && IS_IPHONE && (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 375 && MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 812))


#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

//安全距离
#define KHHPlayerMarginTop        (IS_IPHONE_X ? 44 : 0)
#define KHHPlayerMarginBottom     (IS_IPHONE_X ? 34 : 0)

#define RGBA(r,g,b,a)       [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:(a)]

#define RGBOF(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

// 播控事件中的类型
#define KHHPlayerMainColor                    [UIColor colorWithRed:(232 / 255.0) green:(132 / 255.0) blue:(30 / 255.0) alpha:1]
#define kHHPopErrorViewBackGroundColor        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
#define kHHPopSeekTextColor                   [UIColor colorWithRed:55 / 255.0 green:55 / 255.0 blue:55 / 255.0 alpha:1]
#define kHHColorTextNomal                     [UIColor colorWithRed:(231 / 255.0) green:(231 / 255.0) blue:(231 / 255.0) alpha:1]
#define kHHColorTextGray                      [UIColor colorWithRed:(158 / 255.0) green:(158 / 255.0) blue:(158 / 255.0) alpha:1]


static const CGFloat HHTopViewPlayBackButtonWidth        = 50;                         //返回按钮宽度
static const CGFloat HHTopViewPlayButtonWidth            = 50;                         //返回按钮宽度

static const CGFloat HHPlayerViewButtonWidth             = 50;                         //播放按钮宽度
static const CGFloat HHBottonViewFullScreenTimeWidth     = 80 + 40;                    //全屏时间宽度
static const CGFloat HHBottonViewFullScreenLeftWidth     = 60;                         //全屏左右时间宽度
static const CGFloat HHBottomViewTextSizeFont            = 12.0f;                      //字体字号

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, HHPlayerPanDirection){
    HHPlayerPanDirectionHorizontalMoved, ///< 横向移动
    HHPlayerPanDirectionVerticalMoved,   ///< 纵向移动
};


typedef NS_ENUM (int, HHPlayerErrorType) {
    HHErrorTypeUnknown = 0,
    HHErrorTypeRetry,
    HHErrorTypeReplay,
    HHErrorTypePause,
    HHErrorTypeStsExpired,
    HHErrorTypeUseMobileNetwork,
};

typedef NS_ENUM(int, ALYPVPlayerPopCode) {
    // 未知错误
    ALYPVPlayerPopCodeUnKnown = 0,
    // 当用户播放完成后提示用户可以重新播放。    再次观看，请点击重新播放
    ALYPVPlayerPopCodePlayFinish = 1,
    // 用户主动取消播放
    ALYPVPlayerPopCodeStop = 2,
    // 服务器返回错误情况
    ALYPVPlayerPopCodeServerError= 3,
    // 播放中的情况
    // 当网络超时进行提醒（文案统一可以定义），用户点击可以进行重播。      当前网络不佳，请稍后点击重新播放
    ALYPVPlayerPopCodeNetworkTimeOutError = 4,
    // 断网时进行断网提醒，点击可以重播（按记录已经请求成功的url进行请求播放） 无网络连接，检查网络后点击重新播放
    ALYPVPlayerPopCodeUnreachableNetwork = 5,
    // 当视频加载出错时进行提醒，点击可重新加载。   视频加载出错，请点击重新播放
    ALYPVPlayerPopCodeLoadDataError = 6,
    //当用户使用移动网络播放时，首次不进行自动播放，给予提醒当前的网络状态，用户可手动使用移动网络进行播放。顶部提示条仅显示4秒自动消失。当用户从wifi切到移动网络时，暂定当前播放给予用户提示当前的网络，用户可以点击播放后继续当前播放。
    ALYPVPlayerPopCodeUseMobileNetwork = 7,
    // ststoken过期，需要重新请求
    ALYPVPlayerPopCodeSecurityTokenExpired = 8,
    
    ALYPVPlayerPopCodePreview  = 9,
};

#endif /* HHPlayerPrivateDefine_h */
