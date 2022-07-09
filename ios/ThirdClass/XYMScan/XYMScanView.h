//
//  XYMScanView.h
//  healthcoming
//
//  Created by jack xu on 16/11/16.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XYMScanViewDelegate <NSObject>

-(void)getScanDataString:(NSString*)scanDataString;

@end


@interface XYMScanView : UIView

@property (nonatomic,assign) id<XYMScanViewDelegate> delegate;
@property (nonatomic,assign) int scanW; //width of scan frame
@property (nonatomic,assign) BOOL hiddenTipLb;
- (void)openFlash; //Open the flash
- (void)closeFlash; //Close the flash

- (void)startRunning; //Start scanning
- (void)stopRunning; //stop scanning

@end
