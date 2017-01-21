import PackageDescription

let package = Package(
  name: "VaporForms",
  dependencies: [
    .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 4),
  ]
)
