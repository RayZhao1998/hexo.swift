---
title: Codable 协议
date: 2019-11-12
description: 简单了解了一下 Codable 协议如何进行 JSON 的序列化与反序列化
tags: test,test1
---

`Codable` 协议能实现基本的序列化和反序列化，`Codable` 其实是两个协议合一—— `Encodable` & `Decodable`

```swift
struct User: Codable {
    var name: String
    var age: Int
}
```

只需要支持 `Codable` 协议，现在就可以将一个 `user` 序列化成 `JSON` 数据

```swift
do {
    let user = User(name: &quot;John&quot;, age: 31)
    let encoder = JSONEncoder()
    let data = try encoder.encode(user)
} catch {
    print(error)
}
```

然后我们可以通过 `JSONDecoder` 进行反序列化

```swift
let decoder = JSONDecoder()
let secondUser = try decoder.decode(User.self, from: data)
```

反序列化出来的 `secondUser` 应该和一开始我们定义的 `user` 是相同的，我们也可以看到输出序列化后的 data：

```swift
String(data: data, encoding: .utf8)!
// {"name":"John","age":31}
```

但是有时候我们拿到的 json 不一定和我们定义的结构一致，比如我们拿到的 User JSON 长得像这样

```json
{
    "user_data": {
        "full_name": "John Sundell",
        "user_age": 31
    }
}
```

一种解决方法是，改我们的 User 结构体使得他符合该 JSON 的格式，当然这种方法优点不切实际。另一种选择我们可以扩展我们 User，添加一个专门用来做序列化和反序列化的类型：

```swift
extension User {
    struct CodingData: Codable {
        struct Container: Codable {
      var fullName: String
      var userAge: Int
    }

    var userData: Container
  }
}
```

然后给 `User.CodingData` 一个方法用来返回 `User` 实体

```swift
extension User.CodingData {
    var user: User {
        return User(
            name: userData.fullName,
            age: userData.userAge
        )
    }
}
```

但是我们“键”不一样，但是我们可以通过 `keyEncodingStrategy` 和 `keyDecodingStrategy` 来解决这个问题，设置成 `convertToSnakeCase` 即可

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

let codingData = try decoder.decoder(User.CodingData.self, from: data)
let user = codingData.user
```

## 参考文章
> 1. [Codable | Swift by Sundell](https://www.notion.so/ninjiacoder/Codable-8e6e4568aa224c85a2d05a2cf7064009#fdd57185228a4819944aec10c995873d)

