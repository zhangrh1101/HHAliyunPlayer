//
//  HHPlayerPopLayer.m
//  VideoTest
//
//  Created by mac mini on 2022/2/25.
//

#import "HHPlayerPopLayer.h"
#import "HHPlayerUtil.h"

@interface HHPlayerPopLayer () <HHPlayerPopLayerDelegate>

@property (nonatomic, strong) UIButton  * backButton;                  //返回按钮
@property (nonatomic, strong) UIButton  * retryButton;                 //界面中点击按钮
@property (nonatomic, strong) UILabel   * errorLabel;                  //错误信息

@property (nonatomic, assign) CGFloat     retryWidth;                  //按钮宽度

@end

//容错视图
@implementation HHPlayerPopLayer

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        _backButton.adjustsImageWhenHighlighted = NO;
        [_backButton setImage:[HHPlayerUtil imageWithName:@"hh_video_player_back"] forState:UIControlStateNormal];
        [_backButton setImage:[HHPlayerUtil imageWithName:@"hh_video_player_back"] forState:UIControlStateHighlighted];
        [_backButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)retryButton{
    if (!_retryButton) {
        _retryButton = [[UIButton alloc] init];
        _retryButton.adjustsImageWhenHighlighted = NO;
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_retryButton setTitle:@"重试" forState:UIControlStateNormal];
        [_retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(retryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _retryButton.layer.cornerRadius = 16;
        _retryButton.backgroundColor = KHHPlayerMainColor;
    }
    return _retryButton;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.font = [UIFont systemFontOfSize:14];
        _errorLabel.textColor = [UIColor whiteColor];
        _errorLabel.numberOfLines = 0;
    }
    return _errorLabel;
}


#pragma mark - init
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
      
        self.retryWidth = 80;
        
        [self addSubview:self.backButton];
        [self addSubview:self.retryButton];
        [self addSubview:self.errorLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //返回按钮
    if (self.isPortrait) {
        self.backButton.frame = CGRectMake(0, 0, HHTopViewPlayBackButtonWidth, HHTopViewPlayBackButtonWidth);
    }else{
        self.backButton.frame = CGRectMake(KHHPlayerMarginTop, 0, HHTopViewPlayBackButtonWidth, HHTopViewPlayBackButtonWidth);
    }
    
    self.retryButton.frame = CGRectMake(self.frame.size.width / 2 - self.retryWidth/2, self.frame.size.height / 2 - 20, self.retryWidth, 32);
    self.errorLabel.frame = CGRectMake(40, CGRectGetMaxY(self.retryButton.frame), self.frame.size.width-80, 60);
}


- (void)setHideBack:(BOOL)hideBack {
    _hideBack = hideBack;
    self.backButton.hidden = hideBack;
}

- (void)setIsPortrait:(BOOL)isPortrait {
    _isPortrait = isPortrait;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


#pragma mark - 按钮点击
- (void)onClick:(UIButton *)button {
    if (![HHPlayerUtil isInterfaceOrientationPortrait]) {
        [HHPlayerUtil setFullOrHalfScreen];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onBackClickedWithAlPVPopLayer:)]) {
            [self.delegate onBackClickedWithAlPVPopLayer:self];
        }
    }
}

- (void)retryButtonClick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRetryClickedWithHHPlayerErrorType:)]) {
        [self.delegate onRetryClickedWithHHPlayerErrorType:self.type];
    }
}


#pragma mark - public method
/*
 #define ALIYUNVODVIEW_UNKNOWN              @"未知错误"
 #define ALIYUNVODVIEW_PLAYFINISH           @"再次观看，请点击重新播放"
 #define ALIYUNVODVIEW_NETWORKTIMEOUT       @"当前网络不佳，请稍后点击重新播放"
 #define ALIYUNVODVIEW_NETWORKUNREACHABLE   @"无网络连接，检查网络后点击重新播放"
 #define ALIYUNVODVIEW_LOADINGDATAERROR     @"视频加载出错，请点击重新播放"
 #define ALIYUNVODVIEW_USEMOBILENETWORK     @"当前为移动网络，请点击播放"
 */
- (void)showPopViewWithCode:(ALYPVPlayerPopCode)code popMsg:(NSString *)popMsg {
   
    HHPlayerErrorType type = HHErrorTypeRetry;
    NSString *retryText = @"重新加载";
    NSString *errorText = @"加载失败，点击重试";
    switch (code) {
        case ALYPVPlayerPopCodePlayFinish:
        {
            retryText = @"重新播放";
            errorText = @"再次观看，请点击重新播放";
            type = HHErrorTypeReplay;
        }
            break;
        case ALYPVPlayerPopCodeNetworkTimeOutError :
        {
            retryText = @"重新播放";
            errorText = @"当前网络不佳，请稍后点击重新播放";
            type = HHErrorTypePause;
        }
            break;
        case ALYPVPlayerPopCodeUnreachableNetwork:
        {
            retryText = @"重新播放";
            errorText = @"无网络连接，检查网络后点击重新播放";
            type = HHErrorTypePause;
        }
            break;
        case ALYPVPlayerPopCodeLoadDataError :
        {
            retryText = @"重新播放";
            errorText = @"视频加载出错，请点击重新播放";
            type = HHErrorTypeRetry;
        }
            break;
        case ALYPVPlayerPopCodeServerError:
        {
            errorText = popMsg;
            type = HHErrorTypeRetry;
        }
            break;
        case ALYPVPlayerPopCodeUseMobileNetwork:
        {

            retryText = @"使用流量播放";
            errorText = @"正在使用非Wi-Fi网络，播放将产生流量费用";
            type = HHErrorTypeUseMobileNetwork;

        }
            break;
        case ALYPVPlayerPopCodeSecurityTokenExpired:
        {
            errorText = popMsg;
            type = HHErrorTypeStsExpired;
        }
            break;
        default:
            break;
    }
    
    self.type = type;
    [self.retryButton setTitle:retryText forState:UIControlStateNormal];
    self.errorLabel.text = errorText;
    
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGFloat width = [retryText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 35) options:options attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.width;
    self.retryWidth = ceilf(width + 30);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


@end
