//
//  YCCardView.m
//  YCCardView_Example
//
//  Created by 任义春 on 2021/11/19.
//  Copyright © 2021 renyichun. All rights reserved.
//

#import "YCCardView.h"
#import "YCCardCell.h"

// 卡片旋转角度
#define kCardViewRotationAngle (M_PI/8)
// 卡片Item总个数
#define kCardItemTotalNumber (4)

#define kCardCellRotationAngle (M_PI/8)
#define kCardCellMaxVelocityValue 400
#define kCardCellRotationMaxValue 1
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

// 方位
typedef enum : NSUInteger {
    YCPositionDirectionType_default      = 1 << 0,
    YCPositionDirectionType_topLeft      = 1 << 1,
    YCPositionDirectionType_topRight     = 1 << 2,
    YCPositionDirectionType_bottomLeft   = 1 << 3,
    YCPositionDirectionType_bottomRight  = 1 << 4
} YCPositionDirectionType;


@interface YCCardView() {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}
// 存储卡片Cell
@property (nonatomic, strong) NSMutableArray *mArrayCardCell;
// 存储左侧拖拽index,用于回退
@property (nonatomic, strong) NSMutableArray *mArrayLeftDragIndex;
// 当前显示的索引位置
@property (nonatomic, assign) NSInteger currentIndex;
// 底部卡片的索引位置
@property (nonatomic, assign) NSInteger lastIndex;
// 记录cell 中心位置
@property (assign, nonatomic) CGPoint centerPoint;
// 记录cell的frame
@property (assign, nonatomic) CGRect cellFrame;

// 记录拖拽手势开始位置:左上、左下、右上、右下
@property (assign, assign) YCPositionDirectionType tapPositionDirection;
// 存储卡片回退index，方便回退以及更新使用
@property (nonatomic, strong) NSMutableArray *mArrayCardRollBackIndex;

@end

@implementation YCCardView

#pragma mark - 初始化 ================================================

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initConfig];
    }
    return self;
}

// 初始化
- (void)initConfig {
    self.currentIndex = 0;
}

// 设置UI
- (void)setupUI {
    // 布局卡片
    [self.mArrayCardCell removeAllObjects];
    for (NSInteger index = 0; index < kCardItemTotalNumber; index++) {
        YCCardCell *cardCell = [self p_getCardCellView];
        // 添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        // 添加拖拽手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDragged:)];
        [cardCell addGestureRecognizer:tap];
        [cardCell addGestureRecognizer:panGesture];
        [self addSubview:cardCell];
        [self.mArrayCardCell addObject:cardCell];
    }
}

#pragma mark - 点击事件 ================================================

#pragma mark - 手势相关
// 卡片点击手势
- (void)tapClick:(UIPanGestureRecognizer *)tapGesture {
    YCCardCell *cell = (YCCardCell *)tapGesture.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(yc_cardView:didSelectedIndex:)]) {
        [self.delegate yc_cardView:self didSelectedIndex:cell.indexRow];
    }
}

// 拖拽手势
- (void)panDragged:(UIPanGestureRecognizer *)panGesture {
    // 移动点
    CGPoint pointMove = [panGesture translationInView:self];
    xFromCenter = pointMove.x;
    yFromCenter = pointMove.y;
    CGPoint pointTap = [panGesture locationInView:self];
    // 是否向右侧
    BOOL isRight = (xFromCenter > 0);
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            [self panGestureMoveingWithPoint:pointTap panCell:panGesture.view];
            CGFloat centerDistance = fabs(xFromCenter);
            [self p_sendDelegateCardDraggingWithCenterDistance:centerDistance direction:isRight];
            
            
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.tapPositionDirection = YCPositionDirectionType_default;
            // 检测卡片是否可以拖拽
            BOOL isCanDrag = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(yc_cardDragView:cheackCardHasCanDragWithDragingDirection:)]) {
                isCanDrag = [self.delegate yc_cardDragView:self cheackCardHasCanDragWithDragingDirection:isRight];
            }
            if (isCanDrag == NO) { // // 不允许移动，则复位
                xFromCenter = 0.1;
            }
            [self panGestureStateEndWithWithDistance:xFromCenter
                                         andVelocity:[panGesture velocityInView:panGesture.view.superview]];
        }
            break;
        default:
            break;
    }
}

