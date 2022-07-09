//
//  DisplayMode.h
//  iCamSee
//
//  Created by VINSON on 2019/11/25.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CurtainView : UIView
@property (nonatomic,copy,nullable) void(^onClicked)(NSString *name, BOOL isSelected);
@property (nonatomic,strong) NSArray *onConstraints;
@property (nonatomic,strong) NSArray *offConstraints;
@property (nonatomic,assign) BOOL on;

@property (nonatomic,assign) BOOL exclusive;

-(void)configWithClose:(UIImage*)image title:(NSString*)title color:(UIColor*)color font:(UIFont*)font axis:(UILayoutConstraintAxis)axis;
/**
 #1
 name:
 normalImage
 selectedImage
 normalColor
 selectedColor
 normalBackground
 selectedBackground
 width:
 height:
 #2
 #3
 */
-(void)reset:(NSArray*)array;
@end

NS_ASSUME_NONNULL_END
