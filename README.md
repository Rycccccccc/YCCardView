# YCCardView
[![Version](https://img.shields.io/cocoapods/v/YCCardView.svg?style=flat)](https://cocoapods.org/pods/YCCardView)
[![License](https://img.shields.io/cocoapods/l/YCCardView.svg?style=flat)](https://cocoapods.org/pods/YCCardView)
[![Platform](https://img.shields.io/cocoapods/p/YCCardView.svg?style=flat)](https://cocoapods.org/pods/YCCardView)

-----
## 简介

[功能罗列以及实现博客地址](https://juejin.cn/editor/drafts/7036766272616398856 "") 


`效果图如下`

![image](./source/img_01.gif)

该框架实现了类似于<font color=#0000FF >探探左滑右滑</font> 、<font color=#0000FF >陌陌的点点匹配</font>功能。 功能齐全，可以完成商业级的项目。

<font color=#FF0000 >喜欢的朋友希望给个Star支持一下,谢谢!!!</font>

### 描述
- 1、该框架采用<font color=#0000FF >UITableView</font> 的设计思想，内部使用四张卡片实现卡片的复用效果。通过更新卡片的代理回调来显示对于位置的数据。具体可参考demo示例。
- 2、建议使用者新建一个Cell继承<font color=#0000FF >YCCardCell</font>使用，<font color=#0000FF >YCCardCell</font> 只是一个基类，监听了卡片滑动的距离等操作，方便自定义cell处理相关业务：比如向左滑动显示不喜欢图标，向右滑动显示喜欢图标等。
- 3、统一术语
    - 向左滑动也叫：不喜欢
    - 向右滑动也叫：喜欢
    - 回退也叫： 撤销 

### 功能
- 1、不喜欢操作
   向左拖拽卡片，卡片向左移出。
- 2、喜欢操作
    向右拖拽卡片，卡片向左移出。
- 3、撤销操作
    - 只会回退向左移出的卡片，如果没有向左移出的卡片，则无法回退。 
    - 陌陌里面vip一次只能回退上一个不喜欢的卡片，回退完成，必须等下次有不喜欢的卡片才能回退。属于单次只能回退一个卡片，本框架支持多张卡片回退，也支持陌陌的单次回退，具体看demo
- 4、加载更多数据功能
    - 根据用户设置的阀值（默认为5）去触发加载更多数据的回调。
- 5、检测是否外界允许拖拽
    - 喜欢、不喜欢拖拽结束，检测是否外界允许拖拽：不允许，则回复原位。这里针对一些业务场景比如：用户喜欢的次数用完了，再次触发喜欢操作，则需要弹框购买vip。
- 6、无数据回调
- 7、卡片点击事件
    
    
### 代码示例

1、代理方法
```objc
#pragma mark - 代理方法

#pragma mark - YCCardViewDelegate

/**
 * 更新显示的卡片cell
 * @param cardView 卡片容器视图
 * @param cardDragCell 卡片容器视图对应的每个item
 * @param intIndex 对应的每个item的索引
 */
- (void)yc_cardDragView:(YCCardView *)cardView updateDisplayCell:(YCCardCell *)cardCell cellForRowAtIndex:(NSInteger)indexRow {
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

```


### 注意点
demo示例只是罗列了该框架的功能使用，上层业务控制，结合具体情况设置。比如：卡片拖拽的时候，操作按钮视图关闭交互,拖拽结束再打开等

-----
## 安装方式

YCCardView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YCCardView'
```

## Authorzuozhe

`Rycccccccc`, 787725121@qq.com

## License

YCCardView is available under the MIT license. See the LICENSE file for more info.
