//
//  ButtonShell.h
//  demo
//
//  Created by VINSON on 2019/11/19.
//  Copyright © 2019 Macrovideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 This class of time-critical products requires further adjustment.
 Multi-control selection tool.
 */
@interface ButtonSelectShell : NSObject
@property (nonatomic,assign) BOOL exclusive; // Whether the selection between controls is mutually exclusive, that is, whether it is a single selection.
@property (nonatomic,copy,nullable) void (^onClicked)(NSString *name, BOOL selected); // Control click callback, this callback is not well designed and needs to be adjusted.

/**
 Add non-selectable buttons
 */
-(BOOL)addButton:(UIButton*)button name:(NSString*)name;

/**
 Add selectable keys.
 */
-(BOOL)addSelectableButton:(UIButton*)button name:(NSString*)name;

/**
 delete button
 */
-(void)remove:(NSString*)name;
-(void)removeAll;

/**
 Check/uncheck a key.
 */
-(void)selected:(BOOL)selected name:(NSString*)name;
-(void)selected:(BOOL)selected name:(NSString*)name update:(BOOL)update __attribute__((deprecated)); // update is because there was a problem with the UIButton+state extension before, which caused the layout of all UIButtons to have question.

/**
 Enable button.
 */
-(void)enabled:(BOOL)enabled name:(NSString*)name;
-(void)enabled:(BOOL)enabled names:(NSArray*)names;

/**
 Hide keys.
 */
-(void)hidden:(BOOL)hidden name:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
