//
//  YCViewController.m
//  YCCardView
//
//  Created by renyichun on 11/19/2021.
//  Copyright (c) 2021 renyichun. All rights reserved.
//

#import "YCViewController.h"

#import "YCCardView.h"
#import "YCCardCell.h"

@interface YCViewController ()<YCCardViewDelegate,YCCardViewDataSource>

// 数据源
@property (nonatomic, strong) NSMutableArray *mArrayData;
@property (weak, nonatomic) IBOutlet YCCardView *cardView;

@end

@implementation YCViewController

#pragma mark - 初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self addSubViews];
    // 添加测试数据
    [self loadNewData];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 刷新卡片
    [self.cardView yc_reloadDataWithAnimation:YES];
}

- (void)addSubViews {
    
    self.cardView.delegate = self;
    self.cardView.dataSource = self;
}

#pragma mark - 点击事件
 
- (IBAction)loadNewData:(id)sender {
    [self loadNewData];
    [self.cardView yc_reloadDataWithAnimation:YES];
}

- (IBAction)leftAction:(id)sender {
    [self.cardView yc_nextCardWithDirection:NO];
}

- (IBAction)rightAction:(id)sender {
    [self.cardView yc_nextCardWithDirection:YES];
}

- (IBAction)rollBack:(id)sender {
    
    [self.cardView yc_cardViewRollbackCellPreHandle:^BOOL{
        return YES;
    } complete:^(YCCardCell * _Nonnull carlCell, NSInteger cellIndex) {
        
    }];
}

#pragma mark - 代理方法

#pragma mark - YCCardViewDelegate

/**
 * 更新显示的卡片cell
 * @param cardView 卡片容器视图
 * @param cardDragCell 卡片容器视图对应的每个item
 * @param intIndex 对应的每个item的索引
 */
- (void)yc_cardDragView:(YCCardView *)cardView updateDisplayCell:(YCCardCell *)cardCell cellForRowAtIndex:(NSInteger)indexRow {
    NSLog(@"Ryc_______ cellIndex:%@",@(indexRow));
    
    if (indexRow >= self.mArrayData.count) {
        return;
    }
    [cardCell yc_setObject:self.mArrayData[indexRow]];
}


/**
 * 点击卡片cell事件
 * @param cardView 卡片拖拽视图
 * @param aUIntIndex 卡片所对应的位置
 */
- (void)yc_cardView:(YCCardView *)cardView didSelectedIndex:(NSUInteger)indexRow {
    NSLog(@"Ryc_______ 点击cellIndex:%@",@(indexRow));
}

/**
 卡片是否可以移动，拖拽的时候，可以进行一些条件控制，比如喜欢次数用完了，需要用户充值vip等
 * @param cardView 卡片拖拽视图
 * @param isRightDirection 是否为右边
 */
- (BOOL)yc_cardDragView:(YCCardView *)cardView cheackCardHasCanDragWithDragingDirection:(BOOL )isRightDirection {
    return YES;
}


#pragma mark - YCCardViewDataSource

- (NSInteger)yc_numberOfRowsInCardDragView:(YCCardView *)cardView {
    return self.mArrayData.count;
}

- (UIEdgeInsets)yc_edgeInsetsInCardDragView:(YCCardView *)cardView {
    return UIEdgeInsetsMake(60,10, 60, 10);
}

- (YCCardCell *)yc_creatCellForCardView:(YCCardView *)cardView {
    YCCardCell *cell = [[YCCardCell alloc] init];
    cell.backgroundColor = [self p_randomColor];
    return cell;
}

/**
 加载更多数据
 */
- (void)yc_loadDataMore {
    [self loadMoreData];
}

#pragma mark - 对外方法

#pragma mark - 私有方法


// 加载新数据
- (void)loadNewData {
    [self.mArrayData removeAllObjects];
    for (NSInteger index = 1; index < 11; index ++) {
        NSString *title = [NSString stringWithFormat:@"第%@个",@(index)];
        [self.mArrayData addObject:title];
    }
}

// 加载更多数据
- (void)loadMoreData {
    NSInteger totolNumer = self.mArrayData.count;
    for (NSInteger index = 0; index < 10; index ++) {
        NSString *title = [NSString stringWithFormat:@"第%@个",@(totolNumer + index + 1)];
        [self.mArrayData addObject:title];
    }
}

// 随机颜色
- (UIColor *)p_randomColor {
    NSInteger aRedValue = arc4random() % 255;
    NSInteger aGreenValue = arc4random() % 255;
    NSInteger aBlueValue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
    return randColor;
}

#pragma mark - set/get

- (NSMutableArray *)mArrayData {
    if (!_mArrayData) {
        _mArrayData = [NSMutableArray array];
    }
    return _mArrayData;
}

#pragma mark - 基类方法




@end
