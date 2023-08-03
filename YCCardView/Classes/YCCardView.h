//
//  YCCardView.h
//  YCCardView_Example
//
//  Created by 任义春 on 2021/11/19.
//  Copyright © 2021 renyichun. All rights reserved.
//  卡片视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YCCardCell,YCCardView;

#pragma mark - 视图协议
@protocol YCCardViewDelegate <NSObject>

@optional
/**
 * 点击卡片cell事件
 * @param cardView 卡片拖拽视图
 * @param indexRow 卡片所对应的位置
 */
- (void)yc_cardView:(YCCardView *)cardView didSelectedIndex:(NSUInteger)indexRow;

/**
 卡片拖拽完成代理
 * @param cardView 卡片拖拽视图
 * @param cardIndex 卡片索引位置
 * @param isRight 是否向右侧滑动
 */
- (void)yc_cardDragViewFinish:(YCCardView *)cardView cardCellIndex:(NSInteger )cardIndex direction:(BOOL )isRight;

/**
 卡片是否可以移动，拖拽的时候，可以进行一些条件控制，比如喜欢次数用完了，需要用户充值vip等
 * @param cardView 卡片拖拽视图
 * @param isRightDirection 是否为右边
 */
- (BOOL)yc_cardDragView:(YCCardView *)cardView cheackCardHasCanDragWithDragingDirection:(BOOL )isRightDirection;

/**
 卡片移动中代理
 * @param cardView 卡片拖拽视图
 * @param centerDistance 距离中心的距离，越大距离中点越远
 * @param isRight 是否向右侧滑动
 */
- (void)yc_cardDragging:(YCCardView *)cardView cardCellDragDistance:(CGFloat)centerDistance direction:(BOOL)isRight;

/**
 卡片移动后还原方法代理
 * @param cardView 卡片容器视图
 */
- (void)yc_cardDragEndRestore:(YCCardView *)cardView;

/**
 没有更多数据的处理-显示空展位图等操作
 * @param cardView 卡片容器视图
 */
- (void)yc_noMoreDataIncardDragView:(YCCardView *)cardView;

/**
 * 更新显示的卡片cell
 * @param cardView 卡片容器视图
 * @param cardCell 卡片容器视图对应的每个Cell
 * @param indexRow 对应的每个Cell的索引
 */
- (void)yc_cardDragView:(YCCardView *)cardView updateDisplayCell:(YCCardCell *)cardCell cellForRowAtIndex:(NSInteger)indexRow;

@end

#pragma mark - 数据源协议
@protocol YCCardViewDataSource <NSObject>

/**
 *  一共有多少个cell
 */
- (NSInteger)yc_numberOfRowsInCardDragView:(YCCardView *)cardView;

/**
 * 创建对应的cell样式
 * @param cardView 卡片拖拽视图
 */
- (YCCardCell *)yc_creatCellForCardView:(YCCardView *)cardView;

/**
 * 设置卡片拖拽视图的内边距
 * @param cardView 卡片容器视图
 */
- (UIEdgeInsets )yc_edgeInsetsInCardDragView:(YCCardView *)cardView;

/**
 加载更多数据
 */
- (void)yc_loadDataMore;

@end


@interface YCCardView : UIView

/// 代理属性
@property (nonatomic, weak) id<YCCardViewDelegate> delegate;
/// 数据源代理
@property (nonatomic, weak) id<YCCardViewDataSource> dataSource;
/// 加载更多数据值：默认5，剩余5个卡片的时候，触发 yc_loadDataMore 方法
@property (nonatomic, assign) NSInteger loadMoreDataValue;
/// 是否可以交互的回调
@property (nonatomic, copy) void(^cardCanDragBlcok)(void);

/// 刷新数据
- (void)yc_reloadDataWithAnimation:(BOOL)animation;
// 移除所有动画
- (void)yc_removeAllAnimations;
/// 下一个卡片
- (void)yc_nextCardWithDirection:(BOOL )isRight;
/// 卡片视图回退
- (void)yc_cardViewRollbackCellPreHandle:(BOOL (^)(void)) preHandle
                             complete:(void (^)(YCCardCell *carlCell ,NSInteger cellIndex))complete;

@end

NS_ASSUME_NONNULL_END
