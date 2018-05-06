//
//  SWRevealView.m
//  SWRevealViewController
//
//  Created by Alexander on 06.05.2018.
//  Copyright © 2018 solutions-in.cloud. All rights reserved.
//

#import "SWRevealView.h"
#import "SWStatusBar.h"
#import "Masonry.h"

@implementation SWRevealView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeItems];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self makeItems];
    }
    return self;
}

#pragma mark - Make

- (void)makeItems {
    self.frame = [UIScreen mainScreen].bounds;
    _frontView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_frontView];
    [self.frontView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - Methods

- (CGRect)hierarchycalFrameAdjustment:(CGRect)frame {
    if (self.presentFrontViewHierarchically) {
        UINavigationBar *dummyBar = [[UINavigationBar alloc] init];
        CGFloat barHeight = [dummyBar sizeThatFits:CGSizeMake(100,100)].height;
        CGFloat offset = barHeight + statusBarAdjustment(self);
        frame.origin.y += offset;
        frame.size.height -= offset;
    }
    return frame;
}

- (void)prepareRearViewForPosition:(FrontViewPosition)newPosition frontViewPosition:(FrontViewPosition)frontViewPosition {
    if ( ! _rearView) {
        _rearView = [[UIView alloc] initWithFrame:self.bounds];
        _rearView.autoresizingMask = /*UIViewAutoresizingFlexibleWidth|*/UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_rearView belowSubview:_frontView];
    }
    CGFloat xLocation = [self frontLocationForPosition:frontViewPosition];
    [self _layoutRearViewsForLocation:xLocation];
    [self _prepareForNewPosition:newPosition];
}

- (void)prepareRightViewForPosition:(FrontViewPosition)newPosition frontViewPosition:(FrontViewPosition)frontViewPosition {
    if ( ! _rightView) {
        _rightView = [[UIView alloc] initWithFrame:self.bounds];
        _rightView.autoresizingMask = /*UIViewAutoresizingFlexibleWidth|*/UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_rightView belowSubview:_frontView];
    }
    CGFloat xLocation = [self frontLocationForPosition:frontViewPosition];
    [self _layoutRearViewsForLocation:xLocation];
    [self _prepareForNewPosition:newPosition];
}

- (void)unloadRearView
{
    [_rearView removeFromSuperview];
    _rearView = nil;
}


- (void)unloadRightView
{
    [_rightView removeFromSuperview];
    _rightView = nil;
}


- (CGFloat)frontLocationForPosition:(FrontViewPosition)frontViewPosition
{
    CGFloat revealWidth;
    CGFloat revealOverdraw;
    
    CGFloat location = 0.0f;
    
    int symetry = frontViewPosition<FrontViewPositionLeft? -1 : 1;
    [_c _getRevealWidth:&revealWidth revealOverDraw:&revealOverdraw forSymetry:symetry];
    [_c _getAdjustedFrontViewPosition:&frontViewPosition forSymetry:symetry];
    
    if ( frontViewPosition == FrontViewPositionRight )
        location = revealWidth;
    
    else if ( frontViewPosition > FrontViewPositionRight )
        location = revealWidth + revealOverdraw;
    
    return location*symetry;
}


- (void)dragFrontViewToXLocation:(CGFloat)xLocation
{
    CGRect bounds = self.bounds;
    
    xLocation = [self _adjustedDragLocationForLocation:xLocation];
    [self _layoutRearViewsForLocation:xLocation];
    
    CGRect frame = CGRectMake(xLocation, 0.0f, bounds.size.width, bounds.size.height);
    _frontView.frame = [self hierarchycalFrameAdjustment:frame];
}


# pragma mark - overrides

- (void)layoutSubviews {
    if (_disableLayout == NO) {
        if (self.blockLayoutSubviews) {
            self.blockLayoutSubviews();
        }
    }
}

- (BOOL)pointInsideD:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL isInside = [super pointInside:point withEvent:event];
    if (self.blockPointInside) {
        self.blockPointInside(&isInside, point, event);
    }
    return isInside;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL isInside = [super pointInside:point withEvent:event];
    if (self.blockPointInside) {
        self.blockPointInside(&isInside, point, event);
    }
    return isInside;
}

# pragma mark - private

- (void)_layoutRearViewsForLocation:(CGFloat)xLocation {
    if (self.blockLayoutRearViews) {
        self.blockLayoutRearViews(xLocation);
    }
}

- (void)_prepareForNewPosition:(FrontViewPosition)newPosition;
{
    if ( _rearView == nil || _rightView == nil )
        return;
    
    int symetry = newPosition<FrontViewPositionLeft? -1 : 1;
    
    NSArray *subViews = self.subviews;
    NSInteger rearIndex = [subViews indexOfObjectIdenticalTo:_rearView];
    NSInteger rightIndex = [subViews indexOfObjectIdenticalTo:_rightView];
    
    if ( (symetry < 0 && rightIndex < rearIndex) || (symetry > 0 && rearIndex < rightIndex) )
        [self exchangeSubviewAtIndex:rightIndex withSubviewAtIndex:rearIndex];
}


- (CGFloat)_adjustedDragLocationForLocation:(CGFloat)x
{
    CGFloat result;
    
    CGFloat revealWidth;
    CGFloat revealOverdraw;
    BOOL bounceBack;
    BOOL stableDrag;
    FrontViewPosition position = _c.frontViewPosition;
    
    int symetry = x<0 ? -1 : 1;
    
    [_c _getRevealWidth:&revealWidth revealOverDraw:&revealOverdraw forSymetry:symetry];
    [_c _getBounceBack:&bounceBack pStableDrag:&stableDrag forSymetry:symetry];
    
    BOOL stableTrack = !bounceBack || stableDrag || position==FrontViewPositionRightMost || position==FrontViewPositionLeftSideMost;
    if ( stableTrack )
    {
        revealWidth += revealOverdraw;
        revealOverdraw = 0.0f;
    }
    
    x = x * symetry;
    
    if (x <= revealWidth)
        result = x;         // Translate linearly.
    
    else if (x <= revealWidth+2*revealOverdraw)
        result = revealWidth + (x-revealWidth)/2;   // slow down translation by halph the movement.
    
    else
        result = revealWidth+revealOverdraw;        // keep at the rightMost location.
    
    return result * symetry;
}

@end
