//
//  SWStatusBar.m
//  SWRevealViewController
//
//  Created by Alexander on 06.05.2018.
//  Copyright © 2018 solutions-in.cloud. All rights reserved.
//

#import "SWStatusBar.h"

@implementation SWStatusBar

#pragma mark - StatusBar Helper Function

// computes the required offset adjustment due to the status bar for the passed in view,
// it will return the statusBar height if view fully overlaps the statusBar, otherwise returns 0.0f

+ (CGFloat)statusBarAdjustment:(UIView *)view {
    CGFloat adjustment = 0.0f;
    UIApplication *app = [UIApplication sharedApplication];
    CGRect viewFrame = [view convertRect:view.bounds toView:[app keyWindow]];
    CGRect statusBarFrame = [app statusBarFrame];
    if (CGRectIntersectsRect(viewFrame, statusBarFrame)) {
        adjustment = fminf(statusBarFrame.size.width, statusBarFrame.size.height);
    }
    return adjustment;
}

@end
