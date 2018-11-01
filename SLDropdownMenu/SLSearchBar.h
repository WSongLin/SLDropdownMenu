//
//  SLSearchBar.h
//  SLSearchBar
//
//  Created by sl on 2018/10/29.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLSearchBar;

@protocol SLSearchBarDelegate <NSObject>

@optional
- (void)searchBar:(SLSearchBar *)searchBar textDidChange:(nonnull NSString *)searchText;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SLSearchBar : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<SLSearchBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
