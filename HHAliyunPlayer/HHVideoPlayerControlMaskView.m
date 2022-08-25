//
//  HHVideoPlayerControlMaskView.m
//  VideoPlayer
//
//  Created by mac mini on 2022/2/22.
//

#import "HHVideoPlayerControlMaskView.h"

@interface HHVideoPlayerControlMaskView ()

@property (nonatomic, assign, readwrite) HHMaskStyle style;

@end

@implementation HHVideoPlayerControlMaskView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithStyle:(HHMaskStyle)style {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    self.style = style;
    CAGradientLayer *maskGradientLayer = (id)self.layer;
    switch (_style) {
        case HHMaskStyle_top: {
            maskGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.7].CGColor,
                                         (__bridge id)[UIColor clearColor].CGColor];
        }
            break;
        case HHMaskStyle_bottom: {
            maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                         (__bridge id)[UIColor colorWithWhite:0 alpha:0.7].CGColor];
        }
            break;
    }
    return self;
}


- (void)addColorsWithStyle:(HHMaskStyle)style {
    CAGradientLayer *maskGradientLayer = (id)self.layer;
    switch (style) {
        case HHMaskStyle_top: {
            maskGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.7].CGColor,
                                         (__bridge id)[UIColor clearColor].CGColor];
        }
            break;
        case HHMaskStyle_bottom: {
            maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                         (__bridge id)[UIColor colorWithWhite:0 alpha:0.7].CGColor];
        }
        break;
    }
}

- (void)cleanColors {
    CAGradientLayer *maskGradientLayer = (id)self.layer;
    maskGradientLayer.colors = nil;
}



@end
