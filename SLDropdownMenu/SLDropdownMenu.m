//
//  SLDropdownMenu.m
//  SLDropdownMenu
//
//  Created by sl on 2018/10/22.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import "SLDropdownMenu.h"
#import "Masonry.h"

#define RGBA_COLOR(r, g, b, a) [UIColor colorWithRed:r / 255.f\
                                               green:g / 255.f\
                                                blue:b / 255.f\
                                               alpha:a]

#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size

static NSString * const kReuseIdentifier = @"Cell";

@class SLDimmingView;

@protocol SLDimmingViewDelegate <NSObject>

@optional
/**
 发生在tableView区域以外的事件。
 
 @param dimmingView   SLDimmingView对象
 @param point         点击坐标点
 */
- (void)dimmingView:(SLDimmingView *)dimmingView hitTestAtPoint:(CGPoint)point;

@end

@interface SLDimmingView : UIView

@property (nonatomic, weak) id<SLDimmingViewDelegate> delegate;

@end

@implementation SLDimmingView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];

    //若点击本身（不包含子视图）或本身以外的区域，则让委托处理该事件。
    if (![hitView isDescendantOfView:self] || [hitView isEqual:self]) {
        if ([self.delegate respondsToSelector:@selector(dimmingView:hitTestAtPoint:)]) {
            [self.delegate dimmingView:self hitTestAtPoint:point];
        }
    }

    return hitView;
}

@end

@interface SLDropdownMenu ()<UITableViewDelegate, UITableViewDataSource, SLDimmingViewDelegate>

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) SLDimmingView *dimmingView;
@property (nonatomic, weak) UIView *popoverView;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign) NSInteger cellSelectedIndex;
@property (nonatomic, assign) BOOL isShow;

/**
 用来判断点击事件行为是否是来自外部。
 */
@property (nonatomic, assign) BOOL isActionFromOutside;

@end

@implementation SLDropdownMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _cellSelectedIndex = 0;
        _isShow = NO;
        _isActionFromOutside = NO;
        _imageAlignment = SLImageAlignmentDefault;
        _imageSize = CGSizeMake(22.f, 18.f);
        
        _dimmingViewColorAlpha = 0.f;
        
        _popoverViewBorderWidth = 0.f;
        _popoverViewBorderColor = [UIColor clearColor];
        _popoverModel = SLPopoverViewModelDefault;
        
        _bubbleHeiht = 10.f;
        _bubbleStrokeColor = [UIColor clearColor];
        _bubbleFillColor = [UIColor clearColor];
        _bubblePosition = SLBubblePositionRight;
        
        _tableViewEdgeInsets = UIEdgeInsetsZero;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [self.contentView addGestureRecognizer:recognizer];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (0 == CGRectGetWidth(self.bounds)
        || 0 == CGRectGetHeight(self.bounds)) {
        return;
    }
    
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self);
        // 因为navigation的titleView大小会跟随内容的实际大小改变，所以这里添加一个view来撑住它的大小。
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)));
    }];
    
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (SLImageAlignmentRight == self.imageAlignment
            || SLImageAlignmentLeft == self.imageAlignment) {
            make.edges.equalTo(self.containerView);
        } else {
            //内容撑大
            make.top.bottom.centerX.equalTo(self.containerView);
        }
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.width.lessThanOrEqualTo(@(CGRectGetWidth(self.bounds)- 20.f)).priorityHigh();
        
        if (self.accessoryImage) {
            if (SLImageAlignmentLeft == self.imageAlignment) {
                make.left.equalTo(self.imageView.mas_right).offset(5.f);
                make.right.lessThanOrEqualTo(self.contentView);
            } else {
                make.left.equalTo(self.contentView).offset(5.f);
                make.right.lessThanOrEqualTo(self.imageView.mas_left);
            }
        } else {
            make.right.lessThanOrEqualTo(self.contentView);
        }
    }];
    
    if (self.accessoryImage) {
        [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.size.mas_equalTo(self.imageSize);
            if (SLImageAlignmentLeft == self.imageAlignment) {
                make.left.equalTo(self.contentView.mas_left).offset(5.f);
            } else if (SLImageAlignmentRight == self.imageAlignment) {
                make.right.equalTo(self.contentView.mas_right).offset(-5.f);
            } else {
                make.right.lessThanOrEqualTo(self.contentView);
            }
        }];
    }
    
    [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = self.dataSource.count > indexPath.row ? self.dataSource[indexPath.row] : @"";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = self.titleFont ? : [UIFont systemFontOfSize:14.f];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hiddenTableView];
    
    self.titleLabel.text = self.dataSource.count > indexPath.row ? self.dataSource[indexPath.row] : @"";
    self.cellSelectedIndex = indexPath.row;
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:didSelectedRow:)]) {
        [self.delegate dropdownMenu:self didSelectedRow:indexPath.row];
    }
}

