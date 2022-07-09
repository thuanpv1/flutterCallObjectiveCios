//
//  PresetCell.h
//  iCamSee
//
//  Created by VINSON on 2019/12/6.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresetCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (assign,nonatomic) BOOL edit;
@end

NS_ASSUME_NONNULL_END
