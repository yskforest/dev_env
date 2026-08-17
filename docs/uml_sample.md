# Mermaid / PlantUML サンプル

注文管理システムを題材にした Mermaid と PlantUML の総合サンプル集です。共通図は各図ごとに Mermaid、PlantUML の順で記載しています。

## 共通 UML 相当図

### ユースケース図
ユーザーや外部アクターと、システムが提供する機能の関係を表します。MermaidのflowchartにはUML専用のアクター記号がないため、外側に丸角ノードとして表現します。

- Mermaid
```mermaid
flowchart LR
    customer([顧客])
    staff([担当者])
    admin([管理者])
    subgraph system["注文システム"]
      direction TB
      place((注文する))
      pay((支払う))
      review((注文を確認))
      ship((発送する))
      place -.-> pay
      review -.-> ship
    end
    customer --> place
    customer --> pay
    admin --> review
    staff --> ship
```

- PlantUML
```plantuml
@startuml
left to right direction
actor 顧客
actor 担当者
actor 管理者
rectangle 注文システム {
  usecase "注文する" as Place
  usecase "支払う" as Pay
  usecase "注文を確認" as Review
  usecase "発送する" as Ship
}
顧客 --> Place
顧客 --> Pay
管理者 --> Review
担当者 --> Ship
Place ..> Pay : <<include>>
Review ..> Ship : <<include>>
@enduml
```

### シーケンス図
処理の時間的な流れと、登場するオブジェクト間のメッセージを表します。

- Mermaid
```mermaid
sequenceDiagram
    actor 顧客
    participant Web as Webアプリ
    participant Order as 注文サービス
    participant Stock as 在庫サービス
    participant Pay as 決済サービス
    顧客->>Web: 注文を確定
    Web->>Order: 注文を作成
    Order->>Stock: 在庫を確保
    Stock-->>Order: 確保完了
    Order->>Pay: 支払いを要求
    Pay-->>Order: 支払い成功
    Order-->>Web: 注文受付完了
    Web-->>顧客: 確認画面を表示
```

- PlantUML
```plantuml
@startuml
actor 顧客
participant Webアプリ as Web
participant 注文サービス as Order
participant 在庫サービス as Stock
participant 決済サービス as Pay
顧客 -> Web : 注文を確定
Web -> Order : 注文を作成
Order -> Stock : 在庫を確保
Stock --> Order : 確保完了
Order -> Pay : 支払いを要求
Pay --> Order : 支払い成功
Order --> Web : 注文受付完了
Web --> 顧客 : 確認画面を表示
@enduml
```

### クラス図
クラス、属性、操作、クラス間の関係など、システムの静的構造を表します。

- Mermaid
```mermaid
classDiagram
    class Customer {
      +customerId: UUID
      +name: String
      +placeOrder()
    }
    class Order {
      +orderId: UUID
      +status: OrderStatus
      +total(): Money
    }
    class OrderItem {
      +quantity: int
      +unitPrice: Money
    }
    class Product {
      +productId: UUID
      +name: String
      +price: Money
      +stock: int
    }
    class Payment {
      +paymentId: UUID
      +amount: Money
      +status: PaymentStatus
    }
    Customer "1" --> "0..*" Order : places
    Order "1" *-- "1..*" OrderItem : contains
    OrderItem "0..*" --> "1" Product : refers to
    Order "1" --> "0..1" Payment : paid by
```

- PlantUML
```plantuml
@startuml
class Customer {
  +customerId: UUID
  +name: String
  +placeOrder()
}
class Order {
  +orderId: UUID
  +status: OrderStatus
  +total(): Money
}
class OrderItem {
  +quantity: int
  +unitPrice: Money
}
class Product {
  +productId: UUID
  +name: String
  +price: Money
  +stock: int
}
class Payment {
  +paymentId: UUID
  +amount: Money
  +status: PaymentStatus
}
Customer "1" --> "0..*" Order : places
Order "1" *-- "1..*" OrderItem : contains
OrderItem "0..*" --> "1" Product : refers to
Order "1" --> "0..1" Payment : paid by
@enduml
```

### アクティビティ図
業務や処理の流れ、分岐、並行処理などを表します。

