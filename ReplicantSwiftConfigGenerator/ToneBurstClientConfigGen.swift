//
//  ToneBurstClientConfigGen.swift
//  ReplicantSwiftConfigGenerator
//
//  Created by Mafalda on 2/7/22.
//

import Foundation
import ArgumentParser
import ReplicantSwift

extension Command
{
    struct ToneBurstClientConfigGen: ParsableCommand
    {
        static var configuration: CommandConfiguration
        {
            .init(commandName: "toneburst-client",
                  abstract: "Generates a ToneBurst client config file.")
        }
        
        @Argument(help:"The directory path where the config should be saved. Note: If a file with the same name already exists in this location, it will be deleted.")
        var saveDirectoryPath: String
        
        @Option(
            name: .shortAndLong,
            parsing: .next,
            help: "The name you would like us to give to this config file. The default will be the name of the selected ToneBurst type.")
        var filename: String?
        
        @Option(
            name: .shortAndLong,
            parsing: .next,
            help: "The type of ToneBurst to use. Currently only Whalesong is supported.")
        var type: String
        
        @Option(
            name: .shortAndLong,
            parsing: .next,
            help: "The sequence ToneBurst should use.")
        var sequence: String
        
        @Option(
            name: .shortAndLong,
            parsing: .next,
            help: "The number of times the sequence should be repeated. Note: The count must be greater than 0, but less than 65,535.")
        var count: Int
                
        func run() throws
        {
            guard let toneBurstType = ToneBurstType(rawValue: type) else
            {
                throw Error.invalidType(badType: type.lowercased())
            }
            
            let sequenceData = Data(string: sequence)
            
            guard let toneBurstSequence = SequenceModel(sequence: sequenceData, length: UInt(count)) else
            {
                throw Error.invalidSequence(seqString: sequence, seqLength: count)
            }
            
            let addSequences = [toneBurstSequence]
            let removeSequences = [toneBurstSequence]
            var toneBurstClientConfig: ToneBurstClientConfig
            
            switch toneBurstType
            {
                case .whalesong:
                    guard let whalesongClient = WhalesongClient(addSequences: addSequences, removeSequences: removeSequences) else
                    {
                        throw Error.invalidWhalesongSequence(seqString: sequence, seqLength: count)
                    }
                    
                    toneBurstClientConfig = ToneBurstClientConfig.whalesong(client: whalesongClient)
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            do
            {
                let configData = try encoder.encode(toneBurstClientConfig)
                var saveFilename = "\(type)ClientConfig.json"
                
                if filename != nil
                {
                    saveFilename = filename!
                }
                
                if FileManager.default.fileExists(atPath: saveDirectoryPath.appending(saveFilename))
                {
                    try FileManager.default.removeItem(atPath: saveDirectoryPath.appending(saveFilename))
                }
                
                let configSaved = FileManager.default.createFile(atPath: saveDirectoryPath.appending(saveFilename), contents: configData)
                 
                 if configSaved
                 {
                     print("Created a ToneBurst client config at \(saveDirectoryPath):\n\(configData)")
                 }
                else
                {
                    throw Error.saveFailed
                }
            }
            catch (let error)
            {
                print("Failed to encode config into JSON format: \(error)")
                throw error
            }
            
        }
        
        func validate() throws
        {
            let dirURL = URL(fileURLWithPath: saveDirectoryPath)
            guard dirURL.hasDirectoryPath
            else
            {
                throw Error.savePathIsNotDirectory(path: saveDirectoryPath)
            }
            
            guard count > 0 && count < 65_535 else
            {
                throw Error.invalidCount(badCount: count)
            }
            
            guard !sequence.isEmpty else
            {
                throw Error.emptySequence
            }
            
            guard !type.isEmpty else
            {
                throw Error.emptyType
            }
        }
        
        enum Error: LocalizedError
        {
            case savePathIsNotDirectory(path: String)
            case invalidCount(badCount: Int)
            case emptySequence
            case emptyType
            case invalidType(badType: String)
            case invalidSequence(seqString: String, seqLength: Int)
            case invalidWhalesongSequence(seqString: String, seqLength: Int)
            case saveFailed
            
            var errorDescription: String?
            {
                switch self
                {
                    case .savePathIsNotDirectory(let path):
                        return "The provided save path is not a directory. Provided path: \(path)"
                    case .invalidCount(let badCount):
                        return "\(badCount) is an invalid value. Count must be between 0 and 65,535."
                    case .emptySequence:
                        return "A sequence must be specified."
                    case .emptyType:
                        return "You must specify the type of Toneburst config to create. Currently only whalesong is supported."
                    case .invalidType(let badType):
                        return "The specified type: \(badType), is invalid. Currently only whalesong is supported."
                    case .invalidSequence(let seqString, let seqLength):
                        return "Failed to create a valid ToneBurst Sequence using \(seqString), with a count of \(seqLength)."
                    case .invalidWhalesongSequence(let seqString, let seqLength):
                        return "Failed to create a valid Whaesong configuration using \(seqString), with a count of \(seqLength)."
                    case .saveFailed:
                        return "We were unable to save the ToneBurst config. Please try again."
                }
            }
        }
    }
}
