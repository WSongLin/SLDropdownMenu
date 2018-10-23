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

@class SLDropdownMenuTableView;

static NSString * const kReuseIdentifier = @"Cell";

@protocol SLDropdownMenuTableViewDelegate <NSObject>

@optional

/**
 发生在tableView区域以外的事件。
 
 @param tableView   tableView本身
 @param point       点击在tableView区域以外的坐标点
 */
- (void)tableView:(SLDropdownMenuTableView *)tableView hitTestOutsideAtPoint:(CGPoint)point;

@end

@interface SLDropdownMenuTableView : UITableView

@property (nonatomic, weak) id<SLDropdownMenuTableViewDelegate> DMDelegate;

@end

@implementation SLDropdownMenuTableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (![hitView isDescendantOfView:self]) {
        if ([self.DMDelegate respondsToSelector:@selector(tableView:hitTestOutsideAtPoint:)]) {
            [self.DMDelegate tableView:self hitTestOutsideAtPoint:point];
        }
    }
    
    return hitView;
}

@end

@interface SLDropdownMenu ()<UITableViewDelegate, UITableViewDataSource, SLDropdownMenuTableViewDelegate>

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) SLDropdownMenuTableView *tableView;

@property (nonatomic, assign) NSInteger cellSelectedIndex;
@property (nonatomic, assign) BOOL isShow;

/**
 用来判断行为是否来自tableView而不是来自本身内部。
 */
@property (nonatomic, assign) BOOL isFromTableViewAction;

@end

@implementation SLDropdownMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _cellSelectedIndex = 0;
        _isShow = NO;
        _isFromTableViewAction = NO;
        _imageAlignment = SLImageAlignmentDefault;
        
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
            make.size.mas_equalTo(CGSizeMake(22.f, 18.f));
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

#pragma mark - SLDropdownMenuTableViewDelegate
- (void)tableView:(SLDropdownMenuTableView *)tableView hitTestOutsideAtPoint:(CGPoint)point {
    CGPoint convertPoint = [tableView convertPoint:point toView:self];
    if (CGRectContainsPoint(self.bounds, convertPoint)) {
        self.isFromTableViewAction = YES;
    }
    
    [self hiddenTableView];
}

#pragma mark - UIGestureRecognizer
- (void)tapGestureAction:(UIGestureRecognizer *)recognizer {
    if (self.isFromTableViewAction) {
        //如果事件行为来自tableView，则不需要做任何处理。
        self.isFromTableViewAction = NO;
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
    }
}

#pragma mark - Private method
- (void)showTableView {
    self.isShow = YES;
    
    CGFloat height = self.dataSource.count * self.tableView.rowHeight;
    if (height > SCREEN_SIZE.height * 4 / 5) {
        height = SCREEN_SIZE.height * 4 / 5;
    }
    
    [self layoutTableViewWithHeight:height];
}

- (void)hiddenTableView {
    self.isShow = NO;
    
    [self layoutTableViewWithHeight:0.f];
    [self.tableView removeFromSuperview];
}

- (void)layoutTableViewWithHeight:(CGFloat)height {
    CGPoint point = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
    CGPoint convertPoint = [self convertPoint:point toView:self.window];
    
    CGRect rect = CGRectZero;
    rect.origin.x = convertPoint.x;
    rect.origin.y = convertPoint.y;
    rect.size.width = CGRectGetWidth(self.bounds);
    rect.size.height = height;
    
    [self.tableView setFrame:rect];
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title ? : @"";
    
    [self setNeedsLayout];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    
    if (titleFont) {
        self.titleLabel.font = titleFont;
        [self setNeedsLayout];
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

- (void)setDataSource:(NSArray<NSString *> *)dataSource {
    _dataSource = dataSource;
    
    if (dataSource && dataSource.count > 0) {
        if (!self.title || 0 == self.title.length) {
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

- (SLDropdownMenuTableView *)tableView {
    if (!_tableView) {
        SLDropdownMenuTableView *tableView = [[SLDropdownMenuTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.DMDelegate = self;
        tableView.rowHeight = 44.f;
        tableView.backgroundColor = RGBA_COLOR(31.f, 37.f, 61.f, 0.85f);
        tableView.tableFooterView = [UIView new];
        tableView.separatorInset = UIEdgeInsetsZero;
        tableView.separatorColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kReuseIdentifier];
        [self.window addSubview:tableView];
        
        _tableView = tableView;
    }
    
    return _tableView;
}

- (NSInteger)selectedRow {
    return self.cellSelectedIndex;
}

@end
