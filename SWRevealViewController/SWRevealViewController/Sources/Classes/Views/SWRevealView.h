//
//  SWRevealView.h
//  SWRevealViewController
//
//  Created by Alexander on 06.05.2018.
//  Copyright © 2018 solutions-in.cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWRevealViewController;
@class FrontViewPosition;

@interface SWRevealView: UIView {
    __weak SWRevealViewController *_c;
}

@property (nonatomic, readonly) UIView *rearView;
@property (nonatomic, readonly) UIView *rightView;
@property (nonatomic, readonly) UIView *frontView;
@property (nonatomic, assign) BOOL disableLayout;

@end


@interface SWRevealViewController ()

- (void)_getRevealWidth:(CGFloat *)pRevealWidth revealOverDraw:(CGFloat *)pRevealOverdraw forSymetry:(int)symetry;
- (void)_getBounceBack:(BOOL*)pBounceBack pStableDrag:(BOOL*)pStableDrag forSymetry:(int)symetry;
- (void)_getAdjustedFrontViewPosition:(FrontViewPosition *)frontViewPosition forSymetry:(int)symetry;

@end
