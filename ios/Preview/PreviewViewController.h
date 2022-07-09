//
//  PreviewViewController.h
//  demo
//
//  Created by admin on 2022/3/31.
//  Copyright © 2022 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreviewViewController : UIViewController
-(instancetype)initWithDevices:(NSArray<NVDevice*>*)devices atDeviceIndex:(int)index;

@end

NS_ASSUME_NONNULL_END
