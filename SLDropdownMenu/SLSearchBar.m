//
//  SLSearchBar.m
//  SLSearchBar
//
//  Created by sl on 2018/10/29.
//  Copyright © 2018年 WSonglin. All rights reserved.
//

#import "SLSearchBar.h"
#import "Masonry.h"

@interface SLSearchBar ()<UITextFieldDelegate>

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation SLSearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChangeNotification:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil
         ];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self.mas_left).offset(10.f);
        make.right.equalTo(self.imageView.mas_left).offset(10.f);
    }];
    
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right).offset(-20.f);
        make.size.mas_equalTo(CGSizeMake(20.f, 18.f));
    }];
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

#pragma mark - NSNotification
- (void)textDidChangeNotification:(NSNotification *)note {
    UITextField *textField = (UITextField *)note.object;
    
    if (![textField markedTextRange]) {
        if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
            [self.delegate searchBar:self textDidChange:textField.text];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Setter
- (void)setText:(NSString *)text {
    _text = text;
    
    self.textField.text = text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    
    self.textField.placeholder = placeholder;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    if (image) {
        self.imageView.image = image;
    }
}

#pragma mark - Getter
- (UITextField *)textField {
    if (!_textField) {
        UITextField *text = [[UITextField alloc] init];
        text.textAlignment = NSTextAlignmentCenter;
        text.textColor = [UIColor whiteColor];
        text.returnKeyType = UIReturnKeySearch;
        text.delegate = self;
        [self addSubview:text];
        
        _textField = text;
    }
    
    return _textField;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *view = [[UIImageView alloc] init];
//        view.image = [UIImage imageNamed:@"search"];
        [self addSubview:view];
        
        _imageView = view;
    }
    
    return _imageView;
}

@end
