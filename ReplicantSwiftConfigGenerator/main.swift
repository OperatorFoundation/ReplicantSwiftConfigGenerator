//
//  main.swift
//  ReplicantSwiftConfigGenerator
//
//  Created by Mafalda on 2/4/22.
//

import ArgumentParser
import Foundation

enum Command {}

extension Command
{
    struct Main: ParsableCommand
    {
        static var configuration: CommandConfiguration
        {
            .init(
                commandName: "ReplicantConfigGenerator",
                abstract: "A tool for generating Replicant config json files for Replicant Swift implementations.",
                subcommands: [
                    Command.ReplicantClientConfigGen.self,
                    Command.ToneBurstClientConfigGen.self
                ]
            )
        }
    }
}

Command.Main.main()