#pragma mark 手势移动中
// 拖拽手势移动中
- (void)panGestureMoveingWithPoint:(CGPoint )tapPoint panCell:(UIView *)cell {
    // 获取拖拽手势开始的点击位置
    NSInteger startTapPositionDirection = [self p_getPanGestureBeginPointWithPoint:tapPoint];
    CGFloat rotationStrength = 0;
    CGFloat rotationAngel = 0;
    switch (startTapPositionDirection) {
        case YCPositionDirectionType_topLeft:
        case YCPositionDirectionType_topRight:
        {
            rotationStrength = MIN(xFromCenter / kScreenWidth, kCardCellRotationMaxValue);
            rotationAngel = (CGFloat)(kCardCellRotationAngle * rotationStrength);
        }
            break;
        case YCPositionDirectionType_bottomLeft:
        case YCPositionDirectionType_bottomRight:
        {
            rotationStrength = MIN(xFromCenter / kScreenWidth, kCardCellRotationMaxValue);
            rotationAngel = -(CGFloat)(kCardCellRotationAngle * rotationStrength);
        }
            break;
        default:
            break;
    }
    // 设置卡片中心位置以及旋转角度
    cell.center = CGPointMake(self.centerPoint.x + xFromCenter, self.centerPoint.y + yFromCenter);
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
    cell.transform = transform;
}

#pragma mark - 拖动手势结束后处理
// 拖动手势结束后处理
-(void)panGestureStateEndWithWithDistance:(CGFloat)distance andVelocity:(CGPoint)velocity {
    // 判断最终是向哪边移动
    if (xFromCenter > 0 && (distance > self.cellFrame.size.width / 2 || velocity.x > kCardCellMaxVelocityValue )) {
        // 向右边移动
        [self p_rightAction:velocity];
    } else if(xFromCenter < 0 && (distance < - self.cellFrame.size.width / 2 || velocity.x < -kCardCellMaxVelocityValue)) {
        // 向左边移动
        [self p_leftAction:velocity];
    }else {
        YCCardCell *cell = [self p_getTopCardCellView];
        // 回到原点
        [UIView animateWithDuration:0.25
                         animations:^{
            cell.center = self.centerPoint;
            cell.transform = CGAffineTransformMakeRotation(0);
            [cell yc_cardDragEndRestore];
            [self p_sendDelegateCardDragEndRestore];
        }];
    }
}

// 拖拽手势结束事件处理
- (void)panGestureMoveEneActionHandleWithTargetDistanceX:(CGFloat )targetDistanceX velocity:(CGPoint )velocity isRightDirection:(BOOL )isRightDirection {
    //横向移动距离
    CGFloat distanceX = targetDistanceX;
    //纵向移动距离
    CGFloat distanceY = distanceX * yFromCenter / xFromCenter;
    //目标center点
    CGPoint finishPoint = CGPointMake(self.centerPoint.x + distanceX, self.centerPoint.y + distanceY);
    CGFloat angle = isRightDirection ? kCardCellRotationAngle : (-kCardCellRotationAngle);
    
    
    YCCardCell *cell = [self p_getTopCardCellView];
    [UIView animateWithDuration:0.5
                     animations:^{
        cell.center = finishPoint;
        cell.transform = CGAffineTransformMakeRotation(angle);
    } completion:^(BOOL finished) {
        cell.transform = CGAffineTransformIdentity;
        [self p_cardCellDragFinishHanle:cell dragingDirection:isRightDirection];
    }];
}

#pragma mark - 代理方法 ================================================

#pragma mark - 对外方法 ================================================

// 刷新数据
- (void)yc_reloadDataWithAnimation:(BOOL)animation {
    // 检测卡片视图
    [self p_cheackCardCellViews];
    // 重置数据
    [self p_resetData];
    // 刷新数据
    [self p_reloadCardCell];
    // 开始加载卡片动画
    if (animation) {
        [self p_showCardViewAnimation];
    }
}

