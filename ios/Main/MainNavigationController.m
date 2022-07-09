//
//  MainNavigationController.m
//  demo
//
//  Created by MacroVideo on 2018/1/13.
//  Copyright © 2018年 Macrovideo. All rights reserved.
//

#import "MainNavigationController.h"
@interface MainNavigationController ()

@end

@implementation MainNavigationController


- (void)viewDidLoad {
[super viewDidLoad];
   //Take out the picture affected by tintColor in the tabBar, and use the picture to generate an unaffected picture
    UIImage *selectImage=[self.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAutomatic];
    //Set the unaffected picture as the selected picture
    self.tabBarItem.selectedImage=selectImage;

    [UITabBar appearance].translucent = NO;
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundImage = [UIImage new];
        appearance.shadowColor = [UIColor clearColor] ;
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    }
}
-(BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}

@end
