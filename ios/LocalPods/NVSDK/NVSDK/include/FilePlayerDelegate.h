//
//  FilePlayerDelegate.h
//  NVSDK
//
//  Created by macrovideo on 19/03/2018.
//  Copyright © 2018 macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FilePlayerDelegate <NSObject>
-(void)setFileParam:(int)nCamType panoX:(int) nPanoX panoY:(int) nPanoY panoRad:(int) nPanoRad timeLength:(int64_t) lTimeLength;
-(void)onProgressChange:(int) nProgress;
-(void)onTimeChange:(int64_t) lTimeCurrent;

@end