/// 下一个卡片
- (void)yc_nextCardWithDirection:(BOOL )isRight {
    YCCardCell *topView = [self p_getTopCardCellView];
    if (topView.hidden) { return; }
    if (topView == nil) { return; }
    if (isRight) {
        [self p_cardRightMove];
    } else {
        [self p_cardLeftMove];
    }
}

// 移除所有动画
- (void)yc_removeAllAnimations {
    [self p_removeAllAnimations];
}

/// 卡片视图回退
- (void)yc_cardViewRollbackCellPreHandle:(BOOL (^)(void)) preHandle
                                complete:(void (^)(YCCardCell *carlCell ,NSInteger cellIndex))complete {
    
    // 前处理
    if (preHandle) {
        BOOL isRollback = preHandle();
        if (isRollback == NO) {
            NSLog(@"Ryc____ 不允许回退");
            return;
        }
    }
    
    if (self.mArrayLeftDragIndex.count <= 0) {
        return;
    }
    
    // 刷新顶视图的前一个视图数据
    YCCardCell *topCell = [self p_getTopCardCellView];
    YCCardCell *bottomCell = [self p_getBottomCardCellView];
    if (bottomCell == nil) { return; }
    NSNumber *indexNumber = [self.mArrayLeftDragIndex lastObject];
    NSInteger preIndex = indexNumber.integerValue;
    [self p_updateDisplayCardCell:bottomCell cellForIndexRow:preIndex];
    [self.mArrayLeftDragIndex removeObject:indexNumber];
    [self.mArrayCardRollBackIndex addObject:indexNumber];
    
    if (complete) {
        complete(bottomCell,bottomCell.indexRow);
    }
    // 设置视图层级
    [self insertSubview:bottomCell aboveSubview:topCell];
    // 开始入场动画
    [self p_entranceAnimationWithCardCellView:bottomCell duration:0.25 delay:0.06];
    // 设置顶视图可以拖拽，其它不允许拖拽
    [self p_setTopCanPan];
    
}

#pragma mark - 私有方法 ================================================


#pragma mark - 手势相关

/**
 卡片拖拽完成处理
 * @param cell 当前拖拽的cell
 * @param isRightDirection 移动的方向，是否为右侧
 */
- (void)p_cardCellDragFinishHanle:(YCCardCell *)cell dragingDirection:(BOOL )isRightDirection {
    
    // 交换卡片位置
    cell.center = self.centerPoint;
    [cell.layer removeAllAnimations];
    [self insertSubview:cell atIndex:0];
    
    NSInteger indexRow = cell.indexRow;
    // 如果是左滑结束，存储当前的视图索引，用于回退功能
    if (isRightDirection == NO) {
        [self.mArrayLeftDragIndex addObject:@(indexRow)];
    }
    
    // 发送代理
    [self p_sendDelegateCardDragEndWithCellIndex:indexRow direction:isRightDirection];
    
    // 如果没有数据了，就不再触发加载更多数据逻辑
    BOOL isNoData = [self p_cheackDataIsEmptyWithCardIndex:indexRow];
    if (isNoData) {
        // 没有更多数据的回调
        [self p_noDataHandleWithCardIndex:indexRow];
    } else {
        // 处理阀值
        [self p_loadMoreDataWithCardIndex:indexRow];
    }
    
    // 刷新最后一个视图的数据
    NSInteger bottomCellIndex = [self p_getBottomCellIndexWithTopIndex:indexRow];
    
    [self p_updateDisplayCardCell:cell cellForIndexRow:bottomCellIndex];
    
    // 设置顶部视图可以拖拽，其它不允许拖拽
    [self p_setTopCanPan];
}

