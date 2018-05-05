//
//  SWRevealView.h
//  SWRevealViewController
//
//  Created by Alexander on 06.05.2018.
//  Copyright © 2018 solutions-in.cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWRevealViewController;

@interface SWRevealView: UIView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame controller:(SWRevealViewController *)controller;

#pragma mark - Properties

@property (nonatomic, readonly) UIView *rearView;
@property (nonatomic, readonly) UIView *rightView;
@property (nonatomic, readonly) UIView *frontView;
@property (nonatomic, assign) BOOL disableLayout;

#pragma mark - Methods

- (void)reloadShadow;
- (void)prepareRearViewForPosition:(FrontViewPosition)newPosition;
- (void)prepareRightViewForPosition:(FrontViewPosition)newPosition;
- (void)unloadRearView;
- (void)unloadRightView;
- (CGFloat)frontLocationForPosition:(FrontViewPosition)frontViewPosition;
- (void)dragFrontViewToXLocation:(CGFloat)xLocation;

@end
