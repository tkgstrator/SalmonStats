import Foundation
import SplatNet2
import CodableDictionary
import SwiftUI

extension Result.Response {
    init(from response: ResultStats.Response, playerId: String) {
        let schedule = SplatNet2.schedule.first(where: { $0.startTime == Date.timeIntervalSince1970(iso8601: response.scheduleId) })!
        
        self.init(
            jobScore: nil,
            playerType: nil,
            grade: Result.GradeType(from: response, playerId: playerId),
            otherResults: response.playerResults
                .filter({ $0.playerId != playerId })
                .map({ Result.PlayerResult(
                    from: $0,
                    members: response.memberAccounts,
                    rareWeaponId: response.schedule?.rareWeaponId)
                }),
            schedule: Result.Schedule(from: response.scheduleId),
            kumaPoint: nil,
            waveDetails: response.waves.map({ Result.WaveDetail(from: $0) }),
            jobResult: Result.JobResult(from: response),
            jobId: nil,
            myResult: Result.PlayerResult(
                from: response.playerResults.first(where: { $0.playerId == playerId }) ?? response.playerResults.first!,
                members: response.memberAccounts,
                rareWeaponId: response.schedule?.rareWeaponId
            ),
            gradePointDelta: nil,
            jobRate: nil,
            startTime: schedule.startTime,
            playTime: Date.timeIntervalSince1970(iso8601: response.startAt),
            endTime: schedule.endTime,
            bossCounts: CodableDictionary(uniqueKeysWithValues: response.bossAppearances.map({ ($0.key, Result.BossCount(bossId: $0.key, count: $0.value)) })),
            gradePoint: nil,
            dangerRate: Double(response.dangerRate) ?? 0.0
        )
    }
}

extension Result.PlayerResult {
    init(from player: ResultStats.PlayerResult, members: [ResultStats.MemberAccount]?, rareWeaponId: Int?) {
        self.init(
            pid: player.playerId,
            specialCounts: player.specialUses.map({ $0.count }),
            goldenIkuraNum: player.goldenEggs,
            bossKillCounts: CodableDictionary(uniqueKeysWithValues: player.bossEliminations.counts.map({ ($0.key, Result.BossCount(bossId: $0.key, count: $0.value)) })),
            special: Result.SpecialType(rawValue: player.specialId),
            deadCount: player.death,
            name: members?.first(where: { $0.playerId == player.playerId })?.name,
            ikuraNum: player.powerEggs,
            playerType: nil,
            helpCount: player.rescue,
            weaponList: player.weapons.map({ Result.WeaponList(weaponId: $0.weaponId, rareWeaponId: rareWeaponId)})
        )
    }
}

extension Result.SpecialType {
    init(rawValue: ResultStats.SpecialId) {
        self.init(
            imageA: rawValue.imageA,
            imageB: rawValue.imageB,
            name: rawValue.specialName,
            id: rawValue.specialId
        )
    }
}

extension ResultStats.SpecialId {
    var imageA: Result.ImageA {
        switch self {
            case .splatBombLauncher:
                return .splatBombLauncher
            case .stingRay:
                return .stingRay
            case .inkjet:
                return .inkjet
            case .splashdown:
                return .splashdown
        }
    }
    
    var imageB: Result.ImageB {
        switch self {
            case .splatBombLauncher:
                return .splatBombLauncher
            case .stingRay:
                return .stingRay
            case .inkjet:
                return .inkjet
            case .splashdown:
                return .splashdown
        }
    }
    
    var specialName: String {
        switch self {
            case .splatBombLauncher:
                return "Splat-Bomb Launcher"
            case .stingRay:
                return "Sting Ray"
            case .inkjet:
                return "Inkjet"
            case .splashdown:
                return "Splashdown"
        }
    }
    
    var specialId: Result.SpecialId {
        switch self {
            case .splatBombLauncher:
                return .splatBombLauncher
            case .stingRay:
                return .stingRay
            case .inkjet:
                return .inkjet
            case .splashdown:
                return .splashdown
        }
    }
}

extension Result.BossCount {
    init(bossId: Result.BossId, count: Int) {
        self.init(boss: Result.Boss(bossId: bossId), count: count)
    }
}