// 根据顶部索引，获取底部cellIndex
- (NSInteger )p_getBottomCellIndexWithTopIndex:(NSInteger )topIndex {
    NSInteger bottomIndex = -1;
    // 16,15,14,13,12,10
    // 10
    /**
        假设：mArrayCardRollBackIndex 里面的元素 16,15,14,13,12,10， 当前top为10
     第一步执行，向左右滑动结束后，分情况处理
     1 如果mArrayCardRollBackIndex里面有值: 由于当前top显示的是10，所以更新底部卡片值，就是top指针向前移动4下取15
     - 1.1 如果可以找到了具体的值，直接返回底部卡片index
     - 1.2 如果找不到，从记录的最后值lastIndex, 然后减去减去数组个数减一
     - 1.3 将mArrayCardRollBackIndex 里面的最后一个元素，删除，
     2 如果mArrayCardRollBackIndex里面没有有值
     - 如果mArrayCardRollBackIndex里面没有值了，说明之前回退的都操作完了，这个时候，开始最初的逻辑
     */
    if (self.mArrayCardRollBackIndex.count > 0) { // 有回退的元素
        if (topIndex == self.currentIndex) {
            // 如果当前顶部和curIndex 一致
            bottomIndex = [self p_getLastReloadCellIndex];
        } else {
            // 目标值
            NSInteger target = -1;
            NSInteger end = self.mArrayCardRollBackIndex.count -1;
            // 目标值索引
            NSInteger tagretIndex = end - kCardItemTotalNumber;
            BOOL isFind = NO;
            if (tagretIndex >= 0) {
                // 遍历查找目标值
                for (NSInteger i = end; i >= 0; i--) {
                    if (tagretIndex == i) {
                        target = [self.mArrayCardRollBackIndex[i] integerValue];
                        isFind = YES;
                        break;
                    }
                }
            }
            if (isFind) { // 找到了，直接更新底部卡片信息
                bottomIndex = target;
            } else { // 没找到 取最后一个索引，减去数组个数减一
                bottomIndex = self.lastIndex - (self.mArrayCardRollBackIndex.count -1);
            }
        }
        [self.mArrayCardRollBackIndex removeLastObject];
    } else { // 没有回退的元素
        bottomIndex = [self p_getLastReloadCellIndex];
        self.lastIndex = bottomIndex;
        // 更新当前index
        [self p_updateCurrentIndex];
    }
    return bottomIndex;
}

// 获取拖拽手势开始的点击位置
- (NSInteger)p_getPanGestureBeginPointWithPoint:(CGPoint )pointTap {
    if (self.tapPositionDirection != YCPositionDirectionType_default) {
        return self.tapPositionDirection;
    }
    NSInteger locationIndex = YCPositionDirectionType_default;
    CGFloat halfWidth = self.cellFrame.size.width * 0.5;
    CGFloat halfHeight = self.cellFrame.size.height * 0.5;
    BOOL isLeftTop = CGRectContainsPoint(CGRectMake(0, 0, halfWidth, halfHeight), pointTap);
    BOOL isLeftBootom = CGRectContainsPoint(CGRectMake(0, halfHeight, halfWidth, halfHeight), pointTap);
    BOOL isRightTop = CGRectContainsPoint(CGRectMake(halfWidth, 0, halfWidth, halfHeight), pointTap);
    BOOL isRightBootom = CGRectContainsPoint(CGRectMake(halfWidth, halfHeight, halfWidth, halfHeight), pointTap);
    if (isLeftTop) {
        locationIndex = YCPositionDirectionType_topLeft;
    }
    if (isLeftBootom) {
        locationIndex = YCPositionDirectionType_bottomLeft;
    }
    if (isRightTop) {
        locationIndex = YCPositionDirectionType_topRight;
    }
    if (isRightBootom) {
        locationIndex = YCPositionDirectionType_bottomRight;
    }
    self.tapPositionDirection = locationIndex;
    return locationIndex;
}


#pragma mark - Cell index 有关

// 更新当前index
- (void)p_updateCurrentIndex {
    NSInteger cardTotalNumber = [self p_getCardCellTotalNumber];
    if (self.currentIndex < cardTotalNumber - 1) {
        self.currentIndex++;
    }
}

// 获取最后一个刷新CellIndex
- (NSInteger)p_getLastReloadCellIndex {
    return self.currentIndex + kCardItemTotalNumber;
}

