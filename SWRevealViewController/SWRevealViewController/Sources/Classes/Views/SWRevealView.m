//
//  SWRevealView.m
//  SWRevealViewController
//
//  Created by Alexander on 06.05.2018.
//  Copyright © 2018 solutions-in.cloud. All rights reserved.
//

#import "SWRevealView.h"
#import "SWStatusBar.h"

@interface SWRevealView ()
@property (nonatomic, strong, readonly) SWRevealViewController *c;
@end

@implementation SWRevealView

static CGFloat scaledValue( CGFloat v1, CGFloat min2, CGFloat max2, CGFloat min1, CGFloat max1)
{
    CGFloat result = min2 + (v1-min1)*((max2-min2)/(max1-min1));
    if ( result != result ) return min2;  // nan
    if ( result < min2 ) return min2;
    if ( result > max2 ) return max2;
    return result;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame controller:(SWRevealViewController *)controller {
    self = [super initWithFrame:frame];
    if (self) {
        _c = controller;
        CGRect bounds = self.bounds;
        _frontView = [[UIView alloc] initWithFrame:bounds];
        _frontView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self reloadShadow];
        [self addSubview:_frontView];
    }
    return self;
}

#pragma mark - Methods

- (void)reloadShadow {
    CALayer *frontViewLayer = _frontView.layer;
    frontViewLayer.shadowColor = [_c.frontViewShadowColor CGColor];
    frontViewLayer.shadowOpacity = _c.frontViewShadowOpacity;
    frontViewLayer.shadowOffset = _c.frontViewShadowOffset;
    frontViewLayer.shadowRadius = _c.frontViewShadowRadius;
}

- (CGRect)hierarchycalFrameAdjustment:(CGRect)frame
{
    if ( _c.presentFrontViewHierarchically )
    {
        UINavigationBar *dummyBar = [[UINavigationBar alloc] init];
        CGFloat barHeight = [dummyBar sizeThatFits:CGSizeMake(100,100)].height;
        CGFloat offset = barHeight + statusBarAdjustment(self);
        frame.origin.y += offset;
        frame.size.height -= offset;
    }
    return frame;
}


- (void)prepareRearViewForPosition:(FrontViewPosition)newPosition
{
    if ( _rearView == nil )
    {
        _rearView = [[UIView alloc] initWithFrame:self.bounds];
        _rearView.autoresizingMask = /*UIViewAutoresizingFlexibleWidth|*/UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_rearView belowSubview:_frontView];
    }
    
    CGFloat xLocation = [self frontLocationForPosition:_c.frontViewPosition];
    [self _layoutRearViewsForLocation:xLocation];
    [self _prepareForNewPosition:newPosition];
}


- (void)prepareRightViewForPosition:(FrontViewPosition)newPosition
{
    if ( _rightView == nil )
    {
        _rightView = [[UIView alloc] initWithFrame:self.bounds];
        _rightView.autoresizingMask = /*UIViewAutoresizingFlexibleWidth|*/UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_rightView belowSubview:_frontView];
    }
    
    CGFloat xLocation = [self frontLocationForPosition:_c.frontViewPosition];
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

- (void)layoutSubviews
{
    if ( _disableLayout ) return;
    
    CGRect bounds = self.bounds;
    
    FrontViewPosition position = _c.frontViewPosition;
    CGFloat xLocation = [self frontLocationForPosition:position];
    
    // set rear view frames
    [self _layoutRearViewsForLocation:xLocation];
    
    // set front view frame
    CGRect frame = CGRectMake(xLocation, 0.0f, bounds.size.width, bounds.size.height);
    _frontView.frame = [self hierarchycalFrameAdjustment:frame];
    
    // setup front view shadow path if needed (front view loaded and not removed)
    UIViewController *frontViewController = _c.frontViewController;
    BOOL viewLoaded = frontViewController != nil && frontViewController.isViewLoaded;
    BOOL viewNotRemoved = position > FrontViewPositionLeftSideMostRemoved && position < FrontViewPositionRightMostRemoved;
    CGRect shadowBounds = viewLoaded && viewNotRemoved  ? _frontView.bounds : CGRectZero;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:shadowBounds];
    _frontView.layer.shadowPath = shadowPath.CGPath;
}


- (BOOL)pointInsideD:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isInside = [super pointInside:point withEvent:event];
    if ( _c.extendsPointInsideHit )
    {
        if ( !isInside  && _rearView && [_c.rearViewController isViewLoaded] )
        {
            CGPoint pt = [self convertPoint:point toView:_rearView];
            isInside = [_rearView pointInside:pt withEvent:event];
        }
        
        if ( !isInside && _frontView && [_c.frontViewController isViewLoaded] )
        {
            CGPoint pt = [self convertPoint:point toView:_frontView];
            isInside = [_frontView pointInside:pt withEvent:event];
        }
        
        if ( !isInside && _rightView && [_c.rightViewController isViewLoaded] )
        {
            CGPoint pt = [self convertPoint:point toView:_rightView];
            isInside = [_rightView pointInside:pt withEvent:event];
        }
    }
    return isInside;
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isInside = [super pointInside:point withEvent:event];
    if ( !isInside && _c.extendsPointInsideHit )
    {
        UIView *testViews[] = { _rearView, _frontView, _rightView };
        UIViewController *testControllers[] = { _c.rearViewController, _c.frontViewController, _c.rightViewController };
        
        for ( NSInteger i=0 ; i<3 && !isInside ; i++ )
        {
            if ( testViews[i] && [testControllers[i] isViewLoaded] )
            {
                CGPoint pt = [self convertPoint:point toView:testViews[i]];
                isInside = [testViews[i] pointInside:pt withEvent:event];
            }
        }
    }
    return isInside;
}


# pragma mark - private


- (void)_layoutRearViewsForLocation:(CGFloat)xLocation
{
    CGRect bounds = self.bounds;
    
    CGFloat rearRevealWidth = _c.rearViewRevealWidth;
    if ( rearRevealWidth < 0) rearRevealWidth = bounds.size.width + _c.rearViewRevealWidth;
    
    CGFloat rearXLocation = scaledValue(xLocation, -_c.rearViewRevealDisplacement, 0, 0, rearRevealWidth);
    
    CGFloat rearWidth = rearRevealWidth + _c.rearViewRevealOverdraw;
    _rearView.frame = CGRectMake(rearXLocation, 0.0, rearWidth, bounds.size.height);
    
    CGFloat rightRevealWidth = _c.rightViewRevealWidth;
    if ( rightRevealWidth < 0) rightRevealWidth = bounds.size.width + _c.rightViewRevealWidth;
    
    CGFloat rightXLocation = scaledValue(xLocation, 0, _c.rightViewRevealDisplacement, -rightRevealWidth, 0);
    
    CGFloat rightWidth = rightRevealWidth + _c.rightViewRevealOverdraw;
    _rightView.frame = CGRectMake(bounds.size.width-rightWidth+rightXLocation, 0.0f, rightWidth, bounds.size.height);
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