#pragma mark - SLDimmingViewDelegate
- (void)dimmingView:(SLDimmingView *)dimmingView hitTestAtPoint:(CGPoint)point {
    CGPoint convertPoint = [dimmingView convertPoint:point toView:self];
    if (CGRectContainsPoint(self.bounds, convertPoint) && self.isShow) {
        self.isActionFromOutside = YES;
    }
    
    if (self.isShow) {
        [self hiddenTableView];
    }
    
    [dimmingView removeFromSuperview];
}

#pragma mark - UIGestureRecognizer
- (void)tapGestureAction:(UIGestureRecognizer *)recognizer {
    if (self.isActionFromOutside) {
        //如果事件行为来自外部，则隐藏弹出框。
        if (self.isShow) {
            [self hiddenTableView];
        }

        self.isActionFromOutside = NO;
    } else {
        self.isShow = !self.isShow;
        
        if (self.isShow) {
            [self showTableView];
        } else {
            [self hiddenTableView];
        }
    }
}

#pragma mark - Interface method
- (void)setSelectRow:(NSInteger)row {
    if (self.dataSource && self.dataSource.count > row) {
        self.titleLabel.text = self.dataSource[row];
        self.cellSelectedIndex = row;
    }
}

#pragma mark - Private method
- (void)showTableView {
    self.isShow = YES;
    
    CGFloat height = self.dataSource.count * self.tableView.rowHeight + self.tableViewEdgeInsets.top + self.tableViewEdgeInsets.bottom + self.bubbleHeiht;
    if (height > SCREEN_SIZE.height * 4 / 5) {
        height = SCREEN_SIZE.height * 4 / 5;
    }
    
    [self layoutPopoverViewWithHeight:height];
}

- (void)hiddenTableView {
    self.isShow = NO;
    
    [self layoutPopoverViewWithHeight:0.f];
}

- (void)layoutPopoverViewWithHeight:(CGFloat)height {
    if (height > 0.f) {
        CGFloat x = CGRectGetMinX(self.bounds);
        CGFloat y = CGRectGetMaxY(self.bounds);
        CGFloat width = SCREEN_SIZE.width;
        
        if ((x + self.popoverViewWidth) > width) {
            x = width - self.popoverViewWidth;
        }
        
        if (self.popoverViewWidth >= width) {
            self.popoverViewWidth = width;
            x = 0.f;
        }
        
        CGPoint point = CGPointMake(x, y);
        CGPoint convertPoint = [self convertPoint:point toView:self.window];
        
        //布局模糊背景视图
        CGRect rect = CGRectZero;
        rect.origin.x = 0.f;
        rect.origin.y = convertPoint.y;
        rect.size.width = width;
        rect.size.height = SCREEN_SIZE.height - y;
        
        [self.dimmingView setFrame:rect];
        self.dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.dimmingViewColorAlpha];
        
        //布局弹出框视图
        rect.origin.x = convertPoint.x;
        rect.origin.y = 0.f;
        rect.size.width = self.popoverViewWidth > 0.f ? self.popoverViewWidth : CGRectGetWidth(self.bounds);
        rect.size.height = height;
        [self.popoverView setFrame:rect];
        [self.window bringSubviewToFront:self.popoverView];
        self.popoverView.backgroundColor = self.popoverViewBackgroundColor ? : [UIColor clearColor];
        
        //布局下拉列表
        y = CGRectGetMinY(self.popoverView.bounds) + self.tableViewEdgeInsets.top;
        if (SLPopoverViewModelBubble == self.popoverModel) {
            y += self.bubbleHeiht;
            
            [self drawBubbleLayer];
        }
        
        rect.origin.x = CGRectGetMinX(self.popoverView.bounds) + self.tableViewEdgeInsets.left;
        rect.origin.y = y;
        rect.size.width = CGRectGetWidth(self.popoverView.bounds) - self.tableViewEdgeInsets.left - self.tableViewEdgeInsets.right;
        rect.size.height = CGRectGetHeight(self.popoverView.bounds) - self.tableViewEdgeInsets.bottom - y;
        [self.tableView setFrame:rect];
        [self.popoverView bringSubviewToFront:self.tableView];
    } else {
        [self.tableView removeFromSuperview];
        [self.popoverView removeFromSuperview];
        [self.dimmingView removeFromSuperview];
    }
}