#pragma mark - 没有数据相关处理
// 是否没有数据了
- (BOOL)p_cheackDataIsEmptyWithCardIndex:(NSInteger )cardIndex {
    if (cardIndex < 0) { return YES; }
    NSInteger cardTotalNumber = [self p_getCardCellTotalNumber];
    if (cardTotalNumber <= (cardIndex + 1)) {
        return YES;
    } else {
        return NO;
    }
}

// 没有更多数据的处理
- (void)p_noDataHandleWithCardIndex:(NSInteger )cardIndex {
    if (cardIndex < 0) { return; }
    NSInteger cardTotalNumber = [self p_getCardCellTotalNumber];
    if (cardTotalNumber <= (cardIndex + 1)) {
        NSLog(@"没有数据了");
        [self p_sendDelegateNoDataHandle];
    } else {

    }
}

// 处理加载更多数据逻辑
- (void)p_loadMoreDataWithCardIndex:(NSInteger )cardIndex {
    if (cardIndex < 0) { return; }
    NSInteger rollBackTotolCount = self.mArrayCardRollBackIndex.count;
    NSInteger cardTotalNumber = [self p_getCardCellTotalNumber];
    NSInteger thresholdValue  = [self p_getThresholdValue];
    if (cardTotalNumber - (cardIndex + 1) - rollBackTotolCount <= thresholdValue) {
        NSLog(@"到达阈值，应加载更多数据");
        [self p_sendDelegateLoadMoreDataHandle];
    }
}

#pragma mark - 向左向右移动
// 向左移动:
- (void)p_cardLeftMove {
    // 给个默认值
    xFromCenter = -(self.cellFrame.size.width * 0.5);
    yFromCenter = 40;
    // 给个模拟的数字 30
    YCCardCell *topCell = [self p_getTopCardCellView];
    [topCell yc_cardDragingDistance:30 dragingDirection:NO];
    [self p_leftAction:CGPointMake(-20, 0)];
}

// 向右移动
- (void)p_cardRightMove {
    // 给个默认值
    xFromCenter = (self.cellFrame.size.width * 0.5);
    yFromCenter = 40;
    YCCardCell *topCell = [self p_getTopCardCellView];
    [topCell yc_cardDragingDistance:30 dragingDirection:YES];
    [self p_rightAction:CGPointMake(0,20)];
}

// 往右滑动的事件
-(void)p_rightAction:(CGPoint)velocity {
    //横向移动距离
    CGFloat distanceX = self.cellFrame.size.width + self.centerPoint.x;
    [self panGestureMoveEneActionHandleWithTargetDistanceX:distanceX velocity:velocity isRightDirection:YES];
}

// 往左滑动的事件
-(void)p_leftAction:(CGPoint)velocity {
    //横向移动距离
    CGFloat distanceX = -(self.cellFrame.size.width + self.centerPoint.x);
    [self panGestureMoveEneActionHandleWithTargetDistanceX:distanceX velocity:velocity isRightDirection:NO];
}

#pragma mark - 发送代理相关方法
// 发送代理事件- 卡片拖拽中
- (void)p_sendDelegateCardDraggingWithCenterDistance:(CGFloat )centerDistance direction:(BOOL)isRightDirection {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yc_cardDragging:cardCellDragDistance:direction:)]) {
        [self.delegate yc_cardDragging:self cardCellDragDistance:centerDistance direction:isRightDirection];
    }
    
    YCCardCell *topCell = [self p_getTopCardCellView];
    [topCell yc_cardDragingDistance:centerDistance dragingDirection:isRightDirection];
}

// 发送代理事件= 卡片拖拽结束复位
- (void)p_sendDelegateCardDragEndRestore {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yc_cardDragEndRestore:)]) {
        [self.delegate yc_cardDragEndRestore:self];
    }
}

// 发送代理事件= 卡片拖拽结束
- (void)p_sendDelegateCardDragEndWithCellIndex:(NSInteger )index direction:(BOOL)isRightDirection {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yc_cardDragViewFinish:cardCellIndex:direction:)]) {
        [self.delegate yc_cardDragViewFinish:self cardCellIndex:index direction:isRightDirection];
    }
}

