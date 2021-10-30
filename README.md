# SalmonStats

[Salmon Stats](https://salmon-stats.yuki.games/)からデータを取得するSwift Package Managerに対応したライブラリです。

## シフト統計の取得

指定されたシフトのグローバル記録を取得します。

```swift
ShiftStats
- clearGames: Int
- clearWaves: Int
- games: Int
- goldenEggs: Int
- powerEggs: Int
- rescue: Int
- bossCounts: [Int]
- bossKillCounts: [Int]
```

```swift
SalmonStats.shared.getShiftStats(startTime: Int) // <- シフトIDを指定
  .sink(receiveCompletion: { completion in
    switch completion {
      case .finished:
        break
      case .failure(let error):
        print(error)
        // エラーハンドリング
    }, receiveValue: { response in
      // 受け取った値の処理
})
```

## シフト記録の取得

指定されたシフトのSalmon Statsでの記録を取得します。

```swift
SalmonStats.shared.getShiftRecord(startTime: Int) // <- シフトIDを指定
  .sink(receiveCompletion: { completion in
    switch completion {
      case .finished:
        break
      case .failure(let error):
        print(error)
        // エラーハンドリング
    }, receiveValue: { response in
      // 受け取った値の処理
})
```

## リザルトを1件取得

```swift
Response
- ResultCoop

ResultCoop
- jobId: Int
- stageId: Int
- jobResult: ResultJob
  - failureReason: String?
  - failureWave: Int?
  - isClear: Bool?
- dangerRate: Double
- schedule: Schedule
  - startTime: Int
  - endTime: Int
  - weaponList: [Int]
  - stageId: Int
- time: ResultTime
  - startTime: Int
  - playTime: Int
  - endTime: Int
- bossCounts: [Int]
- bossKillCounts: [Int]
- results: [ResultPlayer]
  - bossKillCounts: [Int]
  - helpCount: Int
  - deadCount: Int
  - ikuraNum: Int
  - goldenIkuraNum: Int
  - pid: String
  - name: String? // 複数取得時はNil
  - specialId: Int
  - specialCount: [Int]
  - weaponList: [Int]
- waveDetails: [ResultWave]
  - eventType: Int
  - waterLevel: Int
  - ikuraNum: Int
  - goldenIkuraNum: Int
  - goldenIkuraPopNum: Int
  - quotaNum: Int 
```

```swift
SalmonStats.shared.getResult(resultId: 100000) // <- プレイヤーIDとページIDを指定
  .sink(receiveCompletion: { completion in
    switch completion {
      case .finished:
        break
      case .failure(let error):
        print(error)
        // エラーハンドリング
    }, receiveValue: { response in
      // 受け取った値の処理
})
```

## リザルトを200件まで取得

指定されたプレイヤーのリザルトを最大200件まで取得します。

繰り返すことで全てのリザルトを取得できます。

```swift
Response
- [ResultCoop]
```

```swift
SalmonStats.shared.getResults(nsaid: String, pageId: Int) // <- プレイヤーIDとページIDを指定
  .sink(receiveCompletion: { completion in
    switch completion {
      case .finished:
        break
      case .failure(let error):
        print(error)
        // エラーハンドリング
    }, receiveValue: { response in
      // 受け取った値の処理
})
```

## ユーザメタデータの取得

指定されたユーザのメタデータを取得します。

```swift
Response
- [Metadata]

Metadata
- isCustomName: Int
- isRegistered: Int
- name: String
- playerId: String
- results: Dictionary
  - clear: Int
  - fail: Int
- total
  - bossEliminationCount: Int
  - death: Int
  - goldenEggs: Int
  - powerEggs: Int
  - rescue: Int
- twitterAvatar: String?
```

```swift
SalmonStats.shared.getMetadata(nsaid: String) // <- プレイヤーIDを指定
  .sink(receiveCompletion: { completion in
    switch completion {
      case .finished:
        break
      case .failure(let error):
        print(error)
        // エラーハンドリング
    }, receiveValue: { response in
      // 受け取った値の処理
})
```
