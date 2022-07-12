//
//  PreviewViewController.h
//  demo
//
//  Created by admin on 2022/3/31.
//  Copyright © 2022 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiPreviewPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreviewViewController : UIViewController
-(instancetype)initViewAllCamera:(NSArray<NVDevice*>*)devices atDeviceIndex:(int)deviceIndex isShowToolBtns: (BOOL) isShowToolBtns isMultiView: (BOOL) isMultiView;
-(instancetype)initWithDevices:(NSArray<NVDevice*>*)devices atDeviceIndex:(int)index;
-(void)returnAndreleaseAll;
-(void)updatePageWithDeviceIndex:(int)deviceIndex onPano:(BOOL)pano;
-(UIView*) getPlayerView;
-(void)startWithDeviceIndex:(int)deviceIndex mute:(BOOL)mute hd:(BOOL)hd;
@property (nonatomic,strong) MultiPreviewPlayer *player;
@end

NS_ASSUME_NONNULL_END
