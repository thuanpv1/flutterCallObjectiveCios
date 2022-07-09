//
// StackViewShell.h
// demo
//
// Created by VINSON on 2019/11/19.
// Copyright © 2019 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This is a time-critical product of this class and requires further adjustments to achieve this generic UI display container
 */
@interface StackViewShell : NSObject
@property (nonatomic, weak, readonly) UIStackView *target;

/**
 Configure UIStackView
 */
-(void)shell:(UIStackView*)target;

/**
 Add View, the main axis direction is adaptive, and the secondary axis is limited by StackView. (Main axis: the layout extension direction of UIStackView)
 */
-(void)add:(NSString*)name view:(UIView*)view;

/**
 Add View and add size constraints.
 */
-(void)add:(NSString*)name size:(CGSize)size view:(UIView*)view;

/**
 Delete the corresponding View
 */
-(void)remove:(NSString*)name;

/**
 delete all views
 */
-(void)removeAll;

/**
 Insert View at specified location
 */
-(void)insert:(NSString*)name view:(UIView*)view atIndex:(int)index;
-(void)insert:(NSString*)name size:(CGSize)size view:(UIView*)view atIndex:(int)index;

/**
 Hide View
 */
-(void)hide:(BOOL)hide Name:(NSString*)name;

/**
 Get View object
 */
-(nullable UIView*)view:(NSString*)name;
@end

NS_ASSUME_NONNULL_END