- Mermaid
```mermaid
flowchart TD
    start((開始)) --> input[/注文情報を入力/]
    input --> confirm[注文内容を確認]
    confirm --> valid{在庫あり?}
    valid -- はい --> payment[支払いを処理]
    valid -- いいえ --> out[在庫切れを通知]
    payment --> finish((注文受付))
    out --> cancel((終了))
```

- PlantUML
```plantuml
@startuml
start
:注文情報を入力;
:注文内容を確認;
if (在庫あり?) then (はい)
  :支払いを処理;
  :注文受付;
else (いいえ)
  :在庫切れを通知;
endif
stop
@enduml
```

### ステートマシン図
オブジェクトの状態と、イベントによる状態遷移を表します。

- Mermaid
```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Confirmed: 注文確定
    Confirmed --> Paid: 支払い成功
    Paid --> Shipped: 発送
    Shipped --> Delivered: 配達完了
    Confirmed --> Cancelled: キャンセル
    Paid --> Refunded: 返金
    Delivered --> Returned: 返品
    Delivered --> [*]
    Cancelled --> [*]
    Refunded --> [*]
    Returned --> [*]
```

- PlantUML
```plantuml
@startuml
[*] --> Draft
Draft --> Confirmed : 注文確定
Confirmed --> Paid : 支払い成功
Paid --> Shipped : 発送
Shipped --> Delivered : 配達完了
Confirmed --> Cancelled : キャンセル
Paid --> Refunded : 返金
Delivered --> Returned : 返品
Delivered --> [*]
Cancelled --> [*]
Refunded --> [*]
Returned --> [*]
@enduml
```

### ER 図
データベースのエンティティ、属性、関連、多重度を表します。

- Mermaid
```mermaid
erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : included_in
    CUSTOMER {
      uuid customer_id PK
      string name
    }
    ORDER {
      uuid order_id PK
      uuid customer_id FK
      string status
    }
    ORDER_ITEM {
      uuid order_id PK, FK
      uuid product_id PK, FK
      int quantity
    }
    PRODUCT {
      uuid product_id PK
      string name
      decimal price
    }
    PAYMENT {
      uuid payment_id PK
      uuid order_id FK
      decimal amount
      string status
    }
```

- PlantUML
```plantuml
@startuml
entity CUSTOMER {
  customer_id : uuid <<PK>>
  name : string
}
entity ORDER {
  order_id : uuid <<PK>>
  customer_id : uuid <<FK>>
  status : string
}
entity ORDER_ITEM {
  order_id : uuid <<PK,FK>>
  product_id : uuid <<PK,FK>>
  quantity : int
}
entity PRODUCT {
  product_id : uuid <<PK>>
  name : string
  price : decimal
}
entity PAYMENT {
  payment_id : uuid <<PK>>
  order_id : uuid <<FK>>
  amount : decimal
  status : string
}
CUSTOMER --> ORDER : places
ORDER --> ORDER_ITEM : contains
PRODUCT --> ORDER_ITEM : included_in
ORDER --> PAYMENT : paid_by
@enduml
```

### コンポーネント図
システムを構成するソフトウェア部品と、その依存関係を表します。

- Mermaid（互換表現）
```mermaid
flowchart TB
    customer[顧客]
    pay[決済サービス]
    subgraph cloud[クラウド]
      web[Webアプリ]
      order[注文サービス]
      db[(注文DB)]
    end
    customer --> web
    web --> order
    order --> db
    order --> pay
```

- PlantUML
```plantuml
@startuml
actor 顧客 as Customer
cloud "クラウド" {
  component Webアプリ as Web
  component 注文サービス as Order
  database 注文DB as DB
}
component 決済サービス as Pay
Customer --> Web
Web --> Order
Order --> DB
Order --> Pay
@enduml
```

### 配置図
ソフトウェア部品が、どのサーバーや実行環境に配置されるかを表します。

- Mermaid（互換表現）
```mermaid
flowchart TB
    subgraph Webサーバー
      web[Webアプリ]
    end
    subgraph アプリサーバー
      order[注文サービス]
    end
    db[(注文DB)]
    pay[決済サービス]
    web --> order
    order --> db
    order --> pay
```

- PlantUML
```plantuml
@startuml
node "Webサーバー" as Web {
  artifact "Webアプリ" as App
}
node "アプリサーバー" as Server {
  artifact "注文サービス" as Order
}
database "注文DB" as DB
component "決済サービス" as Pay
Web --> Server
Server --> DB
Server --> Pay
@enduml
```

