---
title: SwiftUI数据流实践
description: 近一个月在使用 SwiftUI 重构我原先使用 Flutter 写的独立开发应用「日·期」，这篇文章总结了我的使用心得
date: 2019-10-19
---
## 前提
状态（State）是一个 App 中最关键的东西之一，比如我们要用 SwiftUI 来开一个音乐播放器，其中比较关键的是播放按钮，我们会有两个播放状态，播放和暂停，不同状态按钮的图片也是不同的

```swift
struct ContentView: View {
	private var isPlaying: Bool = false

	var body: some View {
		Button(action: {
			...
		}) {
			Image(name: isPlaying ? &quot;pause&quot; : &quot;play&quot;)
		}
	}
}
```

这里我们实现了最简单的根据 `isPlaying` 状态显示不同按钮图片的代码，但是我们如何通过按钮的点击事件来更新 `isPlaying` 状态？

## `@State`
SwiftUI 通过 `@State` 来管理属性，当 state 值发生变化，界面也会随之更新，对于一个界面，state 是 single source of truth(并不知道该怎么翻译)

State 实例和它的值并不是等价的，获取它的值可以直接使用它的值属性

应该通过 view 的 body 或者方法来获取 state 属性。因此，建议将 state 属性定义成私有来防止其他 view 来获取它。

可以使用 `binding` 来绑定一个 state，或者使用 `$` 前缀

所以，我们仅需在 Button 的 action 中 `self.isPlaying.toggle()` 来更新，同时也要给 `isPlaying` 使用 `@State` 的 property wrapper

```swift
struct ContentView: View {
	@State private var isPlaying: Bool = false
	
	var body: some View {
		Button(action: {
			self.isPlaying.toggle()
		}) {
			Image(name: self.isPlaying ? &quot;pause&quot; : &quot;play&quot;)
		}
	}
}
```

当我当前这个 View 比较复杂时，我需要拆分组件，这时候我要把 Button 作为一个独立的组件，我们通过 command 点击 Button，使用 `Estract Subview` 来抽取组件

```swift
struct ContentView: View {
    @State var isPlaying: Bool = false
    
    var body: some View {
        HStack {
            PlayerButton()
        }
    }
}

struct PlayerButton: View {
    var body: some View {
        Button(action: {
            self.isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? &quot;pause&quot; : &quot;play&quot;)
        }
    }
}
```

但是 `PlayerButton` 缺少了 `isPlaying` 的状态。

## `@Binding`
我们可以通过 `SwiftUI` 的另一个 `Property Wrapper` 来实现组件间状态的传递。

```swift
struct ContentView: View {
    @State var isPlaying: Bool = false
    
    var body: some View {
        HStack {
            PlayerButton(isPlaying: self.$isPlaying)
        }
    }
}

struct PlayerButton: View {
	@Binding var isPlaying: Bool

    var body: some View {
        Button(action: {
            self.isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? &quot;pause&quot; : &quot;play&quot;)
        }
    }
}
```

特别需要注意的地方是，我们这边需要用上 `$` 符号来做传递。

但是这样做会有一些问题
1. 如果我嵌套了好几级组件，而我最里层的组件需要用到的状态是在最顶层设置的，那么我们需要一级一级的往下传递，而中间几层又并不需要这个属性，就导致了在组件的定义中添加不必要的属性，降低了代码的可读性
2. 状态零散的散布在各个 `View` 中，不利于管理

## @ObservedObject
当我们的状态比较复杂后，又或者我们需要在多个界面共享状态时，我们需要用到 `@ObservedObject`，这里似乎是借鉴了 Redux 的思想，我们会定义一个 `Store` 用来做全局的状态存储，为了能够让它可以使用 `@ObservedObjet` 我们需要遵循 `ObservableObject ` 协议，然后把我们的 `isPlaying` 属性放到 `Store` 中存储

```swift
final class Store: ObservableObject {
	@Published var isPlaying: Bool = false
}
```

然后将 `@State var isPlaying: Bool = false` 替换成 `@ObservedObject var store = Store()` 即可

```swift
struct ContentView: View {
    @ObservedObject var store = Store()
    
    var body: some View {
        PlayerButton(isPlaying: self.$store.isPlaying)
    }
}
```

但是这样做依然解决不了组件间需要不断传递这个 `Store` 的问题，我的解决方案很简单，使用单例

```swift
final class Store: ObservableObject {
	static let shared = Store()

	@Published var isPlaying: Bool = false
}
```

这样我们在需要的地方，获取这个 `Store.shared` 中的属性，对其修改后也能在其他页面作出相应的修改。

## 小结
以上算是我近一个月用 `SwiftUI` 写 side projects 时的一些心得，主要是 `@State`、 `@Binding` 和 `@ObservedObject` 这三个 property wrapper 在 SwiftUI 数据流中的使用 

## 参考资料
1. [ Managing Data Flow in SwiftUI ](https://mecid.github.io/2019/07/03/managing-data-flow-in-swiftui/)
2. [WWDC2019 Session 226 Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226/)
3. [ What’s the difference between @ObservedObject, @State, and @EnvironmentObject? ](https://www.hackingwithswift.com/quick-start/swiftui/whats-the-difference-between-observedobject-state-and-environmentobject)
