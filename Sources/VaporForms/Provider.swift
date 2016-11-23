import Vapor
import Leaf

public final class Provider: Vapor.Provider {
  public init(config: Config) throws {}

  public func beforeRun(_ drop: Droplet) {
    let stem = (drop.view as? LeafRenderer)?.stem
    let tags: [Tag] = [ErrorsForFormInput(), ValueForFormInput()]
    tags.forEach {
      stem?.register($0)
    }
  }
}