### ガントチャート
作業の期間、順序、依存関係を時系列で表します。

- Mermaid
```mermaid
gantt
    title 注文機能の開発計画
    dateFormat YYYY-MM-DD
    section 設計
    API設計 :done, api, 2026-08-01, 3d
    DB設計 :done, db, after api, 2d
    section 実装
    注文サービス :active, svc, after db, 5d
    画面実装 :ui, after db, 4d
    テスト :test, after svc, 3d
```

- PlantUML
```plantuml
@startgantt
Project starts 2026-08-01
[API設計] lasts 3 days
[DB設計] starts at [API設計]'s end and lasts 2 days
[注文サービス] starts at [DB設計]'s end and lasts 5 days
[画面実装] starts at [DB設計]'s end and lasts 4 days
[テスト] starts at [注文サービス]'s end and lasts 3 days
@endgantt
```

### ファイルツリー
プロジェクトのディレクトリ構成と、主要なファイルの配置を表します。

- Mermaid（互換表現）
```mermaid
flowchart TB
    subgraph root[注文システム]
      direction TB
      subgraph src[src]
        api[order-api.ts]
        service[order-service.ts]
        model[order-model.ts]
        repository[order-repository.ts]
      end
      subgraph tests[tests]
        unit[order-service.test.ts]
        integration[order-api.integration.test.ts]
      end
      subgraph config[設定ファイル]
        package[package.json]
        readme[README.md]
      end
    end
```

- PlantUML
```plantuml
@startuml
folder "注文システム" {
  folder "src" {
    file "order-api.ts"
    file "order-service.ts"
    file "order-model.ts"
    file "order-repository.ts"
  }
  folder "tests" {
    file "order-service.test.ts"
    file "order-api.integration.test.ts"
  }
  file "package.json"
  file "README.md"
}
@enduml
```

### フローチャート
入力、判断、処理、エラーなどの基本的な処理の流れを表します。

- Mermaid
```mermaid
flowchart LR
    input[/入力/]
    valid{検証}
    auth{認証済み?}
    save[(DB)]
    error[/エラー/]
    input --> valid
    valid -->|成功| auth
    valid -->|失敗| error
    auth -->|はい| save
    auth -->|いいえ| error
```

- PlantUML（互換表現）
```plantuml
@startuml
start
:入力;
:検証;
if (検証成功?) then (はい)
  if (認証済み?) then (はい)
    :DBへ保存;
  else (いいえ)
    :エラー;
  endif
else (いいえ)
  :エラー;
endif
stop
@enduml
```

## 共通比較（互換表現を含む）

### マインドマップ
情報やアイデアを中心テーマから階層的に整理します。

- Mermaid
```mermaid
mindmap
  root((注文システム))
    顧客
      登録
      注文履歴
    注文
      商品
      支払い
      配送
```

- PlantUML
```plantuml
@startmindmap
* 注文システム
** 顧客
*** 登録
*** 注文履歴
** 注文
*** 商品
*** 支払い
*** 配送
@endmindmap
```

### スイムレーン
担当者や部門ごとの責任範囲を分けて、業務フローを表します。

- Mermaid（互換表現）
```mermaid
flowchart LR
    subgraph 顧客
      request[注文する]
      receive[受付を確認]
    end
    subgraph 店舗
      check[在庫を確認]
      pack[商品を梱包]
    end
    subgraph 配送会社
      ship[商品を発送]
    end
    request --> check --> pack --> ship --> receive
```

- PlantUML（互換表現）
```plantuml
@startuml
|顧客|
start
:注文する;
|店舗|
:在庫を確認;
:商品を梱包;
|配送会社|
:商品を発送;
|顧客|
:受付を確認;
stop
@enduml
```

### 要求図
要求と、それを満たすシステム要素や検証方法の関係を表します。

- Mermaid（互換表現）
```mermaid
flowchart LR
    orderApi[注文API]
    orderReq[REQ-001: 注文を登録できること]
    orderApi -->|satisfies| orderReq
```

- PlantUML（互換表現）
```plantuml
@startuml
rectangle "REQ-001\n注文を登録できること" as orderReq
component "注文API" as orderApi
orderApi ..> orderReq : satisfies
@enduml
```

### C4
システム、利用者、外部サービスの関係を段階的に整理します。

