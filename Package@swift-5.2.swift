// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Apollo",
    products: [
    .library(
      name: "ApolloCore",
      targets: ["ApolloCore"]),
    .library(
      name: "Apollo",
      targets: ["Apollo"]),
    .library(
        name: "Apollo-Dynamic",
        type: .dynamic,
        targets: ["Apollo"]),
    .library(
      name: "ApolloCodegenLib",
      targets: ["ApolloCodegenLib"]),
    .library(
        name: "ApolloSQLite",
        targets: ["ApolloSQLite"]),
    .library(
        name: "ApolloWebSocket",
        targets: ["ApolloWebSocket"]),
    ],
    dependencies: [
    .package(
      url: "https://github.com/stephencelis/SQLite.swift.git",
      .upToNextMinor(from: "0.12.2")),
    .package(
      url: "https://github.com/daltoniam/Starscream",
      .upToNextMinor(from: "3.1.1")),
    ],
    targets: [
      .target(
        name: "ApolloCore",
        dependencies: []),
    .target(
      name: "Apollo",
      dependencies: [
        "ApolloCore",
      ]),
    .target(
      name: "ApolloCodegenLib",
      dependencies: [
        "ApolloCore",
      ]),
    .target(
      name: "ApolloSQLite",
      dependencies: [
        "Apollo",
        .product(name: "SQLite", package: "SQLite.swift"),
      ]),
    .target(
      name: "ApolloWebSocket",
      dependencies: [
        "Apollo",
        "ApolloCore",
        .product(name: "Starscream", package: "Starscream"),
      ])    
    ]
)
