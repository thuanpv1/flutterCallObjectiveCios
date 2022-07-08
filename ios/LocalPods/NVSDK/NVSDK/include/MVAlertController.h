//
//  MVAlertController.h
//  iCamSee
//
//  Created by Macro-Video on 2019/2/16.
//  Copyright © 2019年 Macrovideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MVAlertDelegate <NSObject>
@optional
- (void)alertAttributeStringDidTap:(NSString *_Nullable)string range:(NSRange)range;
@end


NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,MVAlertControllerType){
    MVAlertControllerTypeOneAction, //只有确定按钮
    MVAlertControllerTypeOKAndCancel //有确定和取消
};

typedef NS_ENUM(NSUInteger, AlertPositionType) {
    AlertPositionTypeCenter, //弹框显示在中央
    AlertPositionTypeBottom, //弹框显示在底部
    AlertPositionTypeTop,    //弹框显示在顶部
};

@interface MVAlertController : UIView
@property (nonatomic, copy) NSString *cancelActionTitle;  //取消按钮标题,如果为空则显示默认标题“取消”
@property (nonatomic, copy) NSString *confirmActionTitle; //确定按钮标题,如果为空则显示默认标题“确定”
@property (nonatomic, strong) UIColor *cancelActionTitleColor; //取消按钮标题的颜色
@property (nonatomic, strong) UIColor *confirmActionTitleColor;//确定按钮标题的颜色
@property (nonatomic, strong) NSMutableArray *textFields;       //所有的输入框都在这个数组里面
@property (nonatomic, weak) id <MVAlertDelegate> delegate;
@property (nonatomic, assign) AlertPositionType positionType;   //弹框位置(默认在中央)


-(instancetype)initWithWidth:(CGFloat)width;
-(void)showAlertWithType:(MVAlertControllerType)type title:(NSString * _Nullable)title message:(NSString * _Nullable )message handel:(void(^ _Nullable)(void) )handel;

//设置弹框的背景颜色
-(void)setAlertBackgroundColor:(UIColor *)color;

//设置按钮的边框颜色
-(void)settingButtonBoderColor:(UIColor *)color;

//设置按钮标题和颜色
-(void)setCancelTitle:(NSString *)cancelActionTitle;
-(void)setConfirmTitle:(NSString *)confirmActionTitle;
-(void)setCancelTitleColor:(UIColor *)cancelActionTitleColor;
-(void)setConfirmTitleColor:(UIColor *)confirmActionTitleColor;

//设置图片 可选择设置在标题上方还是标题下方
-(void)setImage:(UIImage *)image size:(CGSize)ImageSize underTitle:(BOOL)isUnderTitle;

//设置取消时的回调
-(void)setCancelHandell:(void(^)(void))cancelHandle;

//设置对齐方式
-(void)setMessageTextAlignment:(NSTextAlignment)textAlignment;

//设置标题颜色
-(void)setTitleColor:(UIColor *)color;
//设置标题字体
-(void)setTitleFont:(UIFont *)font;
//设置详情颜色
-(void)setMessageColor:(UIColor *)color;
//设置详情字体
-(void)setMessageFont:(UIFont *)font;

//设置弹框的圆角度
-(void)setCornerRadius:(CGFloat)cornerRadius;

//设置按钮是否可点击
-(void)setConfirmBtnEnable:(BOOL)enable;
-(void)setCancelBtnEnable:(BOOL)enable;

//添加输入框(可以添加多个)
-(void)addTextField:(void(^)(UITextField *textField))block;

//设置attributeString
-(void)setAttributedTitle:(NSMutableAttributedString *)attributedAlertTitle;
-(void)setAttributedMessage:(NSMutableAttributedString *)attributedAlertMessage;
-(void)setAttributedConfirm:(NSMutableAttributedString *)attributed;

//设置需要响应点击事件的子字符串（如果设置了，需要遵守代理协议）可以设置多个
-(void)setTitleAttributeTapActionString:(NSString *)string dismissWhenTap:(BOOL)dismissWhenTap;
-(void)setMessageAttributeTapActionStirng:(NSString *)string dismissWhenTap:(BOOL)dismissWhenTap;
@end

NS_ASSUME_NONNULL_END
