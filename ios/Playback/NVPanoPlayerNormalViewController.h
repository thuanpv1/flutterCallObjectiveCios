//
//  NVPanoPlayerNormalViewController.h
//  demo
//
//  Created by MacroVideo on 2018/2/8.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTPlayerVarDefine.h"
@interface NVPanoPlayerNormalViewController : UIViewController
@property (nonatomic,assign)RecordType currentRecordType;//Current recording type
@property(nonatomic,strong)NVDevice *device;
@property(nonatomic,strong)LoginHandle *loginResult;

@property(nonatomic, assign) BOOL isFromMultiPreview;//Four pictures into playback
@end