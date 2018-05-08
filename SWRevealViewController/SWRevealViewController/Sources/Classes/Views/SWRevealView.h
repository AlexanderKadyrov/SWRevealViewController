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

@property (nonatomic, assign) BOOL presentFrontViewHierarchically;
@property (nonatomic, assign) BOOL disableLayout;

#pragma mark - Methods

- (CGRect)hierarchycalFrameAdjustment:(CGRect)frame;
- (void)prepareRearViewForPosition:(FrontViewPosition)newPosition frontViewPosition:(FrontViewPosition)frontViewPosition;
- (void)prepareRightViewForPosition:(FrontViewPosition)newPosition frontViewPosition:(FrontViewPosition)frontViewPosition;
- (void)unloadRearView;
- (void)unloadRightView;
- (CGFloat)frontLocationForPosition:(FrontViewPosition)frontViewPosition;
- (void)dragFrontViewToXLocation:(CGFloat)xLocation;

#pragma mark - Blocks

@property (nonatomic, copy) void (^blockFrontLocationForPosition)(FrontViewPosition *frontViewPosition, CGFloat *revealOverdraw, CGFloat *revealWidth, NSInteger symetry);
@property (nonatomic, copy) void (^blockPointInsideD)(BOOL *isInside, CGPoint point, UIEvent *event);
@property (nonatomic, copy) void (^blockPointInside)(BOOL *isInside, CGPoint point, UIEvent *event);
@property (nonatomic, copy) void (^blockLayoutRearViews)(CGFloat locationX);
@property (nonatomic, copy) dispatch_block_t blockLayoutSubviews;

@end
