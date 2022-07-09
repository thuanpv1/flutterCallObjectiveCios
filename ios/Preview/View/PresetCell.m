//
//  PresetCell.m
//  iCamSee
//
//  Created by VINSON on 2019/12/6.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import "PresetCell.h"

@interface PresetCell()
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@end

@implementation PresetCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _selectedImage.userInteractionEnabled = YES;
}
- (void)setEdit:(BOOL)edit{
    _selectedImage.hidden = !edit;
}
@end
