//
//  HHPlayerTouchProgressLayer.h
//  RenMinWenLv
//
//  Created by mac mini on 2022/3/1.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#define MediaProgressViewHeight 130

typedef NS_ENUM(NSInteger,MediaProgressType)
{
    MediaProgress_brightness,
    MediaProgress_playerTime,
    MediaProgress_volume,
    MediaProgress_loading,
    MedipProgress_locked,
};

NS_ASSUME_NONNULL_BEGIN
@protocol HHPlayerTouchProgressLayerDelegate <NSObject>

-(void)unLockedScreen;

@end

@interface HHPlayerTouchProgressLayer : UIView

@property (weak,nonatomic) id<HHPlayerTouchProgressLayerDelegate>delegate;

-(void)showProgressViewType:(MediaProgressType)_type;

-(void)hideProgressView;

-(void)hideLoadingView;

-(void)setProgress:(float)_progress type:(MediaProgressType)_type;

-(void)endDisplay;



@end

NS_ASSUME_NONNULL_END
