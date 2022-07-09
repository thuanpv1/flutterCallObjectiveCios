//
//  ZTRulerControl.h
//  iCamSee
//
//  Created by hs_mac on 2018/1/2.
//  Copyright © 2018年 macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol rulerScrollDidEndDelegate<NSObject>

@required

// Called when scrolling ends
-(void)rulerScrollDidEndResult:(CGFloat)currentSeconds;

// called when scrolling
-(void)rulerDidScroll:(CGFloat)currentSeconds;
@end

@interface ZTRulerControl : UIControl<UIScrollViewDelegate,UIGestureRecognizerDelegate>


@property (nonatomic, assign) IBInspectable CGFloat selectedValue;//The selected value

@property (nonatomic, assign) IBInspectable NSInteger minValue;//Minimum

@property (nonatomic, assign) IBInspectable NSInteger maxValue;//Maximum

@property (nonatomic, assign) IBInspectable NSInteger valueStep;//step size

@property (nonatomic, assign) IBInspectable CGFloat minorScaleSpacing;//Minor scale spacing

@property (nonatomic, assign) IBInspectable CGFloat majorScaleLength;//Length of major scale

@property (nonatomic, assign) IBInspectable CGFloat middleScaleLength;//Length of middle scale

@property (nonatomic, assign) IBInspectable CGFloat minorScaleLength;//Minor scale length

@property (nonatomic, strong) IBInspectable UIColor *rulerBackgroundColor;//Scale background color

@property (nonatomic, strong) IBInspectable UIColor *scaleColor;//Scale color

@property (nonatomic, strong) IBInspectable UIColor *scaleFontColor;// scale font color

@property (nonatomic, assign) IBInspectable CGFloat scaleFontSize;//scale font size

@property (nonatomic, strong) IBInspectable UIColor *indicatorColor;//Indicator color

@property (nonatomic, assign) IBInspectable CGFloat indicatorLength;//Indicator length

@property (nonatomic, assign) IBInspectable NSInteger midCount;//Several large grids mark a scale

@property (nonatomic, assign) IBInspectable NSInteger smallCount;//Several small cells in a large cell

@property (nonatomic,strong) NSArray *recFileList;

@property (nonatomic, weak) id<rulerScrollDidEndDelegate>delegate;

@property (nonatomic,assign,readonly) BOOL isEditing;

+(instancetype) rulerStyleDefault:(CGRect)frame; // default style
+(instancetype) rulerStyleLanscape:(CGRect)frame; // Landscape style

+(instancetype) rulerStyleCloudDisk:(CGRect)frame; // Special for cloud disk //add by xie yongsheng 20190316 for cloud disk
-(void)setReverseFileList:(NSArray *)fileList; //This interface will reverse the incoming array。
@end
