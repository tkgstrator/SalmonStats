import Foundation
import Combine
import SplatNet2

extension SplatNet2.Coop.Result {
    convenience init(from response: ResultStats.Response, playerId: String) {
        self.init()
        let startTime: Int = response.scheduleId.timeIntervalSince1970
        let playTime: Int = response.startAt.timeIntervalSince1970
        let shift = SplatNet2.shiftSchedule.filter({ $0.startTime == startTime }).first!

        self.jobId = response.id
        self.stageId = shift.stageId
        // 評価があればそれから値を計算する
        if let gradePoint = response.playerResults.filter({ $0.playerId == playerId }).first?.gradePoint {
            let grade: Int = gradePoint.grade
            self.grade = gradePoint.grade
            self.gradePoint = gradePoint - (grade - 1) * 100
        }
        self.jobResult = SplatNet2.Coop.ResultJob(from: response)
        self.dangerRate = Double(response.dangerRate)!
        self.schedule = SplatNet2.Coop.Schedule(from: shift)
        self.time = SplatNet2.Coop.ResultTime(playTime: playTime, from: shift)
        self.bossCounts = response.bossAppearances.sorted{ $0.0 < $1.0 }.map({ $0.value })
        let members = response.memberAccounts
        let membersResults = response.playerResults.filter({ $0.playerId == playerId }) + response.playerResults.filter({ $0.playerId != playerId })
        self.results = membersResults.map({ SplatNet2.Coop.ResultPlayer(from: $0, members: members) })
        
        var tmpKillCounts = Array(repeating: 0, count: 9)
        for result in results {
            tmpKillCounts = Array(zip(tmpKillCounts, result.bossKillCounts)).map({ $0.0 + $0.1 })
        }
        self.bossKillCounts = tmpKillCounts
        self.waveDetails = response.waves.map({ SplatNet2.Coop.ResultWave(from: $0) })
        self.goldenEggs = response.goldenEggDelivered
        self.powerEggs = response.powerEggCollected
    }
}

extension SplatNet2.Coop.ResultWave {
    convenience init(from response: ResultStats.Response.WaveResult) {
        self.init()
        print(response)
        self.eventType = response.eventId.eventType
        self.waterLevel = response.waterId.waterLevel
        self.ikuraNum = response.powerEggCollected
        self.goldenIkuraNum = response.goldenEggDelivered
        self.goldenIkuraPopNum = response.goldenEggAppearances
        self.quotaNum = response.goldenEggQuota
    }
}

extension SplatNet2.Coop.ResultPlayer {
    convenience init(from response: ResultStats.Response.PlayerResult, members: [ResultStats.Response.CrewMember]?) {
        self.init()
        self.bossKillCounts = response.bossEliminations.counts.sorted{ $0.0 < $1.0 }.map({ $0.value })
        self.helpCount = response.rescue
        self.deadCount = response.death
        self.ikuraNum = response.powerEggs
        self.goldenIkuraNum = response.goldenEggs
        self.pid = response.playerId
        self.name = members?.filter{ $0.playerId == response.playerId }.first?.name
        self.playerType = SplatNet2.Coop.PlayerType()
        self.specialId = response.specialId
        self.specialCounts = response.specialUses.map({ $0.count })
        self.weaponList = response.weapons.map({ $0.weaponId })
    }
}

extension SplatNet2.Coop.PlayerType {
}

extension SplatNet2.Coop.ResultJob {
    convenience init(from response: ResultStats.Response) {
        self.init()
        self.failureReason = response.failReasonId.failureReason
        self.failureWave = (response.clearWaves == 3 ? nil : response.clearWaves + 1)
        self.isClear = response.clearWaves == 3
    }
}

extension SplatNet2.Coop.ResultTime {
    convenience init(playTime: Int, from shift: ScheduleCoop.Response) {
        self.init()
        self.playTime = playTime
        self.startTime = shift.startTime
        self.endTime = shift.endTime
    }
}

extension SplatNet2.Coop.Schedule {
    convenience init(from shift: ScheduleCoop.Response) {
        self.init()
        self.startTime = shift.startTime
        self.endTime = shift.endTime
        self.weaponList = shift.weaponList
        self.stageId = shift.stageId
    }
}

private extension Int {
    var grade: Int {
        switch self {
        case 0 ..< 100:
            return 1
        case 100 ..< 200:
            return 2
        case 200 ..< 300:
            return 3
        case 300 ..< 400:
            return 4
        case 400 ..< 1399:
            return 5
        default:
            return 5
        }
    }
}

private extension Optional where Wrapped == Int {
    var failureReason: String? {
        if let value = self {
            switch value {
            case 1:
                return "wipe_out"
            case 2:
                return "time_limit"
            default:
                return nil
            }
        }
        return nil
    }
}

private extension Int {
    var eventType: Int {
        switch self {
        case 0:
            return 0
        case 1:
            return 6
        case 2:
            return 5
        case 3:
            return 2
        case 4:
            return 3
        case 5:
            return 4
        case 6:
            return 1
        default:
            return 0
        }
    }
    
    var waterLevel: Int {
        switch self {
        case 1:
            return 0
        case 2:
            return 1
        case 3:
            return 2
        default:
            return 1
        }
    }
}

private extension String {
    var timeIntervalSince1970: Int {
        guard let dateTime: Date = SalmonStats.formatter.date(from: self) else {
            let dateTime: Date = SalmonStats.iso8601formatter.date(from: self)!
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