- Mermaid（互換表現）
```mermaid
flowchart LR
    customer[顧客]
    shop[注文システム]
    payment[決済サービス]
    customer -->|注文する| shop
    shop -->|支払いを依頼| payment
```

- PlantUML（互換表現）
```plantuml
@startuml
actor 顧客 as customer
rectangle 注文システム as shop
rectangle 決済サービス as payment
customer --> shop : 注文する
shop --> payment : 支払いを依頼
@enduml
```

### Sankey
量の流れや、ある入口から複数の出口へ分岐する過程を表します。

- Mermaid（互換表現）
```mermaid
flowchart LR
    customer[顧客] -->|100| products[商品一覧]
    products -->|70| cart[カート]
    products -->|30| leave[離脱]
    cart -->|55| purchase[購入]
    cart -->|15| leave
```

- PlantUML（互換表現）
```plantuml
@startuml
rectangle 顧客 as customer
rectangle 商品一覧 as products
rectangle カート as cart
rectangle 購入 as purchase
rectangle 離脱 as leave
customer --> products : 100
products --> cart : 70
products --> leave : 30
cart --> purchase : 55
cart --> leave : 15
@enduml
```

### XY チャート
数値の推移や、複数の項目間の関係を表します。

- Mermaid（互換表現）
```mermaid
flowchart LR
    title[月別注文数]
    jan[1月: 42] --> feb[2月: 58] --> mar[3月: 71] --> apr[4月: 83]
```

- PlantUML（互換表現）
```plantuml
@startuml
rectangle "1月: 42" as jan
rectangle "2月: 58" as feb
rectangle "3月: 71" as mar
rectangle "4月: 83" as apr
jan --> feb
feb --> mar
mar --> apr
@enduml
```

### ブロック図
大きな機能や構成要素をブロックとして整理します。

- Mermaid（互換表現）
```mermaid
flowchart TB
    web[Web] --> gateway[API Gateway]
    gateway --> auth[認証サービス]
    gateway --> order[注文サービス]
    order --> pay[決済サービス]
    order --> db[(注文DB)]
    order --> cache[(Redisキャッシュ)]
    pay --> provider[外部決済]
```

- PlantUML（互換表現）
```plantuml
@startuml
rectangle Web
rectangle "API Gateway" as Gateway
rectangle "認証サービス" as Auth
rectangle "注文サービス" as Order
rectangle "決済サービス" as Pay
database "注文DB" as DB
database "Redisキャッシュ" as Cache
rectangle "外部決済" as Provider
Web --> Gateway
Gateway --> Auth
Gateway --> Order
Order --> Pay
Order --> DB
Order --> Cache
Pay --> Provider
@enduml
```

### パケット図
通信パケットやデータのフィールド構成を表します。

- Mermaid（互換表現）
```mermaid
flowchart LR
    version[0-3: Version] --> flags[4-7: Flags] --> length[8-15: Length] --> orderId[16-31: Order ID]
```

- PlantUML（互換表現）
```plantuml
@startuml
rectangle "0-3: Version" as version
rectangle "4-7: Flags" as flags
rectangle "8-15: Length" as length
rectangle "16-31: Order ID" as orderId
version --> flags
flags --> length
length --> orderId
@enduml
```

## Mermaid 固有・拡張図

### ユーザージャーニー
```mermaid
journey
    title 顧客の注文体験
    section 商品選択
      商品を検索: 5: 顧客
      商品を比較: 4: 顧客
    section 購入
      カートに追加: 5: 顧客
      支払い: 3: 顧客
      確認メールを受信: 5: 顧客
```

### 円グラフ
```mermaid
pie title 注文ステータス
    "配送済み" : 55
    "処理中" : 30
    "キャンセル" : 15
```

### 四象限
```mermaid
quadrantChart
    title 商品機能の優先度
    x-axis 低コスト --> 高コスト
    y-axis 低効果 --> 高効果
    quadrant-1 戦略投資
    quadrant-2 クイックウィン
    quadrant-3 保留
    quadrant-4 再検討
    簡易検索: [0.2, 0.8]
    レコメンド: [0.8, 0.9]
    CSV出力: [0.4, 0.3]
```

### Git グラフ
```mermaid
gitGraph
    commit id: "初期実装"
    branch feature/order
    checkout feature/order
    commit id: "注文API"
    checkout main
    commit id: "README更新"
    merge feature/order id: "注文機能を統合"
```