extension Result.BossId {
    var bossName: String {
        switch self {
            case .goldie:
                return "Goldie"
            case .steelhead:
                return "Steelhead"
            case .flyfish:
                return "Flyfish"
            case .scrapper:
                return "Scrapper"
            case .steelEel:
                return "Steel Eel"
            case .stinger:
                return "Stinger"
            case .maws:
                return "Maws"
            case .griller:
                return "Griller"
            case .drizzler:
                return "Drizzler"
        }
    }
}

extension Result.Boss {
    enum BossName: String {
        case go
    }
    
    init(bossId: Result.BossId) {
        switch bossId {
            case .goldie:
                self = Result.Boss(name: bossId.rawValue, key: .sakelienGolden)
            case .steelhead:
                self = Result.Boss(name: bossId.rawValue, key: .sakelienBomber)
            case .flyfish:
                self = Result.Boss(name: bossId.rawValue, key: .sakelienCupTwins)
            case .steelEel:
                self = Result.Boss(name: bossId.rawValue, key: .sakelienSnake)
            case .scrapper:
                self = Result.Boss(name: bossId.rawValue, key: .sakelienShield)
            case .stinger:
                self = Result.Boss(name: bossId.rawValue, key: .sakelienTower)
            case .maws:
                self = Result.Boss(name: bossId.rawValue, key: .sakediver)
            case .griller:
                self = Result.Boss(name: bossId.rawValue, key: .sakedozer)
            case .drizzler:
                self = Result.Boss(name: bossId.rawValue, key: .sakerocket)
        }
    }
}

extension Result.Schedule {
    init(from scheduleId: String) {
        let schedule = SplatNet2.schedule.first(where: { $0.startTime == Date.timeIntervalSince1970(iso8601: scheduleId) })!
        
        self.init(
            stage: Result.Stage(from: schedule),
            weapons: schedule.weaponList.map({ Result.WeaponList.init(weaponId: $0.rawValue, rareWeaponId: schedule.rareWeapon?.rawValue) }),
            endTime: schedule.endTime,
            startTime: schedule.startTime
        )
    }
}

extension Result.Stage {
    init(from schedule: Schedule.Response) {
        let stageImage: Result.StageType.Image = Result.StageType.Image(stageId: schedule.stageId)
        self.init(
            name: stageImage.stageName,
            image: stageImage
        )
    }
}

extension Result.StageType.Image {
    init(stageId: Schedule.StageId) {
        switch stageId {
            case .shakeup:
                self = .shakeup
            case .shakeship:
                self = .shakeship
            case .shakehouse:
                self = .shakehouse
            case .shakelift:
                self = .shakelift
            case .shakeride:
                self = .shakeride
        }
    }
    
    var stageName: String {
        switch self {
            case .shakeup:
                return "Spawning Grounds"
            case .shakeship:
                return "Marooner's Bay"
            case .shakehouse:
                return "Lost Outpost"
            case .shakelift:
                return "Salmonid Smokeyard"
            case .shakeride:
                return "Ruins of Ark Polaris"
        }
        
    }
}

extension Result.WeaponList {
    init(weaponId: Int, rareWeaponId: Int?) {
        // クマサンブキが支給されるとき
        if let rareWeaponId = rareWeaponId {
            self.init(
                id: WeaponType.WeaponId(rawValue: String(weaponId))!,
                weapon: nil,
                coopSpecialWeapon: Result.Brand(weaponId: rareWeaponId)
            )
        }
        self.init(
            id: WeaponType.WeaponId(rawValue: String(weaponId))!,
            weapon: Result.Brand(weaponId: weaponId),
            coopSpecialWeapon: nil
        )
    }
}

extension Result.Brand {
    init?(weaponId: Int) {
        self.init(
            id: WeaponType.WeaponId(rawValue: String(weaponId)),
            thumbnail: nil,
            image: WeaponType.Image.shooterShort, // ボールドマーカーを適当にセット(どうせ使わないので)
            name: ""
        )
    }
}

extension Result.GradeType {
    init?(from response: ResultStats.Response, playerId: String) {
        // プレイヤーIDが一致する最初のプレイヤーのgradePointを取得する
        // そのようなプレイヤーがいない、gradePointが入っていない、変換不可能な値がある場合はnilを返す
        guard let gradePoint = response.playerResults.first(where: { $0.playerId == playerId })?.gradePoint,
              let gradeId = Result.GradeId(rawValue: gradePoint) else {
            return nil
        }
        
        self.init(
            longName: gradeId.longName,
            id: gradeId,
            shortName: gradeId.shortName,
            name: gradeId.name
        )
    }
}

