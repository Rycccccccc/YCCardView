//
//  YCCardCell.h
//  YCCardView_Example
//
//  Created by 任义春 on 2021/11/19.
//  Copyright © 2021 renyichun. All rights reserved.
// 卡片Cell

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCCardCell : UIView

// 当前cell索引
@property (assign, nonatomic,readonly) NSInteger indexRow;


#pragma mark - 外界控制方法

/**
 设置卡片的索引
 */
- (void)yc_setCardIndexRow:(NSInteger )indexRow;


#pragma mark - 基类方法 - 子类可重写

/**
 cell 赋值
 */
- (void)yc_setObject:(id)aObject;

/**
 添加子视图
 */
- (void)yc_addSubViews;

/**
 添加约束
 */
- (void)yc_addViewConstraints;

/**
 清除数据
 */
- (void)yc_clearData;

/**
 卡片拖拽中
 * @param centerDistance 当前x距离中心的偏移量， 值越大，距离视图中心越远
 * @param isRightDirection 移动的方向，是否为右侧
 */
- (void)yc_cardDragingDistance:(CGFloat )centerDistance dragingDirection:(BOOL )isRightDirection;

/**
 卡片移动后还原
 */
- (void)yc_cardDragEndRestore;

@end

NS_ASSUME_NONNULL_END
