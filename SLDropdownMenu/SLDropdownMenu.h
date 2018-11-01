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

//弹出框显示模式
typedef NS_ENUM(NSInteger, SLPopoverViewModel) {
    SLPopoverViewModelDefault = 0,  //默认显示方式（无气泡）
    SLPopoverViewModelBubble        //气泡模式（等腰三角形指示）
};

typedef NS_ENUM(NSInteger, SLBubblePosition) {
    SLBubblePositionLeft,   //气泡靠左显示
    SLBubblePositionMiddle, //气泡居中显示
    SLBubblePositionRight   //气泡靠右显示
};

@class SLDropdownMenu, SLSearchBar;

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
 模糊背景视图颜色透明度，默认黑色，透明度为0.f
 */
@property (nonatomic, assign) CGFloat dimmingViewColorAlpha;

/**
 弹出框宽度，默认为menu本身宽度，如果大于屏幕宽度，则按屏幕宽度布局。
 */
@property (nonatomic, assign) CGFloat popoverViewWidth;

/**
 弹出框背景颜色，默认[UIColor clearColor]
 */
@property (nonatomic, strong) UIColor *popoverViewBackgroundColor;

/**
 弹出框边框线宽度，默认为0.f
 */
@property (nonatomic, assign) CGFloat popoverViewBorderWidth;

/**
 弹出框边框线颜色，默认[UIColor clearColor]
 */
@property (nonatomic, strong) UIColor *popoverViewBorderColor;

/**
 弹出框显示模式，默认为SLPopoverViewModelDefault
 */
@property (nonatomic, assign) SLPopoverViewModel popoverModel;

/**
 气泡（三角形）高度，默认10.f
 */
@property (nonatomic, assign) CGFloat bubbleHeiht;

/**
 气泡绘制线条颜色，默认为弹出框边框线颜色
 */
@property (nonatomic, strong) UIColor *bubbleStrokeColor;

/**
 气泡填充颜色，默认[UIColor clearColor]
 */
@property (nonatomic, strong) UIColor *bubbleFillColor;

/**
 气泡显示位置，默认靠右：SLBubblePositionRight
 */
@property (nonatomic, assign) SLBubblePosition bubblePosition;

/**
 下拉列表内边距，默认UIEdgeInsetsZero。
 */
@property (nonatomic, assign) UIEdgeInsets tableViewEdgeInsets;
@property (nonatomic, strong) UIColor *tableViewBackgroundColor;
@property (nonatomic, strong) UIColor *tableViewSeparatorColor;
@property (nonatomic, assign) BOOL showSeparatorLine;

/**
 显示搜索框，默认NO（不显示）
 */
@property (nonatomic, assign) BOOL showSearchBar;
@property (nonatomic, strong) SLSearchBar *searchBar;

@property (nonatomic, weak) id<SLDropdownMenuDelegate> delegate;

/**
 已选中行。
 */
@property (nonatomic, assign, readonly) NSInteger selectedRow;

/**
 设置选择行
 
 @param row 选择的行，若大于或等于dataSource的count，则无效。
 */
- (void)setSelectRow:(NSInteger)row;

@end