// 发送代理事件= 没有更多数据处理
- (void)p_sendDelegateNoDataHandle {
    if (self.delegate && [self.delegate respondsToSelector:@selector(yc_noMoreDataIncardDragView:)]) {
        [self.delegate yc_noMoreDataIncardDragView:self];
    }
}

// 发送代理事件= 加载更多数据处理
- (void)p_sendDelegateLoadMoreDataHandle {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(yc_loadDataMore)]) {
        [self.dataSource yc_loadDataMore];
    }
}

#pragma mark - 更新-刷新相关方法

// 刷新对应卡片位置
- (void)p_reloadCardCell {
    CGRect frame = self.cellFrame;
    NSArray *temArray = self.subviews;
    if (temArray.count <= 0) { return ; }
    // 从视频顶部向下遍历:重新刷新
    NSInteger topIndex = temArray.count - 1;
    NSInteger indexRow = self.currentIndex;
    for (NSInteger index = topIndex; index >= 0; index--) {
        YCCardCell *cardCell = temArray[index];
        cardCell.frame = frame;
        cardCell.center = self.centerPoint;
        [self p_updateDisplayCardCell:cardCell cellForIndexRow:indexRow];
        indexRow++;
    }
}

// 更新显示的卡片Item
- (void)p_updateDisplayCardCell:(YCCardCell *)cardCell
                cellForIndexRow:(NSInteger)index {
    [cardCell yc_setCardIndexRow:index];
    NSInteger cardTotalNumber = [self p_getCardCellTotalNumber];
    BOOL isBoundary = index >= cardTotalNumber;
    cardCell.hidden = isBoundary;
    if (isBoundary) { // 越界了直接返回
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(yc_cardDragView:updateDisplayCell:cellForRowAtIndex:)]) {
        [self.delegate yc_cardDragView:self updateDisplayCell:cardCell cellForRowAtIndex:index];
    }
}

#pragma mark - 动画相关

// 开始加载卡片动画
- (void)p_showCardViewAnimation {
    for (NSInteger index = 0; index < self.mArrayCardCell.count; index++) {
        YCCardCell *cardCell = self.mArrayCardCell[index];
        [self p_entranceAnimationWithCardCellView:cardCell duration:0.5 delay:0.06 * index];
    }
}

// 卡片入场动画
- (void)p_entranceAnimationWithCardCellView:(YCCardCell *)cardCell duration:(CGFloat )duration delay:(CGFloat )delay {
    CGRect frame = self.cellFrame;
    CGFloat width = CGRectGetWidth(frame);
    CGPoint startPoint = CGPointMake(-width, cardCell.bounds.size.height);
    CGPoint centerPoint = self.centerPoint;
    [cardCell.layer removeAllAnimations];
    cardCell.transform = CGAffineTransformMakeRotation(0);
    cardCell.frame = frame;
    cardCell.center = startPoint;
    [UIView animateKeyframesWithDuration:duration delay:delay options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        cardCell.center = centerPoint;
        cardCell.transform = CGAffineTransformMakeRotation(kCardViewRotationAngle);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            cardCell.transform = CGAffineTransformIdentity;
        }];
    }];
}

// 移除所有的动画
- (void)p_removeAllAnimations {
    for (YCCardCell *view in self.mArrayCardCell) {
        [view.layer removeAllAnimations];
    }
}

#pragma mark - 卡片相关数据

// 重置数据
- (void)p_resetData {
    self.currentIndex = 0;
    for (NSInteger index = 0; index < self.mArrayCardCell.count; index++) {
        YCCardCell *cardCell = self.mArrayCardCell[index];
        [cardCell yc_clearData];
    }
}

// 检测卡片视图
- (void)p_cheackCardCellViews {
    if (self.mArrayCardCell.count > 0) {
        return;
    }
    [self setupUI];
}

// 设置顶部视图可以拖拽，其它不允许拖拽
- (void)p_setTopCanPan {
    NSArray *temArray = self.subviews;
    if (temArray.count <= 0) { return; }
    for (YCCardCell *tmpView in temArray) {
        tmpView.userInteractionEnabled = NO;
    }
    YCCardCell *cardItemView = [temArray lastObject];
    cardItemView.userInteractionEnabled = YES;
    if (self.cardCanDragBlcok) {
        self.cardCanDragBlcok();
    }
}

