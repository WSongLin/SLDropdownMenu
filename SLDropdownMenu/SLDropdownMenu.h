//
//  SLDropdownMenu.h
//  SLDropdownMenu
//
//  Created by sl on 2018/10/22.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SLImageAlignment) {
    SLImageAlignmentDefault = 0,    //居文字右侧，跟随文字变动
    SLImageAlignmentLeft,           //紧挨视图最左侧显示
    SLImageAlignmentRight           //紧挨视图最右侧显示
};

@class SLDropdownMenu;

@protocol SLDropdownMenuDelegate <NSObject>

@optional
- (void)dropdownMenu:(SLDropdownMenu *)menu didSelectedRow:(NSInteger)row;

@end

@interface SLDropdownMenu : UIView

/**
 标题，若有dataSource，则默认为下拉列表数据第一个值。
 */
@property (nonatomic, copy) NSString *title;
@property (nonatomic) UIFont *titleFont;
@property (nonatomic) UIColor *titleColor;

/**
 附加图片，默认为nil。
 */
@property (nonatomic, strong) UIImage *accessoryImage;

/**
 附加图片排列方式，默认SLImageAlignmentDefault
 */
@property (nonatomic, assign) SLImageAlignment imageAlignment;

/**
 图片大小，默认CGSizeMake(22.f, 18.f)。
 */
@property (nonatomic, assign) CGSize imageSize;

/**
 下拉列表数据源。
 */
@property (nonatomic, strong) NSArray<NSString *> *dataSource;

/**
 已选中行。
 */
@property (nonatomic, assign, readonly) NSInteger selectedRow;

/**
 下拉列表宽度，默认为menu本身宽度。
 */
@property (nonatomic, assign) CGFloat tableViewWidth;
@property (nonatomic, strong) UIColor *tableViewBackgroundColor;
@property (nonatomic, strong) UIColor *tableViewSeparatorColor;
@property (nonatomic, assign) BOOL showSeparatorLine;

@property (nonatomic, weak) id<SLDropdownMenuDelegate> delegate;

/**
 设置选择行
 
 @param row 选择的行，若大于或等于dataSource的count，则无效。
 */
- (void)setSelectRow:(NSInteger)row;

@end

