//
//  ClientConfig.swift
//  ReplicantSwiftConfigGenerator
//
//  Created by Mafalda on 2/4/22.
//

import Foundation
import ArgumentParser
import AST

extension Command
{
    struct ClientConfig: ParsableCommand
    {
        static var configuration: CommandConfiguration
        {
            .init(
                commandName: "client",
                abstract: "Generates a Replicant Client Config"
            )
        }
        
        @Argument(help:"The directory path where the config should be saved. Note: If a file with the same name already exists in this location, it will be deleted.")
        var saveDirectoryPath: String
        
        @Option(
            name: .shortAndLong,
            parsing: .next,
            help: "The path to the Polish config file if Polish is being used.")
        var polish: String?
        
        @Option(
            name: .shortAndLong,
            parsing: .next,
            help: "The path to the ToneBurst config if ToneBurst is being used.")
        var toneBurst: String?
        
        func run() throws
        {
            print("\n📝  Generating client config file.\n")
        }
        
        func validate() throws
        {
            let dirURL = URL(fileURLWithPath: saveDirectoryPath)
            guard dirURL.hasDirectoryPath
            else
            {
                throw Error.savePathIsNotDirectory
            }
            
            if let polishPath = polish
            {
                guard FileManager.default.fileExists(atPath: polishPath) else
                {
                    throw Error.fileNotFound(path: polishPath)
                }
            }
            
            if let toneBurstPath = toneBurst
            {
                guard FileManager.default.fileExists(atPath: toneBurstPath) else
                {
                    throw Error.fileNotFound(path: toneBurstPath)
                }
            }
            
        }
        
        enum Error: LocalizedError
        {
            case fileNotFound(path: String)
            case savePathIsNotDirectory
            case saveFailure
            
            
            var errorDescription: String?
            {
                switch self
                {
                    case .fileNotFound(let path):
                        return "Failed to find a file at the specified path: \(path)"
                    case .savePathIsNotDirectory:
                        return "The provided save path is not a directory."
                    case .saveFailure:
                        return "Failed to save the config file to the provided directory."
                }
            }
        }
    }
}