extension Result.GradeId {
    init?(rawValue: Int) {
        switch rawValue {
            case 0 ..< 100:
                self = .apparentice
            case 100 ..< 200:
                self = .parttimer
            case 200 ..< 300:
                self = .gogetter
            case 300 ..< 400:
                self = .overachiver
            case 400 ..< 1399:
                self = .profreshional
            default:
                return nil
        }
    }
    
    var longName: String {
        switch self {
            case .profreshional:
                return "Profreshional"
            case .overachiver:
                return "Over achiver"
            case .gogetter:
                return "Go getter"
            case .parttimer:
                return "Part timer"
            case .apparentice:
                return "Apparantice"
            case .intern:
                return "Intern"
        }
    }
    
    var shortName: String {
        switch self {
            case .profreshional:
                return "Profreshional"
            case .overachiver:
                return "Over achiver"
            case .gogetter:
                return "Go getter"
            case .parttimer:
                return "Part timer"
            case .apparentice:
                return "Apparantice"
            case .intern:
                return "Intern"
        }
    }
    
    var name: String {
        switch self {
            case .profreshional:
                return "Profreshional"
            case .overachiver:
                return "Over achiver"
            case .gogetter:
                return "Go getter"
            case .parttimer:
                return "Part timer"
            case .apparentice:
                return "Apparantice"
            case .intern:
                return "Intern"
        }
    }
}

extension Result.JobResult {
    init(from response: ResultStats.Response) {
        self.init(
            failureWave: response.clearWaves == 3 ? nil : response.clearWaves,
            isClear: response.clearWaves == 3,
            failureReason: Result.FailureReason(rawValue: response.failReasonId)
        )
    }
}

extension Result.WaveDetail {
    init(from response: ResultStats.Wave) {
        self.init(
            quotaNum: response.goldenEggQuota,
            goldenIkuraPopNum: response.goldenEggAppearances,
            waterLevel: Result.WaterLevel(name: Result.WaterKey(waterLevel: response.waterId).waterName, key: Result.WaterKey(waterLevel: response.waterId)),
            ikuraNum: response.powerEggCollected,
            goldenIkuraNum: response.goldenEggDelivered,
            eventType: Result.EventType(name: Result.EventKey(eventType: response.eventId).eventName, key: Result.EventKey(eventType: response.eventId))
       )
    }
}

extension Result.FailureReason {
    init?(rawValue: Int?) {
        switch rawValue {
            case 1:
                self = .wipeOut
            case 2:
                self = .timeLimit
            default:
                return nil
        }
    }
}

extension Result.WaterKey {
    init(waterLevel: Int) {
        switch waterLevel {
            case 1:
                self = .low
            case 2:
                self = .normal
            case 3:
                self = .high
            default:
                self = .normal
        }
    }
    
    var waterName: String {
        switch self {
            case .high:
                return "High tide"
            case .low:
                return "Low tide"
            case .normal:
                return "Normal"
        }
    }
}

extension Result.EventKey {
    init(eventType: Int) {
        switch eventType {
            case 0:
                self = .waterLevels
            case 1:
                self = .cohockCharge
            case 2:
                self = .theMothership
            case 3:
                self = .goldieSeeking
            case 4:
                self = .griller
            case 5:
                self = .fog
            case 6:
                self = .rush
            default:
                self = .waterLevels
        }
    }
    
    var eventName: String {
        switch self {
            case .waterLevels:
                return "-"
            case .rush:
                return "Rush"
            case .goldieSeeking:
                return "Goldie Seeking"
            case .griller:
                return "The Griller"
            case .fog:
                return "Fog"
            case .theMothership:
                return "The Mothership"
            case .cohockCharge:
                return "Cohock Charge"
        }
    }
}

extension Date {
    static func timeIntervalSince1970(iso8601: String) -> Int {
        guard let dateTime: Date = SalmonStats.formatter.date(from: iso8601) else {
            let dateTime: Date = SalmonStats.iso8601formatter.date(from: iso8601)!
            return Int(dateTime.timeIntervalSince1970)
        }
        return Int(dateTime.timeIntervalSince1970)
    }
    
    static func iso8601Format(timestamp: Int) -> String {
        SalmonStats.formatter.string(from: Date(timeIntervalSince1970: Double(timestamp)))
    }
}

extension SalmonStats {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static let iso8601formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter
    }()
}
