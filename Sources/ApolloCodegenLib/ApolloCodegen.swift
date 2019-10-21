//
//  ApolloCodegen.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 9/24/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

/// A class to facilitate running code generation
public class ApolloCodegen {
  
  /// Errors which can happen with code generation
  public enum ApolloCodegenError: Error, LocalizedError {
    case folderDoesNotExist(_ url: URL)
    
    public var errorDescription: String? {
      switch self {
      case .folderDoesNotExist(let url):
        return "Can't run codegen from \(url) - there is no folder there!"
      }
    }
  }
  
  /// Runs code generation from the given folder with the passed-in options
  ///
  /// - Parameter folder: The folder to run the script from. Should be the folder that at some depth, contains all `.graphql` files.
  /// - Parameter scriptFolderURL: The folder where the Apollo scripts have been checked out.
  /// - Parameter options: The options object to use to run the code generation.
  public static func run(from folder: URL,
                         scriptFolderURL: URL,
                         options: ApolloCodegenOptions) throws -> String {
    guard FileManager.default.apollo_folderExists(at: folder) else {
      throw ApolloCodegenError.folderDoesNotExist(folder)
    }
    
    switch options.outputFormat {
    case .multipleFiles(let folderURL):
      try FileManager.default.apollo_createFolderIfNeeded(at: folderURL)
    case .singleFile(let fileURL):
      try FileManager.default.apollo_createContainingFolderIfNeeded(for: fileURL)
    }
    
    let cli = try ApolloCLI.createCLI(scriptsFolderURL: scriptFolderURL)
    return try cli.runApollo(with: options.arguments, from: folder)
  }
}