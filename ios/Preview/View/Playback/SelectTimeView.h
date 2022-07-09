//
//  SelectTimeView.h
//  iCamSee
//
//  Created by MacroVideo on 2018/7/16.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectTimeViewDelegate <NSObject>
-(void)selectedTimeBlock:(NSString*)str;
@end

@interface SelectTimeView : UIView
@property (nonatomic,weak) id <SelectTimeViewDelegate> delegate;
- (void)show;
@end

