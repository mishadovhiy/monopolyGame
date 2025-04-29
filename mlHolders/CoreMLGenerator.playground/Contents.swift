import CreateML
import Foundation
import TabularData

struct ProjectMetadata {
    var description:String
    var version:String
    var cvsName:FileName
    enum FileName:String, CaseIterable {
        case upgradeSkip
        case buyAuction
        case continiueBetting
    }
    
    static func configure(file:FileName) -> Self {
        switch file {
        case .upgradeSkip:
                .init(description: """
                    enemy model to predict, if enemy should upgrade owned properties or skip. Called when enemy has enought balance
                    """, version: "4", cvsName: file)
        case .buyAuction:
                .init(description: """
                    enemy move completion model, to prediction  buy or start auction. Called each time when enemy completed moving, to unwoned property and has enough balance to buy ptoperty
                    """, version: "6", cvsName: file)
        case .continiueBetting:
                .init(description: """
                    enemy auction model, to predict, keep betting or decline
                    """, version: "4", cvsName: file)
        }
    }
}


func create(_ input:ProjectMetadata) {
    let data = try! DataFrame(contentsOfCSVFile: URL(fileURLWithPath: "/Users/mykhailodovhyi/Developer/other/MonopolyGame/mlHolders/createML/buy/\(input.cvsName.rawValue).csv"))
    let model = try! MLClassifier(trainingData: data, targetColumn: "action")
    try! model.write(to: URL(fileURLWithPath: "/Users/mykhailodovhyi/Developer/other/MonopolyGame/mlHolders/createML/buy/\(input.cvsName.rawValue.capitalized)Model.mlmodel"), metadata: .init(author: "Mykhailo Dovhiy", shortDescription: input.description, license: "Mykhailo Dovhyi", version: input.version, additional: [:]))
    
}

ProjectMetadata.FileName.allCases.forEach {
    create(.configure(file: $0))

}