- (void)drawBubbleLayer {
    //等腰三角形顶点
    CGPoint triangleTopPoint = CGPointMake(CGRectGetMaxX(self.popoverView.bounds) - 20.f, 0.f);
    if (SLBubblePositionLeft == self.bubblePosition) {
        triangleTopPoint = CGPointMake(CGRectGetMinX(self.popoverView.bounds) + 20.f, 0.f);
    } else if (SLBubblePositionMiddle == self.bubblePosition) {
        triangleTopPoint = CGPointMake(CGRectGetMidX(self.popoverView.bounds), 0.f);
    }
    
    //等腰三角形左边点
    CGPoint triangleLeftPoint = CGPointMake(triangleTopPoint.x - 10.f, triangleTopPoint.y + self.bubbleHeiht);
    //边框线上左点
    CGPoint borderLineLeftTopPoint = CGPointMake(0.f, triangleLeftPoint.y);
    //边框线下左点
    CGPoint borderLineLeftBottomPoint = CGPointMake(0.f, CGRectGetMaxY(self.popoverView.bounds));
    //边框线下右点
    CGPoint borderLineRightBottomPoint = CGPointMake(CGRectGetMaxX(self.popoverView.bounds), borderLineLeftBottomPoint.y);
    //边框线上右点
    CGPoint borderLineRightTopPoint = CGPointMake(borderLineRightBottomPoint.x, triangleLeftPoint.y);
    //等腰三角形右边点
    CGPoint triangleRightPoint = CGPointMake(triangleTopPoint.x + 10.f, triangleLeftPoint.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:triangleTopPoint];
    [path addLineToPoint:triangleLeftPoint];
    [path addLineToPoint:borderLineLeftTopPoint];
    [path addLineToPoint:borderLineLeftBottomPoint];
    [path addLineToPoint:borderLineRightBottomPoint];
    [path addLineToPoint:borderLineRightTopPoint];
    [path addLineToPoint:triangleRightPoint];
    [path closePath];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.strokeColor = self.bubbleStrokeColor.CGColor;
    layer.fillColor = self.bubbleFillColor.CGColor;
    layer.path = path.CGPath;
    [self.popoverView.layer addSublayer:layer];
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title ? : @"";
    
    if (self.dataSource && self.dataSource.count > 0) {
        if ([self.dataSource containsObject:title]) {
            self.cellSelectedIndex = [self.dataSource indexOfObject:title];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    
    if (titleFont) {
        self.titleLabel.font = titleFont;
        
        [self setNeedsLayout];
        [self.tableView reloadData];
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    
    if (titleColor) {
        self.titleLabel.textColor = titleColor;
    }
}

- (void)setAccessoryImage:(UIImage *)accessoryImage {
    _accessoryImage = accessoryImage;
    
    if (accessoryImage) {
        self.imageView.image = accessoryImage;
    }
    
    [self setNeedsLayout];
}

- (void)setImageAlignment:(SLImageAlignment)imageAlignment {
    _imageAlignment = imageAlignment;
    
    [self setNeedsLayout];
}

- (void)setImageSize:(CGSize)imageSize {
    _imageSize = imageSize;
    
    [self setNeedsLayout];
}

- (void)setDataSource:(NSArray<NSString *> *)dataSource {
    _dataSource = dataSource;
    
    if (dataSource && dataSource.count > 0) {
        if (self.title && self.title.length > 0) {
            if ([dataSource containsObject:self.title]) {
                self.cellSelectedIndex = [dataSource indexOfObject:self.title];
                self.titleLabel.text = self.title;
            }
        } else {
            self.cellSelectedIndex = 0;
            self.titleLabel.text = dataSource[0];
        }
    }
    
    [self setNeedsLayout];
    [self.tableView reloadData];
}

- (void)setTableViewBackgroundColor:(UIColor *)tableViewBackgroundColor {
    _tableViewBackgroundColor = tableViewBackgroundColor;
    
    if (tableViewBackgroundColor) {
        self.tableView.backgroundColor = tableViewBackgroundColor;
    }
}

- (void)setTableViewSeparatorColor:(UIColor *)tableViewSeparatorColor {
    _tableViewSeparatorColor = tableViewSeparatorColor;
    
    if (tableViewSeparatorColor) {
        self.tableView.separatorColor = tableViewSeparatorColor;
    }
}

- (void)setShowSeparatorLine:(BOOL)showSeparatorLine {
    _showSeparatorLine = showSeparatorLine;
    
    if (!showSeparatorLine) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

#pragma mark - Getter
- (UIView *)containerView {
    if (!_containerView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        
        _containerView = view;
    }
    
    return _containerView;
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        [self.containerView addSubview:view];
        
        _contentView = view;
    }
    
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];
        
        _titleLabel = label;
    }
    
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *view = [[UIImageView alloc] init];
        [self.contentView addSubview:view];
        
        _imageView = view;
    }
    
    return _imageView;
}

- (SLDimmingView *)dimmingView {
    if (!_dimmingView) {
        SLDimmingView *view = [[SLDimmingView alloc] init];
        view.delegate = self;
        [self.window addSubview:view];
        
        _dimmingView = view;
    }
    
    return _dimmingView;
}

- (UIView *)popoverView {
    if (!_popoverView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        [self.dimmingView addSubview:view];
        
        _popoverView = view;
    }
    
    return _popoverView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = 44.f;
        tableView.backgroundColor = [UIColor blackColor];
        tableView.tableFooterView = [UIView new];
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifier];
        [self.popoverView addSubview:tableView];
        
        _tableView = tableView;
    }
    
    return _tableView;
}

- (NSInteger)selectedRow {
    return self.cellSelectedIndex;
}

@end
