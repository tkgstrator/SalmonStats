import Foundation
import SplatNet2
import CodableDictionary

extension Result.Response {
    init(from response: ResultStats.Response, playerId: String) {
        self.init(
            jobScore: nil,
            playerType: nil,
            grade: Result.GradeType(from: response, playerId: playerId),
            otherResults: response.playerResults
                .filter({ $0.playerId != playerId })
                .map({ Result.PlayerResult(
                    from: $0,
                    members: response.memberAccounts,
                    rareWeaponId: response.schedule.rareWeaponId)
                }),
            schedule: Result.Schedule(from: response.schedule),
            kumaPoint: nil,
            waveDetails: response.waves.map({ Result.WaveDetail(from: $0) }),
            jobResult: Result.JobResult(from: response),
            jobId: nil,
            myResult: Result.PlayerResult(
                from: response.playerResults.first(where: { $0.playerId == playerId }) ?? response.playerResults.first!,
                members: response.memberAccounts,
                rareWeaponId: response.schedule.rareWeaponId
            ),
            gradePointDelta: nil,
            jobRate: nil,
            startTime: Date.timeIntervalSince1970(iso8601: response.scheduleId),
            playTime: Date.timeIntervalSince1970(iso8601: response.startAt),
            endTime: Date.timeIntervalSince1970(iso8601: response.schedule.endAt),
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
    
    var specialName: Result.SpecialName {
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
        self.init(boss: Result.Boss(rawValue: bossId), count: count)
    }
}

extension Result.Boss {
    init(rawValue: Result.BossId) {
        switch rawValue {
            case .goldie:
                self = Result.Boss(name: .goldie, key: .sakelienGolden)
            case .steelhead:
                self = Result.Boss(name: .steelhead, key: .sakelienBomber)
            case .flyfish:
                self = Result.Boss(name: .flyfish, key: .sakelienCupTwins)
            case .steelEel:
                self = Result.Boss(name: .steelEel, key: .sakelienSnake)
            case .scrapper:
                self = Result.Boss(name: .scrapper, key: .sakelienShield)
            case .stinger:
                self = Result.Boss(name: .stinger, key: .sakelienTower)
            case .maws:
                self = Result.Boss(name: .maws, key: .sakediver)
            case .griller:
                self = Result.Boss(name: .griller, key: .sakedozer)
            case .drizzler:
                self = Result.Boss(name: .drizzler, key: .sakerocket)
        }
    }
}

extension Result.Schedule {
    init(from schedule: ResultStats.Schedule) {
        self.init(
            stage: Result.Stage(from: schedule),
            weapons: schedule.weapons.map({ Result.WeaponList(weaponId: $0, rareWeaponId: schedule.rareWeaponId) }),
            endTime: Date.timeIntervalSince1970(iso8601: schedule.endAt),
            startTime: Date.timeIntervalSince1970(iso8601: schedule.scheduleId)
        )
    }
}

extension Result.Stage {
    init(from schedule: ResultStats.Schedule) {
        self.init(
            name: Result.StageName(rawValue: schedule.stageId),
            image: "" // ないものはしょうがないので空欄で適当に埋める
        )
    }
}

extension Result.StageName {
    init(rawValue: Int) {
        switch rawValue {
            case 0:
                self = .shakeup
            case 1:
                self = .shakeship
            case 2:
                self = .shakehouse
            case 3:
                self = .shakelift
            case 4:
                self = .shakeride
            default:
                self = .shakeup
        }
    }
}

extension Result.WeaponList {
    init(weaponId: Int, rareWeaponId: Int?) {
        if let rareWeaponId = rareWeaponId {
            self.init(
                id: String(weaponId),
                weapon: nil,
                coopSpecialWeapon: Result.Brand(weaponId: rareWeaponId)
            )
        }
        self.init(
            id: String(weaponId),
            weapon: Result.Brand(weaponId: weaponId),
            coopSpecialWeapon: nil
        )
    }
}

extension Result.Brand {
    init?(weaponId: Int) {
        self.init(
            id: String(weaponId),
            thumbnail: nil,
            image: "",
            name: "")
    }
}

extension Result.GradeType {
    init?(from response: ResultStats.Response, playerId: String) {
        // プレイヤーIDが一致する最初のプレイヤーのgradePointを取得する
        // そのようなプレイヤーがいない、gradePointが入っていない、変換不可能な値がある場合はnilを返す
        guard let gradePoint = response.playerResults.first(where: { $0.playerId == playerId })?.gradePoint,
              let gradeName = Result.GradeName(rawValue: gradePoint) else {
            return nil
        }
        
        self.init(
            longName: gradeName,
            id: gradeName.gradeId,
            shortName: gradeName,
            name: gradeName
        )
    }
}

extension Result.GradeName {
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
    
    var gradeId: String {
        switch self {
            case .profreshional:
                return "5"
            case .overachiver:
                return "4"
            case .gogetter:
                return "3"
            case .parttimer:
                return "2"
            case .apparentice:
                return "1"
            case .intern:
                return "0"
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
            waterLevel: Result.WaterLevel(name: Result.WaterName(waterLevel: response.waterId), key: Result.WaterKey(waterLevel: response.waterId)),
            ikuraNum: response.powerEggCollected,
            goldenIkuraNum: response.goldenEggDelivered,
            eventType: Result.EventType(name: Result.EventName(eventType: response.eventId), key: Result.EventKey(eventType: response.eventId))
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
}

extension Result.WaterName {
    init(waterLevel: Int) {
        switch waterLevel {
            case 1:
                self = .lowTide
            case 2:
                self = .normal
            case 3:
                self = .highTide
            default:
                self = .normal
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
}

extension Result.EventName {
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
                self = .theGriller
            case 5:
                self = .fog
            case 6:
                self = .rush
            default:
                self = .waterLevels
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
