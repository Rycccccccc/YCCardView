//
//  YCCardCell.m
//  YCCardView_Example
//
//  Created by 任义春 on 2021/11/19.
//  Copyright © 2021 renyichun. All rights reserved.
//

#import "YCCardCell.h"

@interface YCCardCell()

// 记录索引
@property (assign, nonatomic) NSInteger recordIndexRow;
// 标题
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation YCCardCell

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initConfig];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initConfig];
        [self setupUI];
    }
    return self;
}

- (void)initConfig {
    [self p_setShadowRadius];
}

- (void)setupUI {
    [self yc_addSubViews];
    [self yc_addViewConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0, self.bounds.size.height - 40, self.bounds.size.width, 40);
}

#pragma mark - 点击事件

#pragma mark - 代理方法


#pragma mark - 对外方法

#pragma mark - 外界控制方法

- (NSInteger)indexRow {
    return self.recordIndexRow;
}

/**
 设置卡片的索引
 */
- (void)yc_setCardIndexRow:(NSInteger )indexRow {
    self.recordIndexRow = indexRow;
}


#pragma mark - 私有方法

// 设置圆角阴影
- (void)p_setShadowRadius {
    self.layer.cornerRadius      = 8;
    self.layer.shadowRadius      = 3;
    self.layer.shadowOpacity     = 0.2;
    self.layer.shadowOffset      = CGSizeMake(1, 1);
    self.layer.shadowPath        = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.masksToBounds = YES;
}

#pragma mark - set/get

// 标题
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor orangeColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark - 基类方法

#pragma mark - 基类方法 - 子类可重写

/**
 cell 赋值
 */
- (void)yc_setObject:(id)aObject {
    NSString *titleStr = (NSString *) aObject;
    self.titleLabel.text = titleStr;
}

/**
 添加子视图
 */
- (void)yc_addSubViews {
    [self addSubview:self.titleLabel];
}

/**
 添加约束
 */
- (void)yc_addViewConstraints {
    
}

/**
 清除数据
 */
- (void)yc_clearData {
    self.titleLabel.text = @"";
}

/**
 卡片拖拽中
 * @param centerDistance 当前x距离中心的偏移量， 值越大，距离视图中心越远
 * @param isRightDirection 移动的方向，是否为右侧
 */
- (void)yc_cardDragingDistance:(CGFloat )centerDistance dragingDirection:(BOOL )isRightDirection {
    
}

/**
 卡片移动后还原
 */
- (void)yc_cardDragEndRestore {
    
}

@end
