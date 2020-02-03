import Foundation
import ApolloCodegenLib

enum MyCodegenError: Error {
  case sourceRootNotProvided
  case sourceRootNotADirectory
  case targetDoesntExist
}

guard let sourceRootPath = ProcessInfo.processInfo.environment["SRCROOT"] else {
  throw MyCodegenError.sourceRootNotProvided
}

guard FileManager.default.apollo_folderExists(at: sourceRootPath) else {
  throw MyCodegenError.sourceRootNotADirectory
}

let sourceRootURL = URL(fileURLWithPath: sourceRootPath)

let starWarsTarget = sourceRootURL
  .appendingPathComponent("Tests")
  .appendingPathComponent("StarWarsAPI")

guard FileManager.default.apollo_folderExists(at: starWarsTarget) else {
  throw MyCodegenError.targetDoesntExist
}

let scriptFolderURL = sourceRootURL.appendingPathComponent("scripts")
let options = ApolloCodegenOptions(targetRootURL: starWarsTarget)

do {
  let result = try ApolloCodegen.run(from: starWarsTarget,
                                     with: scriptFolderURL,
                                     options: options)
  print("RESULT: \(result)")
} catch {
  print("ERROR: \(error)")
  exit(1)
}