// 获取触发加载更多数据的阀值：默认5
- (NSInteger)p_getThresholdValue {
    NSInteger value = 5;
    if (self.loadMoreDataValue > 0) {
        value = self.loadMoreDataValue;
    }
    return value;
}

// 获取视图顶部卡片
- (YCCardCell *)p_getTopCardCellView {
    NSArray *temArray = self.subviews;
    if (temArray.count <= 0) { return nil; }
    YCCardCell *cardCellView = [temArray lastObject];
    return cardCellView;
}

// 获取视图底部卡片
- (YCCardCell *)p_getBottomCardCellView {
    NSArray *temArray = self.subviews;
    if (temArray.count <= 0) { return nil; }
    YCCardCell *cardCellView = [temArray firstObject];
    return cardCellView;
}

// 获取卡片Cell 中心位置
- (CGPoint )p_getCardCellViewCenterPoint {
    CGRect frame = [self p_getCardCellViewFrame];
    CGFloat minX = CGRectGetMinX(frame);
    CGFloat minY = CGRectGetMinY(frame);
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    CGPoint centerPoint = CGPointMake(minX + width / 2, minY + height / 2);
    return centerPoint;
}

// 获取卡片视图frame
- (CGRect )p_getCardCellViewFrame {
    UIEdgeInsets inset = [self p_getCardEdgeInsets];
    CGFloat x = inset.left;
    CGFloat y = inset.top;
    CGFloat w = self.bounds.size.width - inset.left - inset.right;
    CGFloat h = self.bounds.size.height - inset.top - inset.bottom;
    return CGRectMake(x, y, w, h);
}

// 获取卡片内切
- (UIEdgeInsets )p_getCardEdgeInsets {
    UIEdgeInsets inset = UIEdgeInsetsMake(10, 10, 10, 10);
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(yc_edgeInsetsInCardDragView:)]) {
        inset = [self.dataSource yc_edgeInsetsInCardDragView:self];
    }
    return inset;
}

// 获取卡片总个数
- (NSInteger)p_getCardCellTotalNumber {
    NSInteger totalNumber = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(yc_numberOfRowsInCardDragView:)]) {
        totalNumber = [self.dataSource yc_numberOfRowsInCardDragView:self];
    }
    return totalNumber;
}

// 获取卡片Cell视图
- (YCCardCell * )p_getCardCellView {
    YCCardCell *cardCell = [[YCCardCell alloc] init];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(yc_creatCellForCardView:)]) {
        cardCell = [self.dataSource yc_creatCellForCardView:self];
    }
    return cardCell;
}

#pragma mark - set/get ================================================

- (NSMutableArray *)mArrayCardCell {
    if (!_mArrayCardCell) {
        _mArrayCardCell = [NSMutableArray array];
    }
    return _mArrayCardCell;
}

- (CGPoint)centerPoint {
    if (CGPointEqualToPoint(_centerPoint, CGPointZero) == NO) {
        return _centerPoint;
    }
    _centerPoint = [self p_getCardCellViewCenterPoint];
    return _centerPoint;
}

- (CGRect)cellFrame {
    if (CGRectEqualToRect(_cellFrame, CGRectZero) == NO) {
        return _cellFrame;
    }
    _cellFrame = [self p_getCardCellViewFrame];
    return _cellFrame;
}

// 存储左侧拖拽index,用于回退
- (NSMutableArray *)mArrayLeftDragIndex {
    if (!_mArrayLeftDragIndex) {
        _mArrayLeftDragIndex = [NSMutableArray array];
    }
    return _mArrayLeftDragIndex;
}

// 存储回退卡片index，方便卡片底部更新使用
- (NSMutableArray *)mArrayCardRollBackIndex {
    if (!_mArrayCardRollBackIndex) {
        _mArrayCardRollBackIndex = [NSMutableArray array];
    }
    return _mArrayCardRollBackIndex;
}

#pragma mark - 基类方法 ================================================


@end
