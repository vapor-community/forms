import PackageDescription

let package = Package(
  name: "VaporForms",
  dependencies: [
    .Package(url: "https://github.com/vapor/validation-provider.git", majorVersion: 0),
    .Package(url: "https://github.com/vapor/leaf-provider.git", majorVersion: 0),
    .Package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 0),
  ]
)
