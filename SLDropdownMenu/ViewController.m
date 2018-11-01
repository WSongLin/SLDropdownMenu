//
//  ViewController.m
//  SLDropdownMenu
//
//  Created by sl on 2018/10/22.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import "ViewController.h"
#import "SLDropdownMenu.h"

@interface ViewController ()<SLDropdownMenuDelegate>

@property (nonatomic, strong) SLDropdownMenu *dropdownMenu;
@property (nonatomic, weak) SLDropdownMenu *networkDropdownMenu;
@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, strong) NSArray *networkInfos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self settingNavigationBar];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 100.f, 150.f, 25.f)];
    label.text = @"学习网站选择：";
    [self.view addSubview:label];
    
    [self.networkDropdownMenu setFrame:CGRectMake(CGRectGetMaxX(label.bounds), 90.f, 200.f, 40.f)];
}

#pragma mark - SLDropdownMenuDelegate
- (void)dropdownMenu:(SLDropdownMenu *)menu didSelectedRow:(NSInteger)row {
    if (self.dropdownMenu == menu) {
        NSLog(@"row = %ld, title = %@", (long)row, self.datas[row]);
    } else if (self.networkDropdownMenu == menu) {
        NSLog(@"row = %ld, title = %@", (long)row, self.networkInfos[row]);
    }
}

#pragma mark - Event response
- (void)navigationLeftItemTapped:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)navigationRightItemTapped:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


#pragma mark - Private method
- (void)settingNavigationBar {
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:99.f / 255.f green:184.f / 255 blue:255.f / 255 alpha:1.f];
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                                 target:self
                                                                                 action:@selector(navigationLeftItemTapped:)
                                    ];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                  target:self
                                                                                  action:@selector(navigationRightItemTapped:)
                                     ];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    [self.dropdownMenu setFrame:self.navigationController.navigationBar.frame];
    self.navigationItem.titleView = self.dropdownMenu;
    
    self.dropdownMenu.dataSource = self.datas;
//    self.dropdownMenu.backgroundColor = [UIColor redColor];
}

#pragma mark - Getter
- (SLDropdownMenu *)dropdownMenu {
    if (!_dropdownMenu) {
        _dropdownMenu = [[SLDropdownMenu alloc] init];
        _dropdownMenu.accessoryImage = [UIImage imageNamed:@"down_arrow_fill_white"];
        _dropdownMenu.delegate = self;
        _dropdownMenu.dimmingViewColorAlpha = 0.6f;
        _dropdownMenu.popoverModel = SLPopoverViewModelBubble;
//        _dropdownMenu.popoverViewBackgroundColor = [UIColor redColor];
        _dropdownMenu.bubbleStrokeColor = [UIColor yellowColor];
        _dropdownMenu.bubbleFillColor = [UIColor blackColor];
        _dropdownMenu.popoverViewWidth = 350.f;
        _dropdownMenu.bubblePosition = SLBubblePositionLeft;
        _dropdownMenu.showSearchBar = YES;
    }
    
    return _dropdownMenu;
}

- (SLDropdownMenu *)networkDropdownMenu {
    if (!_networkDropdownMenu) {
        SLDropdownMenu *menu = [[SLDropdownMenu alloc] init];
        menu.delegate = self;
        menu.imageAlignment = SLImageAlignmentRight;
        menu.backgroundColor = [UIColor colorWithRed:99.f / 255.f green:184.f / 255 blue:255.f / 255 alpha:1.f];
        menu.accessoryImage = [UIImage imageNamed:@"down_arrow_fill_white"];
        menu.dataSource = self.networkInfos;
        menu.popoverModel = SLPopoverViewModelBubble;
//        menu.popoverViewBackgroundColor = [UIColor redColor];
//        menu.bubbleStrokeColor = [UIColor redColor];
        menu.bubbleFillColor = [UIColor blackColor];
        menu.bubblePosition = SLBubblePositionMiddle;

        [self.view addSubview:menu];
        
        _networkDropdownMenu = menu;
    }
    
    return _networkDropdownMenu;
}

- (NSArray *)datas {
    return @[@"iOS与OS X多线程和内存管理",
             @"OS X与iOS内核编程",
             @"iOS网络高级编程",
             @"iOS Core Animation",
             @"编写高质量iOS与OS X代码",
             @"HTTP权威指南",
             @"Cocoa设计模式",
             @"官方文档"
             ];
}

- (NSArray *)networkInfos {
    return @[@"Apple Developer",
             @"GitHub",
             @"Stack Overflow",
             @"Google",
             @"CocoaChina",
             @"知乎",
             @"CSDN",
             @"简书",
             @"博客园"
             ];
}

@end