### タイムライン
```mermaid
timeline
    title 注文システムの沿革
    2024 : 要件定義
    2025 : MVPリリース
         : 決済連携
    2026 : 配送追跡を追加
```

## PlantUML 固有・拡張図

### オブジェクト図
```plantuml
@startuml
object customer {
  customerId = "C-001"
  name = "山田太郎"
}
object order {
  orderId = "O-001"
  status = "Paid"
}
customer --> order : places
@enduml
```

### タイミング図
```plantuml
@startuml
robust "注文" as Order
robust "支払い" as Pay
@0
Order is Draft
Pay is Idle
@1
Order is Confirmed
@2
Pay is Paid
@3
Order is Shipped
@enduml
```

### WBS
```plantuml
@startwbs
* 注文機能
** 要件定義
** 設計
*** API
*** DB
*** UI
** 実装
*** 注文サービス
*** 決済連携
** テスト
*** 単体テスト
*** 結合テスト
** リリース
@endwbs
```

### JSON
```plantuml
@startjson
{
  "orderId": "O-001",
  "status": "Paid",
  "items": [
    { "productId": "P-001", "quantity": 2 }
  ]
}
@endjson
```

### YAML
```plantuml
@startyaml
order:
  id: O-001
  status: Paid
  items:
    - product: P-001
      quantity: 2
@endyaml
```

### EBNF
```plantuml
@startebnf
order = customer, { item }, payment ;
item = product, quantity ;
payment = "card" | "bank" ;
@endebnf
```

### Regex
```plantuml
@startregex
^[A-Z]{1,3}-[0-9]{3}$
@endregex
```

### Network / nwdiag
```plantuml
@startnwdiag
network internet {
  address = "203.0.113.0/24";
  web [address = "203.0.113.10"];
}
network private {
  app [address = "10.0.0.10"];
  db [address = "10.0.0.20"];
}
@endnwdiag
```

### Salt（画面モック）
```plantuml
@startsalt
{+
  注文検索 | "O-001" | [検索]
  {#
    ステータス | Paid
    合計 | 12,000円
  }
}
@endsalt
```

### Wireframe
```plantuml
@startsalt
{+
  注文詳細
  {
    顧客名 | 山田太郎
    状態 | Paid
    合計 | 12,000円
  }
  [キャンセル] | [発送する]
}
@endsalt
```

### Archimate
```plantuml
@startuml
!include <archimate/Archimate>
Business_Actor(customer, "顧客")
Business_Service(service, "注文サービス")
Technology_Artifact(db, "注文DB")
Rel_Serving(service, customer, "提供")
Rel_Realization(db, service, "実装")
@enduml
```

### Chronology
```plantuml
@startuml
robust "注文" as Order
concise "支払い" as Payment
@0
Order is Draft
Payment is Idle
@1
Order is Confirmed
Payment is Waiting
@2
Order is Paid
Payment is Paid
@3
Order is Shipped
Payment is Paid
@enduml
```

### 数式（AsciiMath・互換表現）
```plantuml
@startuml
rectangle "total = sum(quantity_i * unitPrice_i)" as formula
@enduml
```

### Information Engineering（IE）
```plantuml
@startuml
entity CUSTOMER {
  customer_id <<key>>
  name
}
entity ORDER {
  order_id <<key>>
  customer_id
}
CUSTOMER ||--o{ ORDER : places
@enduml
```

### Chen 形式 ER（互換表現）
```plantuml
@startuml
entity CUSTOMER {
  customer_id : uuid <<key>>
  name
}
entity ORDER {
  order_id : uuid <<key>>
  status
}
CUSTOMER ||--o{ ORDER : places
@enduml
```

### Chart（PlantUML 1.2026.0+）
```plantuml
@startchart
h-axis [1月, 2月, 3月, 4月]
v-axis "注文数" 0 --> 100
bar "注文数" [42, 58, 71, 83]
@endchart
```

## 表示方法

- Mermaid: Mermaid 対応の Markdown エディタ、または Mermaid Live Editor でコードブロックをレンダリングします。
- PlantUML: `@startuml` から `@enduml`（または各図種の開始・終了タグ）を PlantUML 対応エディタでレンダリングします。

一部の新しい Mermaid 図種や PlantUML の Chart は、利用するバージョンによって未対応の場合があります。
