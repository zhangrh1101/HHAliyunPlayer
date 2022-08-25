//
//  HHPlayerUtil.m
//  VideoPlayer
//
//  Created by mac mini on 2022/2/23.
//

#import "HHPlayerUtil.h"

@implementation HHPlayerUtil

+ (BOOL)isInterfaceOrientationPortrait {
    UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
    return o == UIInterfaceOrientationPortrait;
}

+ (void)setFullOrHalfScreen {
    BOOL isFull = [self isInterfaceOrientationPortrait];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = isFull ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
        
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
}

+ (UIImage *)imageWithName:(NSString *)name {
    
    //    int scale = (int)UIScreen.mainScreen.scale;
    //    scale = MIN(MAX(scale, 2), 3);
    
    UIImage *image = nil;
    
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSString *image_path = [resourcePath stringByAppendingPathComponent:image_name];
    
    image = [[UIImage alloc] initWithContentsOfFile:image_path];
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


+ (NSBundle *)resourceBundle {
    NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"HHAliyunPlayer" ofType:@"bundle"]];
    if (!resourceBundle) {
        resourceBundle = [NSBundle mainBundle];
    }
    return resourceBundle;
}


+ (NSString *)timeformatFromSeconds:(NSInteger)seconds {
    //format of hour
    seconds = seconds/1000;
    NSString *str_hour = [NSString stringWithFormat:@"%02ld", (long) seconds / 3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (long) (seconds % 3600) / 60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", (long) seconds % 60];
    //format of time
    NSString *format_time = nil;
    if (seconds / 3600 <= 0) {
        format_time = [NSString stringWithFormat:@"00:%@:%@", str_minute, str_second];
    } else {
        format_time = [NSString stringWithFormat:@"%@:%@:%@", str_hour, str_minute, str_second];
    }
    return format_time;
}



+ (UIWindow *)getCurrentWindow {
    
    if ([[[UIApplication sharedApplication] delegate] window]) {
        return[[[UIApplication sharedApplication] delegate] window];
    }else{
        if(@available(iOS 13.0, *)) {
            NSArray *array =[[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene *windowScene = (UIWindowScene*)array[0];
            
            //如果是普通App开发，可以使用
            //SceneDelegate * delegate = (SceneDelegate *)windowScene.delegate;
            //UIWindow * mainWindow = delegate.window;
            
            UIWindow* mainWindow = [windowScene valueForKeyPath:@"delegate.window"];
            if (mainWindow) {
                return mainWindow;
            }else{
                return [UIApplication sharedApplication].windows.lastObject;
            }
        }else{
            return [UIApplication sharedApplication].keyWindow;
        }
    }
}


+ (UIView*)makeEffectViewWithFrame:(CGRect)frame stype:(UIBlurEffectStyle)style cornerRadius:(float)cornerRadius {
    UIView* view;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
        //毛玻璃效果
        UIBlurEffect* effect = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        if (cornerRadius) {
            effectView.layer.cornerRadius = cornerRadius;
            effectView.layer.masksToBounds = true;
        }
        effectView.frame = frame;
        view = effectView;
    }else
    {
        view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        view.layer.cornerRadius = cornerRadius;
    }
    return view;
}

@end

