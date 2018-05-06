//
//  SWRevealView.h
//  SWRevealViewController
//
//  Created by Alexander on 06.05.2018.
//  Copyright © 2018 solutions-in.cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface SWRevealView: UIView

#pragma mark - Properties

@property (nonatomic, readonly) UIView *rearView;
@property (nonatomic, readonly) UIView *rightView;
@property (nonatomic, readonly) UIView *frontView;
@property (nonatomic, assign) BOOL disableLayout;

#pragma mark - Methods

- (void)prepareRearViewForPosition:(FrontViewPosition)newPosition;
- (void)prepareRightViewForPosition:(FrontViewPosition)newPosition;
- (void)unloadRearView;
- (void)unloadRightView;
- (CGFloat)frontLocationForPosition:(FrontViewPosition)frontViewPosition;
- (void)dragFrontViewToXLocation:(CGFloat)xLocation;

#pragma mark - Blocks

@property (nonatomic, copy) void (^blockPointInside)(BOOL *isInside, CGPoint point, UIEvent *event);

@end
